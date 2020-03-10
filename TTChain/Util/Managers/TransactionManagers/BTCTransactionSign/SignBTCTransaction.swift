//
//  SignBTCTransaction.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/5/6.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation
import HDWalletKit
import RxSwift

class SignBTCTransaction {
    
    private var destinations: [(address: Address, amount: UInt64)]?
    
    init() {
        
    }
    private var fee:UInt64 = 0
    private var targetValue:UInt64 = 0
    private var isCompressed:Bool = true
    
    static func getSignTxForBTC(withInfo info: WithdrawalInfo, forUnspents unspents:[UnspentTransaction],isCompressed:Bool) -> RxAPIResponse<String> {
        
        let instance = SignBTCTransaction.init()
        instance.fee = NSDecimalNumber(decimal:info.totalFee.btcToSatoshi).uint64Value
        
        instance.targetValue =  NSDecimalNumber(decimal:info.withdrawalAmt.btcToSatoshi).uint64Value
        instance.isCompressed = isCompressed
        let fromAddress = try! LegacyAddress(info.wallet.address!, coin: .bitcoin)
        let toAddress = try! LegacyAddress(info.address, coin: .bitcoin)
        
        return Single.create { (handler) -> Disposable in
            do {
                
                let utxosToSpend = try instance.select(info: info, utxos: unspents)
                let totalAmount = utxosToSpend.sum()
                
                var change: UInt64
                var targetValue:UInt64
                var unsignedTx:UnsignedTransaction
                
                if info.asset.coinID == Coin.usdt_identifier {
                    targetValue = 546
                    change = totalAmount - targetValue - instance.fee
                    instance.destinations = [(toAddress, targetValue), (fromAddress, change)]
                    unsignedTx = try instance.buildUnspendTxForUSDTtoUSDT(utxos: utxosToSpend)
                }else {
                    change = totalAmount - instance.targetValue - instance.fee
//                    targetValue = instance.targetValue
//                    instance.destinations = [(toAddress, targetValue), (fromAddress, change)]
                    if (change == 0) {
                        instance.destinations = [(toAddress, instance.targetValue)]
                    } else {
                        instance.destinations = [(toAddress, instance.targetValue), (fromAddress, change)]
                    }
                    unsignedTx = try instance.buildUnspentTxForBTCtoBTC(utxos: utxosToSpend)
                }
                
                guard let privateKey = PrivateKey.init(pk: info.wallet.pKey, coin: .bitcoin) else {
                    throw GTServerAPIError.incorrectResult("", "Cant get private key")
                }
                let signedTx = try instance.signBtc(unsignedTx, with: privateKey)
                let signedTxString = signedTx.serialized().hex
                DLogInfo(signedTxString)
                handler(.success(.success(signedTxString)))
            } catch let error{
                let apiError = error is GTServerAPIError ? (error as! GTServerAPIError) : GTServerAPIError.incorrectResult("", error.localizedDescription)
                handler(.success(.failed(error: apiError)))
            }
            return Disposables.create()
        }
        
    }
    
    static func getSignTxForTTNChain(withInfo info: WithdrawalInfo, forUnspents unspents:[UnspentTransaction], ttnAddress:String,isCompressed:Bool) -> RxAPIResponse<String> {
        
        let instance = SignBTCTransaction.init()
        instance.fee = NSDecimalNumber(decimal:info.totalFee.btcToSatoshi).uint64Value
        if info.asset.coinID == Coin.usdt_identifier {
            instance.fee += (546+546) // extra fee for USDT_tx
        }
        instance.targetValue = NSDecimalNumber(decimal:info.withdrawalAmt.btcToSatoshi).uint64Value
        instance.isCompressed = isCompressed
        let fromAddress = try! LegacyAddress(info.wallet.address!, coin: .bitcoin)
        let toAddress = try! LegacyAddress(info.address, coin: .bitcoin)

        return Single.create { (handler) -> Disposable in
            do {
                
                let utxosToSpend = try instance.select(info: info, utxos: unspents)
                let totalAmount = utxosToSpend.sum()
                
                var change: UInt64
                
                var unsignedTx:UnsignedTransaction
                if info.asset.coinID == Coin.usdt_identifier {
                    change = totalAmount - instance.fee
                    instance.destinations = [(fromAddress, change),(toAddress, 546)]
                    unsignedTx = try instance.buildUnspendTxForUSDTNtoTTN(utxos: utxosToSpend,ttnAddress: ttnAddress)
                }else {
                    change = totalAmount - instance.targetValue - instance.fee
                    instance.destinations = [(toAddress, instance.targetValue), (fromAddress, change)]
                    unsignedTx = try instance.buildUnspentTxForBTCtoTTN(utxos: utxosToSpend,ttnAddress: ttnAddress)
                }
                guard let privateKey = PrivateKey.init(pk: info.wallet.pKey, coin: .bitcoin) else {
                    throw GTServerAPIError.incorrectResult("", "Cant get private key")
                }
                let signedTx = try instance.signBtc(unsignedTx, with: privateKey)
                let signedTxString = signedTx.serialized().hex
                DLogInfo(signedTxString)
                handler(.success(.success(signedTxString)))
            } catch let error{
                let apiError = error is GTServerAPIError ? (error as! GTServerAPIError) : GTServerAPIError.incorrectResult("", error.localizedDescription)
                handler(.success(.failed(error: apiError)))
            }
            return Disposables.create()
        }
        
    }
    

