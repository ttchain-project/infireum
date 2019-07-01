//
//  AddWalletViewModel.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/7/1.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

struct AddWalletSection:IdentifiableType {
    enum Action {
        case create
        case `import`
    }
    var identity: String {
        return self.title
    }
    typealias Identity = String
    let title:String
    var isShowing:Bool = false
    var action:Action
}

struct AddWalletUnit {
    let title:String
    let walletType:ChainType
    var image:UIImage {
        switch walletType {
        case .btc:return #imageLiteral(resourceName: "iconFundsBitcoin")
        case .eth:return #imageLiteral(resourceName: "iconContentEth.png")
        default:
            return UIImage()
        }
    }
}
extension AddWalletUnit: IdentifiableType,Equatable {
    typealias Identity = String
    var identity: String {
        return self.title
    }
    static func ==(lhs:AddWalletUnit, rhs:AddWalletUnit) -> Bool{
        return lhs.title == rhs.title
    }
}

class AddWalletViewModel : KLRxViewModel {
    
    required init(input: Void, output: Void) {
        self.input = input
        self.output = output
        let importSection = AddWalletSection.init(title: LM.dls.qrcode_btn_importWallet, isShowing: false,action: .import)
        let createSection = AddWalletSection.init(title: LM.dls.create_new_wallet, isShowing: false,action: .create)
         let animatableSections = [AnimatableSectionModel<AddWalletSection, AddWalletUnit>.init(model:createSection,items:[]),
                                  AnimatableSectionModel<AddWalletSection, AddWalletUnit>.init(model:importSection,items:[])]
        self.animatableSectionModel.accept(animatableSections)
    }
    
    let importWalletUnits = [AddWalletUnit.init(title:"\(LM.dls.import_key_string) \(LM.dls.setting_export_btc_wallet_title)", walletType: .btc),AddWalletUnit.init(title: "\(LM.dls.import_key_string) \(LM.dls.setting_export_eth_wallet_title)", walletType: .eth)]
    let createWalletUnits = [AddWalletUnit.init(title:"\(LM.dls.createID_btn_create) \(LM.dls.setting_export_btc_wallet_title)", walletType: .btc),AddWalletUnit.init(title: "\(LM.dls.createID_btn_create) \(LM.dls.setting_export_eth_wallet_title)", walletType: .eth)]
    
    var animatableSectionModel = BehaviorRelay<[AnimatableSectionModel<AddWalletSection, AddWalletUnit>]>(value: [AnimatableSectionModel<AddWalletSection, AddWalletUnit>]())

    
    let dataSource = RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<AddWalletSection, AddWalletUnit>>.init(animationConfiguration:AnimationConfiguration(insertAnimation: .fade,
                                                                                                                               reloadAnimation: .fade,
                                                                                                                               deleteAnimation: .fade)
        ,configureCell: { (dataSource, tv, indexPath, model) -> UITableViewCell in
    
            let cell = tv.dequeueReusableCell(withClass: ExportWalletSettingsTableViewCell.self)
            cell.configForImport(walletUnit: model)
            cell.exportLabel.text = indexPath.section == 0 ? LM.dls.createID_btn_create : LM.dls.import_key_string

            return cell
    })
    
    var input: Void
    
    var output: Void
    
    func concatInput() {
        
    }
    
    func concatOutput() {
        
    }
    
    typealias InputSource = Void
    
    typealias OutputSource = Void
    
    var bag:DisposeBag = DisposeBag()
    
    func updateSection(section:Int) {
        var array = self.animatableSectionModel.value
        var sectionModel = array[section]
        if sectionModel.model.isShowing {
            sectionModel.items = []
        }else {
            sectionModel.items = sectionModel.model.action == .create ? createWalletUnits : importWalletUnits
        }
        sectionModel.model.isShowing = !sectionModel.model.isShowing
        array.remove(at: section)
        array.insert(sectionModel, at: section)
        self.animatableSectionModel.accept(array)
    }
}

