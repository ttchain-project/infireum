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
    
    var image: UIImage? {
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
            return nil
        case .ExportBTCWallet:
            return nil
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
            return LM.dls.setting_export_key_title + LM.dls.setting_export_btc_wallet_title
        case .ExportETHWallet:
            return LM.dls.setting_export_key_title + LM.dls.setting_export_eth_wallet_title
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
        self.categoryTitle = ""
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
    var settingsArray : [SettingSectionModel] = []
    
    lazy var datasource: RxCollectionViewSectionedReloadDataSource<MarketTestSectionModel> = {
        let source = RxCollectionViewSectionedReloadDataSource<MarketTestSectionModel>.init(configureCell: { (source, cv, idxPath, settingModel) -> SettingMenuCollectionViewCell in
            let cell = cv.dequeueReusableCell(withReuseIdentifier: SettingMenuCollectionViewCell.cellIdentifier(), for: idxPath) as! SettingMenuCollectionViewCell
            cell.setupCell(model:settingModel)
            return cell
        }, configureSupplementaryView: { (datasource, cv, kind, indexpath) in
            if (kind == UICollectionElementKindSectionHeader) {
                let headerView = cv.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SettingMenuHeaderCollectionReusableView.className, for: indexpath) as!  SettingMenuHeaderCollectionReusableView
                
                let titleString : String = {
                    switch indexpath.section {
                    case 0:  return LM.dls.account_setting_title
                    case 1:  return LM.dls.basic_setting_title
                    case 2:  return LM.dls.follow_us_title
                    case 3:  return LM.dls.others_title
                    default:
                        return ""
                    }
                    
                }()
                headerView.setup(title: titleString)
                return headerView
            }
            return UICollectionReusableView()
        })
        return source
    }()
    
    func createSettingOptionsArray() {
        
        self.settingsArray = [SettingSectionModel.init(title: LM.dls.system_settings_title,
                                                      items: [SettingType.Notification,
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
    }
    
}
