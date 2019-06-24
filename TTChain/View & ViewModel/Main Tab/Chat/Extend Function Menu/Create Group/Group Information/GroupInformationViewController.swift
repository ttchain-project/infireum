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
    @IBOutlet weak var groupTypeStackView: UIStackView!
    @IBOutlet weak var spacingView1: UIView!
    @IBOutlet weak var spacingView2: UIView!
    @IBOutlet weak var groupCreateImageView: UIView!
    @IBOutlet weak var groupImageView: UIImageView! {
        didSet {
            self.viewModel.output.groupImage.bind(to: groupImageView.rx.image).disposed(by: disposeBag)
        }
    }
    @IBOutlet weak var privateButton: UIButton! {
        didSet {
            self.privateButton.setTitle(LM.dls.private_group, for: .normal)
        }
    }
    @IBOutlet weak var publicButton: UIButton! {
        didSet {
            self.publicButton.setTitle(LM.dls.public_group, for: .normal)
        }
    }
    
    @IBOutlet weak var postMessageLabel: UILabel! {
        didSet {
            postMessageLabel.text = LM.dls.post_message
        }
    }
    
    @IBOutlet weak var managerButton: UIButton! {
        didSet {
            self.managerButton.setTitle(LM.dls.admin_only, for: .normal)
        }
    }
    @IBOutlet weak var membersButton: UIButton! {
        didSet {
            self.membersButton.setTitle(LM.dls.all_members, for: .normal)
        }
    }
    @IBOutlet weak var groupIconButton: UIButton! {
        didSet {
            
            viewModel.output.isEditable.map { !$0 }.bind(to: groupIconButton.rx.isHidden).disposed(by: disposeBag)
            groupIconButton.rx.tap.subscribe(onNext: {
                [unowned self] in
                self.showImgSourceActionSheet()
            }).disposed(by: disposeBag)
        }
    }
    
    @IBOutlet private weak var groupNameHintLabel: UILabel! {
        didSet {
            viewModel.output.nameCountHintString.bind(to: groupNameHintLabel.rx.text).disposed(by: disposeBag)
            viewModel.output.nameCountHintColor.bind(to: groupNameHintLabel.rx.textColor).disposed(by: disposeBag)
        }
    }
    
    @IBOutlet weak var groupTypeTitleLabel: UILabel! {
        didSet {
            self.groupTypeTitleLabel.text = LM.dls.group
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
            groupNameTextField.placeholder = LM.dls.group_name
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
        didSet { viewModel.output.introduction.map({ !($0?.isEmpty ?? true) }).bind(to: placeholderLabel.rx.isHidden).disposed(by: disposeBag)
            placeholderLabel.text = LM.dls.group_description
        }
    }
    
    @IBOutlet weak var bottomButton: UIButton! {
        didSet {
            bottomButton.rx.tap.subscribe(onNext: {
                [unowned self] in
                if self.viewModel.output.groupImage.value != nil {
                    self.viewModel.output.groupImage.accept(self.groupImageView.image)
                }else {
                    self.viewModel.output.groupImage.accept(self.groupCreateImageView.asImage())
                }
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
                case .normal:
                    var model : FriendModel
                    if indexPath.section == 0 {
                        model = self.viewModel.input.userGroupInfoModelSubject.value.membersArray![indexPath.row]
                    }else {
                        model = self.viewModel.input.userGroupInfoModelSubject.value.invitedMembersArray![indexPath.row]
                    }
                    if model.uid == IMUserManager.manager.userModel.value?.uID {
                        self.toProfileVC()
                    }else {
                        self.toUserProfileVC(forFriend: model)
                    }

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
    
    private lazy var hud = {
        return KLHUD.init(
            type: .spinner,
            frame: CGRect.init(
                origin: .zero,
                size: .init(width: 100, height: 100)
            )
        )
    }()
    
    
    fileprivate var imagePicker: UIImagePickerController!

    private let viewModel: GroupInformationViewModel
    private let disposeBag = DisposeBag()
    private var addMembersDisposeBag = DisposeBag()
    
    private lazy var deleteGroupBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(title: LM.dls.delete_group, style: .plain, target: self, action: nil)
        barButtonItem.rx.tap.subscribe(onNext: {
            [unowned self] in
            self.deleteGroup()
        }).disposed(by: disposeBag)
        barButtonItem.tintColor = UIColor.owPumpkinOrange
        return barButtonItem
    }()
    private lazy var cancelEditGroupBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(title: LM.dls.g_cancel, style: .plain, target: self, action: nil)
        barButtonItem.rx.tap.subscribe(onNext: {
            [unowned self] in
            self.undoGroup()
        }).disposed(by: disposeBag)
        barButtonItem.tintColor = UIColor.owPumpkinOrange
        return barButtonItem
    }()
    
    private lazy var inviteUsersBarButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(title: LM.dls.group_member_invited, style: .plain, target: self, action: nil)
        barButtonItem.rx.tap.subscribe(onNext: {
            [unowned self] in
            self.presentAddGroupMemberView()
        }).disposed(by: disposeBag)
        barButtonItem.tintColor = UIColor.owPumpkinOrange
        return barButtonItem
    }()
    
    var didUpdateProfileImage:Bool = false
    
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
        //Hiding the public private groupselection view
        let palette = TM.palette
        renderNavBar(tint: palette.nav_item_2, barTint: palette.nav_bar_tint)
        changeLeftBarButtonToDismissToRoot(tintColor: .white,image:#imageLiteral(resourceName: "btn_previous_light"))
        self.groupTypeStackView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    private func setUpRx() {
        
        viewModel.output.animateHUDSubject.subscribe(onNext: { [weak self] status in
            if status {
                self?.hud.startAnimating(inView: self?.view)
            }else {
                self?.hud.stopAnimating()
            }
        }).disposed(by:disposeBag)
        
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
            } else if type == .normal {
                 self.navigationItem.rightBarButtonItem = self.inviteUsersBarButton
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
            case .leave: self.bottomButton.setTitleForAllStates(LM.dls.exit_group)
            case .edit: self.bottomButton.setTitleForAllStates(LM.dls.manage_group)
            }
            self.bottomButton.backgroundColor = type == .leave ? UIColor.owPumpkinOrange : TM.palette.btn_bgFill_enable_bg
        }).disposed(by: disposeBag)
        
        viewModel.output.leaveGroupActionSubject.subscribe(onNext: {
            [unowned self] action in
            let alertController = UIAlertController(title: LM.dls.confirm_exit, message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: LM.dls.g_confirm, style: .default, handler: { (_) in
                action()
            })
            let cancelAction = UIAlertAction(title: LM.dls.g_cancel, style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
        viewModel.groupMembersInvitedSuccessfully.subscribe(onNext: { (_) in
            self.showSimplePopUp(with: "", contents: LM.dls.members_invitation_successfull, cancelTitle: LM.dls.g_cancel, cancelHandler: nil)
        }).disposed(by: disposeBag)
    }
    
    private func presentAddGroupMemberView() {
        let viewModel = SearchMemberViewModel()
        let viewController = SearchMemberViewController(viewModel: viewModel)
        viewModel.output.selectedFriends.subscribe(onNext: {
            [unowned self] models in
            viewController.pop(sender: self)
            self.viewModel.input.addMembersSubject.onNext(models)
            if self.viewModel.input.userGroupInfoModelSubject.value.groupOwnerUID != IMUserManager.manager.userModel.value?.uID  {
                self.viewModel.addMembersToGroup(friendModels: models)
            }
            self.addMembersDisposeBag = DisposeBag()
        }).disposed(by: addMembersDisposeBag)
        show(viewController, sender: self)
    }
    
    private func deleteGroup() {
        showAlert(title: LM.dls.confirm_delete_group, message: nil, buttonTitles: [LM.dls.g_cancel, LM.dls.g_confirm]) { [unowned self] (index) in
            if index == 1 {
                Server.instance.deleteGroup(parameters: DeleteGroupAPI.Parameters.init(userGroupInfoModel: self.viewModel.input.userGroupInfoModelSubject.value)).asObservable().subscribe(onNext: {
                    [weak self] result in
                    switch result {
                    case .success: self?.popToRoot(sender: self)
                    case .failed(error: let error):
                        guard let `self` = self else { return }
                        EZToast.present(on: self, content: error.descString)
                    }
                }).disposed(by: self.disposeBag)
            }
        }
    }
    
    private func undoGroup() {
        showAlert(title: LM.dls.confirm_cancel_editing, message: nil, buttonTitles: [LM.dls.g_cancel, LM.dls.g_confirm]) { [unowned self] (index) in
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
    
    func toUserProfileVC(forFriend friend: FriendModel) {
        
        var purpose : UserProfileViewController.Purpose
        if friend is GroupMemberModel {
            let friends = friend as! GroupMemberModel
            purpose = friends.isFriend! ? .myFriend : .notMyFriend
        }else {
            purpose = .myFriend
        }
       
        let config = UserProfileViewController.Config.init(purpose: purpose, user: friend)
        let viewController = UserProfileViewController.instance(from: config)
        self.show(viewController, sender: nil)
    }
    func toProfileVC() {
        let viewController = ProfileViewController.instance()
        self.show(viewController, sender: nil)
    }
}


extension GroupInformationViewController {
    
    fileprivate func displayCamera() {
        guard PhotoAuthHandler.hasAuthedCamera else {
            return
        }
        
        imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .camera
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    fileprivate func displayImageSource() {
        guard PhotoAuthHandler.hasAuthedPhotoLibrary else {
            return
        }
        
        imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    fileprivate func showImgSourceActionSheet() {
        let actionSheet = UIAlertController.init(title: "", message: nil, preferredStyle: .actionSheet)
        
        let camera = UIAlertAction.init(title: LM.dls.select_from_camera, style: .default) { (_) in
            self.displayCamera()
        }
        
        let gallery = UIAlertAction.init(title: LM.dls.select_from_gallery, style: .default) { (_) in
            self.displayImageSource()
        }
        
        let cancel = UIAlertAction.init(title: LM.dls.g_cancel, style: .cancel, handler: nil)
        
        actionSheet.addAction(camera)
        actionSheet.addAction(gallery)
        actionSheet.addAction(cancel)
        
        present(actionSheet, animated: true, completion: nil)
    }
}

extension GroupInformationViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let resizedImg = image.scaleImage(toSize: targetSize(for: image))!
            self.didUpdateProfileImage = true
            self.viewModel.output.groupImage.accept(resizedImg)
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    fileprivate func targetSize(for originImg:UIImage) -> CGSize {
        let originSize = originImg.size
        enum Longer {
            case w
            case h
        }
        
        var targetSize: CGSize = .zero
        let longer : Longer = (originSize.width >= originSize.height) ? .w : .h
        switch longer {
        case .w:
            targetSize.width = min(originSize.width, 480)
            let compressRatio = targetSize.width / originSize.width
            targetSize.height = originSize.height * compressRatio
        case .h:
            targetSize.height = min(originSize.height, 480)
            let compressRatio = targetSize.height / originSize.height
            targetSize.width = originSize.width * compressRatio
        }
        
        return targetSize
    }
}