    func buildUnspendTxForUSDTNtoTTN(utxos:[UnspentTransaction],ttnAddress:String) throws -> UnsignedTransaction {
        
        var outputs = [TransactionOutput]()
        
        let usdtHex = String(targetValue,radix:16)
        let padded = "0000000000000000".dropLast(usdtHex.count) + usdtHex
        DLogInfo("usdtnhext padded \(padded)")
        let outputForUSDTN = "6f6d6e69000000000000001f\(padded)"
        let dataForUSDTN = Data.fromHex(outputForUSDTN)
        //        let hexString = outputForTTN.toHexString()
        
        var scriptForUSDTN = Script()
        scriptForUSDTN = try! scriptForUSDTN.append(.OP_RETURN)
        scriptForUSDTN = try! scriptForUSDTN.appendData(dataForUSDTN!)
        
        let lockingScriptForUSDTN = scriptForUSDTN.data
        let transOutputForUSDTN = TransactionOutput(value: 0, lockingScript: lockingScriptForUSDTN)
        outputs.append(transOutputForUSDTN)

        
        let base58TTNAddress = TTNWalletManager.getBase58Address(forAddress:ttnAddress)

        guard let address = try? LegacyAddress.init(base58TTNAddress, coin: .bitcoin) else {
            throw GTServerAPIError.incorrectResult("","Failed to create base58 ttn address")
        }
        
        guard let lockingScript = Script.init(address: address)?.data else {
            throw GTServerAPIError.incorrectResult("","Failed to create LockingScript")
        }
        outputs.append(TransactionOutput.init(value: 546, lockingScript: lockingScript))
        
        outputs.append(contentsOf:try self.destinations!.map { (address: Address, amount: UInt64) -> TransactionOutput in
            guard let lockingScript = Script(address: address)?.data else {
                throw GTServerAPIError.incorrectResult("","Invalid address type")
            }
            return TransactionOutput(value: amount, lockingScript: lockingScript)
            })

        let unsignedInputs = utxos.map { TransactionInput(previousOutput: $0.outpoint, signatureScript: $0.output.lockingScript, sequence: UInt32.max) }
        let tx = Transaction(version: 1, inputs: unsignedInputs, outputs: outputs, lockTime: 0)
        return UnsignedTransaction(tx: tx, utxos: utxos)
    }
    
    func buildUnspentTxForBTCtoTTN(utxos:[UnspentTransaction],ttnAddress:String) throws -> UnsignedTransaction {
        
        var outputs = try self.destinations!.map { (address: Address, amount: UInt64) -> TransactionOutput in
            guard let lockingScript = Script(address: address)?.data else {
                throw GTServerAPIError.incorrectResult("","Invalid address type")
            }
            return TransactionOutput(value: amount, lockingScript: lockingScript)
        }
        let outputForTTN = "c2cccccc0000000000000001\(ttnAddress)"
        let data = Data.fromHex(outputForTTN)
        //        let hexString = outputForTTN.toHexString()
        
        var script = Script()
        script = try! script.append(.OP_RETURN)
        script = try! script.appendData(data!)
        
        let lockingScript = script.data
        let transOutput = TransactionOutput(value: 0, lockingScript: lockingScript)
        outputs.append(transOutput)
        
        
        let unsignedInputs = utxos.map { TransactionInput(previousOutput: $0.outpoint, signatureScript: $0.output.lockingScript, sequence: UInt32.max) }
        let tx = Transaction(version: 1, inputs: unsignedInputs, outputs: outputs, lockTime: 0)
        return UnsignedTransaction(tx: tx, utxos: utxos)
    }
    
