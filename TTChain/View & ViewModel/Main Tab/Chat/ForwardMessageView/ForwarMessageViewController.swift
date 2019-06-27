//
//  ForwarMessageViewController.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/3/29.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources


import ObjectiveC

extension MessageModel {
    
    private struct AssociatedKeys {
        static var kIsSelected = "kIsSelected"
    }
    private var isSelected: Bool? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.kIsSelected) as? Bool
        }set {
            objc_setAssociatedObject(self, &AssociatedKeys.kIsSelected, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var isMessageSelected :Bool {
        get {
            return self.isSelected ?? false
        }
        set {
            self.isSelected = newValue
        }
    }
}


final class ForwarMessageViewController: KLModuleViewController, KLVMVC {
    
    var viewModel: ForwarMessageViewModel!
    
    typealias ResultCallback = (ChatListPage,[MessageModel]) -> Void
    var onForwardMessagesSelection: ResultCallback?
    
    typealias ViewModel = ForwarMessageViewModel
    
    func config(constructor: ForwarMessageViewController.Config) {
        self.view.layoutIfNeeded()
        self.navigationItem.title = LM.dls.forward_message_title_string
        self.viewModel = ForwarMessageViewModel.init(input: ForwarMessageViewModel.InputSource.init(messages: constructor.messages, roomId: constructor.roomId, avatarImage: constructor.avatarImage,memberAvatarMapping:constructor.memberAvatarMapping), output: ForwarMessageViewModel.OutputSource())
        self.onForwardMessagesSelection = constructor.forwardMessagesSelected
        self.initTableView()
        self.bindViewModel()
        self.confirmButton.backgroundColor = TM.palette.btn_bgFill_enable_bg
        self.confirmButton.setTitle(LM.dls.g_confirm, for: .normal)
        self.confirmButton.rx.tap.asDriver().drive(onNext: { () in
            let vc = ForwardListContainerViewController.init()
            vc.config(constructor: ForwardListContainerViewController.Config(messageModel: self.viewModel.input.messages[0]))
            self.navigationController?.pushViewController(vc)
            vc.onForwardChatToSelection.asObservable().subscribe(onNext: { [unowned self] (model) in
                let selectedMessages = self.viewModel.input.messages.filter { $0.isMessageSelected == true }
                self.onForwardMessagesSelection!(model,selectedMessages)
                self.dismiss(animated: false, completion: nil)
            }).disposed(by: vc.bag)
        }).disposed(by: bag)
        
        renderNavBar(tint: .white, barTint: TM.palette.nav_bar_tint)
        renderNavTitle(color: .white, font: .owMedium(size: 18))
        self.changeLeftBarButtonToDismissToRoot(tintColor: .black, image: #imageLiteral(resourceName: "arrowNavBlack"))
    }
    
    var bag: DisposeBag = DisposeBag.init()
    typealias Constructor = Config
    struct Config {
        let messages:[MessageModel]
        let roomId:String
        let avatarImage:String?
        var memberAvatarMapping: [String:String?]? = nil
        let forwardMessagesSelected: ResultCallback
    }
    
    @IBOutlet weak var tableView: UITableView!
  
    @IBOutlet weak var confirmButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func initTableView() {
        tableView.register(ChatMessageTableViewCell.nib, forCellReuseIdentifier: ChatMessageTableViewCell.nameOfClass)
        tableView.register(ChatMessageImageTableViewCell.nib, forCellReuseIdentifier: ChatMessageImageTableViewCell.nameOfClass)
        tableView.register(ReceiptTableViewCell.nib, forCellReuseIdentifier: ReceiptTableViewCell.nameOfClass)
        tableView.register(RedEnvTableViewCell.nib, forCellReuseIdentifier: RedEnvTableViewCell.nameOfClass)
        tableView.register(RceiveRedEnvelopeTableViewCell.nib, forCellReuseIdentifier: RceiveRedEnvelopeTableViewCell.nameOfClass)
        tableView.register(UnknownFileTableViewCell.nib, forCellReuseIdentifier: UnknownFileTableViewCell.nameOfClass)
    }
    
    func bindViewModel() {
        viewModel.messages.distinctUntilChanged().bind(to: tableView.rx.items) {
            [unowned self]
            tv,row,messageModel in
            
            var cell: UITableViewCell
            var leftImage: String?
            
            if let mapping = self.viewModel.input.memberAvatarMapping {
                leftImage = mapping[messageModel.userName ?? ""] ?? ""
            }else {
                leftImage = self.viewModel.input.avatarImage ?? ""
            }
            switch messageModel.msgType {
            case .general,.audioCall(_),.urlMessage:
                let chatCell = tv.dequeueReusableCell(withIdentifier: ChatMessageTableViewCell.cellIdentifier(), for: IndexPath.init(item: row, section: 0)) as! ChatMessageTableViewCell
                
                chatCell.setDataForForwarSelection(message: messageModel, leftImage: leftImage, messageSelected: { (model) in
                    model.isMessageSelected = !model.isMessageSelected
                })
                
                cell = chatCell
                
            case .image:
                let chatImgCell = tv.dequeueReusableCell(withIdentifier: ChatMessageImageTableViewCell.cellIdentifier(), for: IndexPath.init(item: row, section: 0)) as! ChatMessageImageTableViewCell
                
                chatImgCell.setDataForForwarSelection(message: messageModel, leftImage: leftImage, messageSelected: { (model) in
                    
                    model.isMessageSelected = !model.isMessageSelected
                })
                
                cell = chatImgCell
            case .voiceMessage:
                let voiceMessageCell = tv.dequeueReusableCell(withIdentifier: ChatMessageImageTableViewCell.cellIdentifier(), for: IndexPath.init(item: row, section: 0)) as! ChatMessageImageTableViewCell
                
                voiceMessageCell.setDataForForwarSelection(message: messageModel, leftImage: leftImage, messageSelected: { (model) in
                    model.isMessageSelected = !model.isMessageSelected
                })
                
                cell = voiceMessageCell
            case .receipt :
                let receiptCell = tv.dequeueReusableCell(withIdentifier: ReceiptTableViewCell.cellIdentifier(), for: IndexPath.init(item: row, section: 0)) as! ReceiptTableViewCell
                
                receiptCell.setMessage(forMessage: messageModel, leftImage: leftImage, leftImageAction: {_ in ()})
                
                cell = receiptCell
            case .createRedEnvelope:
                let redEnvCell = tv.dequeueReusableCell(withIdentifier: RedEnvTableViewCell.cellIdentifier(), for: IndexPath.init(item: row, section: 0)) as! RedEnvTableViewCell
                
                redEnvCell.setMessage(forMessage: messageModel, leftImage: leftImage, leftImageAction: {_ in ()})
                
                cell = redEnvCell
            case .receiveRedEnvelope:
                let rcvRedEnvCell = tv.dequeueReusableCell(withIdentifier: RceiveRedEnvelopeTableViewCell.cellIdentifier(), for: IndexPath.init(item: row, section: 0)) as! RceiveRedEnvelopeTableViewCell
                rcvRedEnvCell.config(message: messageModel)
                
                cell = rcvRedEnvCell
           
            case .file :
                let unknownFileCell = tv.dequeueReusableCell(withIdentifier: UnknownFileTableViewCell.cellIdentifier(), for: IndexPath.init(item: row, section: 0)) as! UnknownFileTableViewCell
                unknownFileCell.setDataForForwarSelection(message: messageModel, leftImage: leftImage, messageSelected: { (model) in
                    model.isMessageSelected = !model.isMessageSelected
                })
            
                cell = unknownFileCell
            }
            return cell
            }.disposed(by: bag)
        
        self.tableView.scrollToLastRow()

    }
    
}
