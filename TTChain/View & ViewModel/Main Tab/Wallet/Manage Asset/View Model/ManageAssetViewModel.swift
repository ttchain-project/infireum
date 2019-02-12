//
//  ManageAssetViewModel.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/26.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ManageAssetViewModel: KLRxViewModel {
    var bag: DisposeBag = DisposeBag.init()
    
    struct Input {
        let wallet: Wallet
        let source:MainWalletViewController.Source
    }
    
    typealias InputSource = Input
    var input: ManageAssetViewModel.Input
    
    typealias OutputSource = Void
    var output: Void
    
//    private(set) lazy var selections: BehaviorRelay<CoinSelection?
    
    private(set) lazy var coinSels: BehaviorRelay<[CoinSelection]> = {
        return BehaviorRelay.init(value: getSelections())
    }()
    
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
        concatInput()
        concatOutput()
    }
    
    
    func concatInput() {

    }
    
    func concatOutput() {
        
    }
    
    //MARK: Renew CoinSelections
    func refreshDataSource() {
        coinSels.accept(getSelections())
    }
    
    private func getSelections() -> [CoinSelection] {
        var _coinSels = CoinSelection.getAllSelections(of: input.wallet,
                                                       filterIsSelected: false)
        switch input.source {
        case .StableCoin:
            _coinSels = _coinSels.filter { $0.coinIdentifier?.contains("_RSC") == true}
        case .ListCoin:
            _coinSels = _coinSels.filter { $0.coinIdentifier?.contains("_AIRDROP") == true}
        default:
            break
        }
        _coinSels.sort(by: { (sel1, sel2) -> Bool in
            guard let c1 = sel1.coin, let c2 = sel2.coin else {
                return true
            }
            
            let c1_undeletable = c1.isDeletable
            let c2_undeletable = c2.isDeletable
            guard c1_undeletable == c2_undeletable else {
                return c1_undeletable
            }
            
            return true
        })
        
        sortSelsInPlace(&_coinSels,
                        withSortingOption: AssetSortingManager.getSortOption())
        
        return _coinSels
    }
    
    //MARK: - Hide Empty Amt Selection
    func hideEmptyAmtSelections() {
        for sel in coinSels.value {
            if let asset = sel.findAsset() {
                sel.isSelected = (asset.amount! as Decimal) != 0
            }
        }
    }
    
    //MARK: - Coin Selection
    func updateSelectState(ofCoinSelIdx row: Int, isSelected: Bool) {
        guard row < coinSels.value.count else { return }
        updateSelectState(of: coinSels.value[row], isSelected: isSelected)
    }
    
    func updateSelectState(of coinSel: CoinSelection, isSelected: Bool) {
        coinSel.isSelected = isSelected
        guard DB.instance.update() else {
            return errorDebug(response: ())
        }
    }

    //MARK: - CoinSel Deletion
    func deleteCoinSel(idxRow: Int) -> Bool {
        guard idxRow < coinSels.value.count else {
            return errorDebug(response: true)
        }
        
        var sels = coinSels.value
        let sel = sels.remove(at: idxRow)
        
        if let asset = sel.findAsset() {
            DB.instance.managedObjectContext.delete(asset)
        }
        
        OWRxNotificationCenter.instance.willDeleteCoinSelection(sel)
        DB.instance.managedObjectContext.delete(sel)
        DB.instance.update()
        
        coinSels.accept(sels)
        return true
    }
    
    //MARK: - Helper
    func parseSelectedSelectionsToAsset() -> [Asset] {
        let sels = coinSels.value.filter {
            $0.isSelected
        }
        
        let assets = sels.compactMap { $0.findAsset() }
        guard assets.count == sels.count else {
            return errorDebug(response: assets)
        }
        
        return assets
    }
    
    func updateSortingType(sort: AssetSortingManager.Sort) {
        var sels = coinSels.value
        sortSelsInPlace(&sels, withSortingOption: sort)
        coinSels.accept(sels)
    }
    
    private func sortSelsInPlace(_ sels: inout [CoinSelection], withSortingOption sort: AssetSortingManager.Sort) {
        let originSels = sels
        let sortedSels: [CoinSelection]
        switch sort {
        case .none:
            sortedSels = CoinSelection.getAllSelections(of: input.wallet, filterIsSelected: false)
        case .alphabetic:
            sortedSels = originSels.sorted(by: { (sel1, sel2) -> Bool in
                guard let c1 = sel1.coin, let c2 = sel2.coin else {
                    return true
                }
                
                return c1.inAppName! <= c2.inAppName!
            })
        case .assetAmt:
            sortedSels = originSels.sorted(by: { (sel1, sel2) -> Bool in
                guard let a1 = sel1.findAsset(), let a2 = sel2.findAsset() else {
                    return true
                }
                
                guard let a1_amt = a1.amount as Decimal?,
                    let a2_amt = a2.amount as Decimal? else {
                        return true
                }
                
                //If one of asset is empty, just compare the amount itself
                if a1_amt == 0 || a2_amt == 0 {
                    return a1_amt >= a2_amt
                }else {
                    /* Both assets are not empty,
                       so try to get the fiat rate of the coin from DB.
                       If able to get the fiat rate,
                       return the result of fiat value comparison */
                    if let usd = Fiat.usd?.id,
                        let fiatRate1 = CoinToFiatRate.getRateFromDatabase(coinID: a1.coinID!, fiatID: usd)?.rate as Decimal?,
                        let fiatRate2 = CoinToFiatRate.getRateFromDatabase(coinID: a2.coinID!, fiatID: usd)?.rate as Decimal? {
                        return a1_amt * fiatRate1 >= a2_amt * fiatRate2
                    }else {
                        /* if unable to get fiat rate from DB,
                           just compare the asset amt. */
                        return a1_amt >= a2_amt
                    }
                }
            })
        }
        
        var unremovableSels: [CoinSelection] = []
        var removableSels: [CoinSelection] = []
        for sel in sortedSels {
            if sel.coin!.isDeletable {
                removableSels.append(sel)
            }else {
                unremovableSels.append(sel)
            }
        }
        
        //As the unremovable coins shuold always be list at top of the list.
        sels = unremovableSels + removableSels
    }
}