    func buildUnspendTxForUSDTtoUSDT(utxos:[UnspentTransaction]) throws -> UnsignedTransaction {
        
        var outputs = [TransactionOutput]()
        
        let usdtHex = String(targetValue,radix:16)
        let padded = "0000000000000000".dropLast(usdtHex.count) + usdtHex
        DLogInfo("usdthex padded \(padded)")
        let outputForUSDT = "6f6d6e69000000000000001f\(padded)"
        let dataForUSDT = Data.fromHex(outputForUSDT)
        
        var scriptForUSDT = Script()
        scriptForUSDT = try! scriptForUSDT.append(.OP_RETURN)
        scriptForUSDT = try! scriptForUSDT.appendData(dataForUSDT!)
        
        let lockingScriptForUSDT = scriptForUSDT.data
        let transOutputForUSDT = TransactionOutput(value: 0, lockingScript: lockingScriptForUSDT)
        outputs.append(transOutputForUSDT)
        
        outputs.append(contentsOf:try self.destinations!.map { (address: Address, amount: UInt64) -> TransactionOutput in
            guard let lockingScript = Script(address: address)?.data else {
                throw GTServerAPIError.incorrectResult("","Invalid address type")
            }
            return TransactionOutput(value: amount, lockingScript: lockingScript)
            })
        
        let unsignedInputs = utxos.map { TransactionInput(previousOutput: $0.outpoint, signatureScript: $0.output.lockingScript, sequence: UInt32.max) }
        let tx = Transaction(version: 1, inputs: unsignedInputs, outputs: outputs, lockTime: 0)
        return UnsignedTransaction(tx: tx, utxos: utxos)
    }
    
    func buildUnspentTxForBTCtoBTC(utxos:[UnspentTransaction]) throws -> UnsignedTransaction {
        
        let outputs = try self.destinations!.map { (address: Address, amount: UInt64) -> TransactionOutput in
            guard let lockingScript = Script(address: address)?.data else {
                throw GTServerAPIError.incorrectResult("","Invalid address type")
            }
            return TransactionOutput(value: amount, lockingScript: lockingScript)
        }
        
        let unsignedInputs = utxos.map { TransactionInput(previousOutput: $0.outpoint, signatureScript: $0.output.lockingScript, sequence: UInt32.max) }
        let tx = Transaction(version: 1, inputs: unsignedInputs, outputs: outputs, lockTime: 0)
        return UnsignedTransaction(tx: tx, utxos: utxos)
    }
    
