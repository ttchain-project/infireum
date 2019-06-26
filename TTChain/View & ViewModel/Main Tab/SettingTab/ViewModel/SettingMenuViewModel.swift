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

class SettingMenuViewModel: KLRxViewModel {
    
    required init(input: Void, output: Void) {
        self.input = input
        self.output = output
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
}
