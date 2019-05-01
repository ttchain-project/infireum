
import Foundation

class TTNTxFilter: TxFilter {
    typealias Tx = TTNTx
    typealias ConditionInput = Coin
    func filter(source: [Tx], condition: ConditionInput) -> (valid: [Tx], unused: [Tx], unsupports: [Tx]) {
        var valid: [Tx] = []
        var unused: [Tx] = []
        let unsupports: [Tx] = []
        
        for tx in source {
            if tx.coin.identifier == condition.identifier {
                valid.append(tx)
            }else {
                unused.append(tx)
            }
        }
        
        return (valid: valid, unused: unused, unsupports: unsupports)
    }
}
