//
//  GroupInformationViewController.swift
//  OfflineWallet
//
//  Created by Archie on 2018/11/15.
//  Copyright © 2018 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

class GroupInformationViewController: UIViewController {
    @IBOutlet weak var spacingView1: UIView!
    @IBOutlet weak var spacingView2: UIView!
    @IBOutlet weak var groupCreateImageView: UIView!
    @IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet weak var privateButton: UIButton!
    @IBOutlet weak var publicButton: UIButton!
    @IBOutlet weak var managerButton: UIButton!
    @IBOutlet weak var membersButton: UIButton!
    @IBOutlet private weak var groupNameHintLabel: UILabel! {
        didSet {
            viewModel.output.nameCountHintString.bind(to: groupNameHintLabel.rx.text).disposed(by: disposeBag)
            viewModel.output.nameCountHintColor.bind(to: groupNameHintLabel.rx.textColor).disposed(by: disposeBag)
        }
    }
    @IBOutlet private weak var introduceHintLabel: UILabel! {
        didSet {
            viewModel.output.introductionCountHintColor.bind(to: introduceHintLabel.rx.textColor).disposed(by: disposeBag)
            viewModel.output.introductionCountHintString.bind(to: introduceHintLabel.rx.text).disposed(by: disposeBag)
        }
    }
    @IBOutlet weak var groupNameFirstLabel: UILabel! {
        didSet { viewModel.output.groupName.map({ $0?.first?.string }).bind(to: groupNameFirstLabel.rx.text).disposed(by: disposeBag) }
    }
    @IBOutlet weak var groupNameTextField: UITextField! {
        didSet {
            (groupNameTextField.rx.text <-> viewModel.output.groupName).disposed(by: disposeBag)
            viewModel.output.isEditable.bind(to: groupNameTextField.rx.isEnabled).disposed(by: disposeBag)
        }
    }
    @IBOutlet private weak var introductTextView: UITextView! {
        didSet {
            (introductTextView.rx.text <-> viewModel.output.introduction).disposed(by: disposeBag)
            viewModel.output.isEditable.bind(to: introductTextView.rx.isEditable).disposed(by: disposeBag)
        }
    }
    @IBOutlet private weak var placeholderLabel: UILabel! {
        didSet { viewModel.output.introduction.map({ !($0?.isEmpty ?? true) }).bind(to: placeholderLabel.rx.isHidden).disposed(by: disposeBag) }
    }
    @IBOutlet weak var bottomButton: UIButton! {
        didSet {
            bottomButton.rx.tap.subscribe(onNext: {
                [unowned self] in
                self.viewModel.output.groupImageString.accept(self.groupCreateImageView.asImage().base64EncodedString)
                self.viewModel.input.buttonTapSubject.onNext(())
            }).disposed(by: disposeBag)
        }
    }
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout! {
        didSet {
            collectionViewFlowLayout.itemSize = CGSize(width: UIScreen.main.bounds.size.width / 4, height: UIScreen.main.bounds.size.width / 4 - 18 * 2 + 18 + 6 + 12 + 12)
            collectionViewFlowLayout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.size.width, height: 30)
        }
    }
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet  {
            collectionView.register(cellType: GroupMemberCollectionViewCell.self)
            collectionView.register(reusableViewType: GroupCollectionReusableView.self)
            collectionView.rx.itemSelected.subscribe(onNext: {
                [unowned self] indexPath in
                switch self.viewModel.input.typeSubject.value {
                case .normal: break
                default:
                    var sections = self.viewModel.output.animatableSectionModel.value
                    var sectionModel = sections[indexPath.section]
                    if let targetUid = sectionModel.items[indexPath.row].input.groupMemberModel?.uid {
                        guard let uid = RocketChatManager.manager.rocketChatUser.value?.name else { return }
                        if targetUid != uid {
                            sectionModel.items.remove(at: indexPath.row)
                            sections.remove(at: indexPath.section)
                            sections.insert(sectionModel, at: indexPath.section)
                            self.viewModel.output.animatableSectionModel.accept(sections)
                        }
                    } else {
                        self.presentAddGroupMemberView()
                    }
                }
            }).disposed(by: disposeBag)
        }
    }
    
    private let viewModel: GroupInformationViewModel
    private let disposeBag = DisposeBag()
    private var addMembersDisposeBag = DisposeBag()
    
    private lazy var deleteGroupBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(title: "删除群组", style: .plain, target: self, action: nil)
        barButtonItem.rx.tap.subscribe(onNext: {
            [unowned self] in
            self.deleteGroup()
        }).disposed(by: disposeBag)
        barButtonItem.tintColor = UIColor.owPumpkinOrange
        return barButtonItem
    }()
    private lazy var cancelEditGroupBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(title: "取消编辑", style: .plain, target: self, action: nil)
        barButtonItem.rx.tap.subscribe(onNext: {
            [unowned self] in
            self.undoGroup()
        }).disposed(by: disposeBag)
        barButtonItem.tintColor = UIColor.owPumpkinOrange
        return barButtonItem
    }()
    
    init(viewModel: GroupInformationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: GroupInformationViewController.className, bundle: nil)
        viewModel.output.title.bind(to: rx.title).disposed(by: disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpRx()
    }
    
    private func setUpRx() {
        viewModel.output.isPostable.subscribe(onNext: {
            [unowned self] isPostable in
            self.managerButton.setImageForAllStates(isPostable ? #imageLiteral(resourceName: "radioButtonOff.png") : #imageLiteral(resourceName: "radioButtonOn.png"))
            self.membersButton.setImageForAllStates(isPostable ? #imageLiteral(resourceName: "radioButtonOn.png") : #imageLiteral(resourceName: "radioButtonOff.png"))
        }).disposed(by: disposeBag)
        viewModel.output.isPrivate.subscribe(onNext: {
            [unowned self] isPrivate in
            self.publicButton.setImage(isPrivate ? #imageLiteral(resourceName: "radioButtonOff.png") : #imageLiteral(resourceName: "radioButtonOn.png"), for: .normal)
            self.publicButton.setImage(isPrivate ? #imageLiteral(resourceName: "radioButtonOffDisable.png") : #imageLiteral(resourceName: "radioButtonOnDisable.png"), for: .disabled)
            self.privateButton.setImage(isPrivate ? #imageLiteral(resourceName: "radioButtonOn.png") : #imageLiteral(resourceName: "radioButtonOff.png"), for: .normal)
            self.privateButton.setImage(isPrivate ? #imageLiteral(resourceName: "radioButtonOnDisable.png") : #imageLiteral(resourceName: "radioButtonOffDisable.png"), for: .disabled)
        }).disposed(by: disposeBag)
        viewModel.input.typeSubject.subscribe(onNext: {
            [unowned self] type in
            self.publicButton.isHidden = type == .normal ? self.viewModel.output.isPrivate.value : true
            self.privateButton.isHidden = type == .normal ? !self.publicButton.isHidden : false
            self.managerButton.isHidden = type == .normal ? self.viewModel.output.isPostable.value : false
            self.membersButton.isHidden = type == .normal ? !self.managerButton.isHidden : false
            self.spacingView1.isHidden = type == .normal
            self.spacingView2.isHidden = type == .normal
            self.privateButton.isEnabled = type == .create
            self.publicButton.isEnabled = type == .create
            self.managerButton.isEnabled = type != .normal
            self.membersButton.isEnabled = type != .normal
            self.introduceHintLabel.isHidden = type == .normal
            self.groupNameHintLabel.isHidden = type == .normal
            if type == .normal {
                self.publicButton.setImage(nil, for: .disabled)
                self.privateButton.setImage(nil, for: .disabled)
                self.managerButton.setImage(nil, for: .disabled)
                self.membersButton.setImage(nil, for: .disabled)
                self.publicButton.setImage(nil, for: .normal)
                self.privateButton.setImage(nil, for: .normal)
                self.managerButton.setImage(nil, for: .normal)
                self.membersButton.setImage(nil, for: .normal)
            } else {
                self.viewModel.output.isPrivate.accept(self.viewModel.output.isPrivate.value)
                self.viewModel.output.isPostable.accept(self.viewModel.output.isPostable.value)
            }
            if self.viewModel.input.userGroupInfoModelSubject.value.groupOwnerUID == IMUserManager.manager.userModel.value?.uID {
                self.navigationItem.rightBarButtonItem = type == .edit ? self.cancelEditGroupBarButtonItem : self.deleteGroupBarButtonItem
            } else {
                self.navigationItem.rightBarButtonItem = nil
            }
        }).disposed(by: disposeBag)
        viewModel.output.animatableSectionModel.bind(to: collectionView.rx.items(dataSource: viewModel.output.dataSource)).disposed(by: disposeBag)
        viewModel.output.errorMessageSubject.subscribe(onNext: {
            [weak self] message in
            guard let `self` = self else { return }
            EZToast.present(on: self, content: message)
        }).disposed(by: disposeBag)
        viewModel.output.bottomButtonIsEnabled.subscribe(onNext: {
            [unowned self] isEnabled in
            self.bottomButton.isEnabled = isEnabled
            self.bottomButton.backgroundColor = isEnabled ? UIColor.owAzure : UIColor.owSilver
        }).disposed(by: disposeBag)
        viewModel.output.dismissSubject.subscribe(onCompleted: {
            [unowned self] in
            self.pop(sender: self)
        }).disposed(by: disposeBag)
        viewModel.output.popToRootSubject.subscribe(onCompleted: {
            [unowned self] in
            self.popToRoot(sender: self)
        }).disposed(by: disposeBag)
        viewModel.output.buttonType.subscribe(onNext: {
            [unowned self] type in
            switch type {
            case .confirm, .create: self.bottomButton.setTitleForAllStates(LM.dls.g_ok)
            case .leave: self.bottomButton.setTitleForAllStates("退出群組")
            case .edit: self.bottomButton.setTitleForAllStates("管理群組")
            }
            self.bottomButton.backgroundColor = type == .leave ? UIColor.owPumpkinOrange : UIColor.owIceCold
        }).disposed(by: disposeBag)
        viewModel.output.leaveGroupActionSubject.subscribe(onNext: {
            [unowned self] action in
            let alertController = UIAlertController(title: "确认退出群组？", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: LM.dls.g_confirm, style: .default, handler: { (_) in
                action()
            })
            let cancelAction = UIAlertAction(title: LM.dls.g_cancel, style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }).disposed(by: disposeBag)
    }
    
    private func presentAddGroupMemberView() {
        let viewModel = SearchMemberViewModel()
        let viewController = SearchMemberViewController(viewModel: viewModel)
        viewModel.output.selectedFriends.subscribe(onNext: {
            [unowned self] models in
            viewController.pop(sender: self)
            self.viewModel.input.addMembersSubject.onNext(models)
            self.addMembersDisposeBag = DisposeBag()
        }).disposed(by: addMembersDisposeBag)
        show(viewController, sender: self)
    }
    
    private func deleteGroup() {
        showAlert(title: "确认解散删除群组？", message: nil, buttonTitles: [LM.dls.g_cancel, LM.dls.g_confirm]) { [unowned self] (index) in
            if index == 1 {
                Server.instance.deleteGroup(parameters: DeleteGroupAPI.Parameters.init(userGroupInfoModel: self.viewModel.input.userGroupInfoModelSubject.value)).asObservable().subscribe(onNext: {
                    [weak self] result in
                    switch result {
                    case .success: self?.popToRoot(sender: self)
                    case .failed(error: let error):
                        guard let `self` = self else { return }
                        EZToast.present(on: self, content: error.localizedDescription)
                    }
                }).disposed(by: self.disposeBag)
            }
        }
    }
    
    private func undoGroup() {
        showAlert(title: "确认取消编辑？", message: nil, buttonTitles: [LM.dls.g_cancel, LM.dls.g_confirm]) { [unowned self] (index) in
            if index == 1 {
                self.viewModel.input.typeSubject.accept(.normal)
                self.viewModel.input.userGroupInfoModelSubject.accept(self.viewModel.input.userGroupInfoModelSubject.value)
            }
        }
    }
    
    @IBAction func clickGroupTypeButton(_ sender: UIButton) {
        switch viewModel.input.typeSubject.value {
        case .create: viewModel.output.isPrivate.accept(sender == privateButton)
        case .edit, .normal: return
        }
    }
    
    @IBAction func clickPostTypeButton(_ sender: UIButton) {
        switch viewModel.input.typeSubject.value {
        case .edit, .create:
            viewModel.output.isPostable.accept(sender == membersButton)
        case .normal: return
        }
    }
}
