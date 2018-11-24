//
//  ChatAddressBook2ViewController.swift
//  OfflineWallet
//
//  Created by Song-Hua on 2018/10/23.
//  Copyright © 2018 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class ChatExtendFunctionMenuViewController: KLModuleViewController, KLVMVC {
    
    @IBOutlet weak var tableView: UITableView!
    
    let items: [ChatExtensionFunctions] = [
        ChatExtensionFunctions.init(title: "", items:
            [
//                ChatExtensionFunctions.Item.init(image: UIImage(named: "iconSweepQrcode")!, title: LM.dls.chat_extend_item_sweep_qrcode),
                ChatExtensionFunctions.Item.init(image: UIImage(named: "iconAddChannel")!, title: LM.dls.chat_extend_item_add_channel),
                ChatExtensionFunctions.Item.init(image: UIImage(named: "iconAddFriends")!, title: LM.dls.chat_extend_item_add_friends),
//                ChatExtensionFunctions.Item.init(image: UIImage(named: "iconSearchGroup")!, title: LM.dls.chat_extend_item_search_group),
//                ChatExtensionFunctions.Item.init(image: UIImage(named: "iconSocialEnvelope")!, title: LM.dls.chat_extend_item_social_envelope),
                ChatExtensionFunctions.Item.init(image: UIImage(named: "iconUserInformation")!, title: LM.dls.chat_extend_item_user_information)
            ])
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        initTableView()
        
    }
    
    func initTableView() {
        
        tableView.register(UINib.init(nibName: "ExtendFunctionTableViewCell", bundle: nil), forCellReuseIdentifier: "ExtendFunctionTableViewCell")
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.isScrollEnabled = false
        
        let dataSource: RxTableViewSectionedReloadDataSource<ChatExtensionFunctions> = {
            let source = RxTableViewSectionedReloadDataSource<ChatExtensionFunctions>.init(configureCell: { (friends, tableView, indexPath, friend) -> UITableViewCell in
                return UITableViewCell()
            })
            
            return source
        }()
        
        
        dataSource.configureCell = { (_, tableView, indexPath, viewModel) in            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ExtendFunctionTableViewCell") as! ExtendFunctionTableViewCell
            cell.viewModel = viewModel
            cell.backgroundColor = .clear
            return cell
        }
        
        
        // Bind data to UITableView
        Observable.just(items).bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: bag)
    }
    
    
    typealias Constructor = Void
    var viewModel: DepositViewModel!
    var bag: DisposeBag = DisposeBag()
    
    
    func config(constructor: Void) {
        
    }
    
}

extension ChatExtendFunctionMenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 33
    }
}
