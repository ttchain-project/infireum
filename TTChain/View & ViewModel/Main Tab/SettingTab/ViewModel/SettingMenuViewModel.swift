//
//  SettingMenuViewModel.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/1/8.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxDataSources

enum SettingType {
    case Notification
    case Language
    case VersionCheck
    case Address
    case Currency
    case ExportETHWallet
    case ExportBTCWallet
    case BackupAccount
    case DeleteAccount
    
    var image: UIImage {
        switch self {
        case .Notification:
            return #imageLiteral(resourceName: "setting_icon_message.png")
        case .Address:
            return #imageLiteral(resourceName: "setting_icon_address.png")
        case .Language:
            return #imageLiteral(resourceName: "setting_icon_language.png")
        case .VersionCheck:
            return #imageLiteral(resourceName: "setting_icon_patch.png")
        case .Currency:
            return #imageLiteral(resourceName: "setting_icon_money.png")
        case .ExportETHWallet:
            return #imageLiteral(resourceName: "iconContentEth.png")
        case .ExportBTCWallet:
            return #imageLiteral(resourceName: "iconFundsBitcoin")
        case .BackupAccount:
            return #imageLiteral(resourceName: "setting_icon_backup.png")
        case .DeleteAccount:
            return #imageLiteral(resourceName: "setting_icon_delete.png")
        }
    }
    var title:String {
        switch self {
        case .Notification:
            return LM.dls.settings_notification_title
        case .Address:
            return LM.dls.addressbook_title
        case .BackupAccount:
            return LM.dls.myIdentity_btn_backup_identity
        case .Currency:
            return LM.dls.settings_label_currencyUnit
        case .DeleteAccount:
            return LM.dls.setting_delete_account_title
        case .ExportBTCWallet:
            return LM.dls.setting_export_btc_wallet_title
        case .ExportETHWallet:
            return LM.dls.setting_export_eth_wallet_title
        case .Language:
            return LM.dls.settings_label_language
        case .VersionCheck:
            return LM.dls.me_label_check_update
        }
    }
}


struct SettingSectionModel: SectionModelType{
    
    var items: [SettingType]
    
    init(original: SettingSectionModel, items: [Item]) {
        self = original
        self.categoryTitle = original.categoryTitle
        self.items = items
    }
    
    typealias Item = SettingType
    
    var categoryTitle:String
    
    init(title: String, items: [Item]) {
        self.categoryTitle = title
        self.items = items
    }
    
}

class SettingMenuViewModel: KLRxViewModel {
    
    required init(input: Void, output: Void) {
        self.input = input
        self.output = output
        createSettingOptionsArray()
    }
    var input: Void
    var output: Void
    func concatInput() {
        
    }
    
    func concatOutput() {
        
    }
    typealias InputSource = Void
    typealias OutputSource = Void
    var bag: DisposeBag = DisposeBag.init()
    public lazy var settingsArray:Observable<[SettingSectionModel]> = {
        _settingsArray.asObservable()
    }()
    
    private lazy var _settingsArray : BehaviorRelay<[SettingSectionModel]> = BehaviorRelay.init(value: [])
    
    lazy var dataSource: RxTableViewSectionedReloadDataSource<SettingSectionModel> = {
        return RxTableViewSectionedReloadDataSource<SettingSectionModel>.init(configureCell: { (dataSource, tv, idxPath, settingType) -> UITableViewCell in
            switch settingType {
            case .ExportBTCWallet, .ExportETHWallet:
                let cell: ExportWalletSettingsTableViewCell = tv.dequeueReusableCell(withClass: ExportWalletSettingsTableViewCell.self)
                cell.config(setting:settingType)
                return cell
            default:
                let cell: SettingsTabTableViewCell = tv.dequeueReusableCell(withClass: SettingsTabTableViewCell.self)
                cell.config(setting:settingType)
                return cell
            }
        })
    }()
    

    
    func createSettingOptionsArray() {
        
        let _settingsArray = [SettingSectionModel.init(title: LM.dls.system_settings_title,
//                                                      items: [SettingType.Notification,
                                                      items: [
                                                              SettingType.Language,
                                                              SettingType.VersionCheck]),
                             SettingSectionModel.init(title: LM.dls.wallet_settings_title,
                                                      items: [SettingType.Address,
                                                              SettingType.Currency,
                                                              SettingType.ExportBTCWallet,
                                                              SettingType.ExportETHWallet]),
                             SettingSectionModel.init(title: LM.dls.account_safety_settings_title,
                                                      items: [SettingType.BackupAccount,
                                                              SettingType.DeleteAccount])
        ]
        self._settingsArray.accept(_settingsArray)
    }
    
}