    func select(info: WithdrawalInfo, utxos: [UnspentTransaction]) throws ->[UnspentTransaction] {
        // if target value is zero, fee is zero
        var tranferAmount = targetValue
        let dustThreshhold : UInt64 = 3 * 182

        if info.asset.coinID == Coin.usdt_identifier {
            //Since we are transferring USDT, for unspents we just make sure there is enough for fee and dust
            tranferAmount = 0 + dustThreshhold
        }
        guard tranferAmount > 0 else {
            return []
        }
        
        // definitions for the following caluculation
        let doubleTargetValue = tranferAmount * 2
        var numOutputs = 2 // if allow multiple output, it will be changed.
        var numInputs = 2
        var tranferAmountWithFee: UInt64 {
            return tranferAmount + fee
        }
        var targetWithFeeAndDust: UInt64 {
            return tranferAmountWithFee + dustThreshhold
        }
        
        let sortedUtxos: [UnspentTransaction] = utxos.sorted(by: { $0.output.value < $1.output.value })
        
        // total values of utxos should be greater than targetValue
        guard sortedUtxos.sum() >= tranferAmount && !sortedUtxos.isEmpty else {
            let err: GTServerAPIError = GTServerAPIError.incorrectResult(
                LM.dls
                    .withdrawalConfirm_pwdVerify_error_btc_insufficient_fee_title,
                LM.dls
                    .insufficient_unspend_error_msg
            )
            throw err
        }
        
        // difference from 2x targetValue
        func distFrom2x(_ val: UInt64) -> UInt64 {
            if val > doubleTargetValue { return val - doubleTargetValue } else { return doubleTargetValue - val }
        }
        
        // 1. Find a combination of the fewest outputs that is
        //    (1) bigger than what we need
        //    (2) closer to 2x the amount,
        //    (3) and does not produce dust change.
        txN:do {
            for numTx in (1...sortedUtxos.count) {
                numInputs = numTx
                let nOutputsSlices = sortedUtxos.eachSlices(numInputs)
                var nOutputsInRange = nOutputsSlices.filter { $0.sum() >= targetWithFeeAndDust }
                nOutputsInRange.sort { distFrom2x($0.sum()) < distFrom2x($1.sum()) }
                if let nOutputs = nOutputsInRange.first {
                    return nOutputs
                }
            }
        }
        
        // 2. If not, find a combination of outputs that may produce dust change.
        txDiscardDust:do {
            for numTx in (1...sortedUtxos.count) {
                numInputs = numTx
                let nOutputsSlices = sortedUtxos.eachSlices(numInputs)
                let nOutputsInRange = nOutputsSlices.filter {
                    return $0.sum() >= tranferAmountWithFee
                }
                if let nOutputs = nOutputsInRange.first {
                    return nOutputs
                }
            }
        }
        
        let err: GTServerAPIError = GTServerAPIError.incorrectResult(
            LM.dls
                .withdrawalConfirm_pwdVerify_error_btc_insufficient_fee_title,
            LM.dls
                .insufficient_unspend_error_msg
        )
        throw err
    }
    
    func signBtc(_ unsignedTransaction: UnsignedTransaction, with key: PrivateKey) throws -> Transaction {
        // Define Transaction
        var signingInputs: [TransactionInput]
        var signingTransaction: Transaction {
            let tx: Transaction = unsignedTransaction.tx
            return Transaction(version: tx.version, inputs: signingInputs, outputs: tx.outputs, lockTime: tx.lockTime)
        }
        
        // Sign
        signingInputs = unsignedTransaction.tx.inputs
        let hashType = SighashType.BTC.ALL
        for (i, utxo) in unsignedTransaction.utxos.enumerated() {
            // Sign transaction hash
            let sighash: Data = signingTransaction.signatureHash(for: utxo.output, inputIndex: i, hashType: SighashType.BTC.ALL)
            let signature: Data = try ECDSA.sign(sighash, privateKey: key.raw)
            let txin = signingInputs[i]
            let pubkey = key.publicKey
            
            // Create Signature Script
            var hashIntVal = UInt8(hashType)
            let hashDataValue = Data(buffer: UnsafeBufferPointer(start: &hashIntVal, count: 1))
            let sigWithHashType: Data = signature + hashDataValue
            
            let pubkeyData = Data(hex:pubkey.getPublicKey(compressed: self.isCompressed).toHexString())
            
            let unlockingScript: Script = try Script()
                .appendData(sigWithHashType)
                .appendData(pubkeyData)
            
            // Update TransactionInput
            signingInputs[i] = TransactionInput(previousOutput: txin.previousOutput, signatureScript: unlockingScript.data, sequence: txin.sequence)
        }
        return signingTransaction
        
    }

}

enum Result:Error {
    case insufficient
}

private extension Array {
    // Slice Array
    // [0,1,2,3,4,5,6,7,8,9].eachSlices(3)
    // >
    // [[0, 1, 2], [1, 2, 3], [2, 3, 4], [3, 4, 5], [4, 5, 6], [5, 6, 7], [6, 7, 8], [7, 8, 9]]
    func eachSlices(_ num: Int) -> [[Element]] {
        let slices = (0...count - num).map { self[$0..<$0 + num].map { $0 } }
        return slices
    }
}

internal extension Sequence where Element == UnspentTransaction {
    func sum() -> UInt64 {
        return reduce(UInt64()) { $0 + $1.output.value }
    }
}


