//
//  CreateNewGroupViewController.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/7/4.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
final class CreateNewGroupViewController: KLModuleViewController, KLVMVC {

    
    var bag: DisposeBag = DisposeBag()
    typealias Constructor = Config
    struct Config {
        enum GroupAction {
            case Create
            case Normal
            case Edit
        }
        var groupAction:GroupAction
        var groupModel:UserGroupInfoModel?
    }
    
    typealias ViewModel = CreateNewGroupViewModel
    var viewModel: CreateNewGroupViewModel!
    func config(constructor: CreateNewGroupViewController.Config) {
        self.view.layoutIfNeeded()
        self.viewModel = CreateNewGroupViewModel.init(input: CreateNewGroupViewModel.InputSource(groupModel: constructor.groupModel), output: CreateNewGroupViewModel.OutputSource())
        self.state = constructor.groupAction

        setupUIForEdit()
        self.renderNavBar(tint: TM.palette.nav_bg_1, barTint: TM.palette.nav_bar_tint)
        renderNavTitle(color: TM.palette.nav_bg_1, font: .owRegular(size:16))
        changeLeftBarButton(target: self, selector: #selector(navBarBackTapped), tintColor: .white, image: #imageLiteral(resourceName: "btn_previous_light"))
        self.viewModel.groupModel.accept(constructor.groupModel)
        bindUI()
        self.view.backgroundColor = TM.palette.bgView_main
        self.title = LM.dls.group_info_title
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    private lazy var optionsBarButton: UIBarButtonItem = {
        let barButtonButton = UIBarButtonItem(image: #imageLiteral(resourceName: "options_icon"), style: .plain, target: self, action: nil)
        barButtonButton.rx.tap.subscribe(onNext: {
            [unowned self] in
            self.showOptionActions()
        }).disposed(by: bag)
        return barButtonButton
    }()

    public var didUpdateGroupInfo : ((UserGroupInfoModel?) -> (Void))?
    
    var imagePicker: UIImagePickerController!

    var state: Config.GroupAction = .Normal
    
    @IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet weak var groupIconButton: UIButton! {
        didSet {
            groupIconButton.isHidden = true
            groupIconButton.rx.tap.subscribe(onNext: {
                [unowned self] in
                self.showImgSourceActionSheet()
            }).disposed(by: bag)
        }
    }
    
    @IBOutlet weak var groupNameTextField: UITextField! {
        didSet {
            groupNameTextField.placeholder = LM.dls.group_name
            groupNameTextField.set(textColor: TM.palette.input_text, font: .owRegular(size: 14), placeHolderColor: TM.palette.input_placeholder)
        }
    }
    @IBOutlet weak var imageViewLabel: UILabel!
    @IBOutlet weak var infoTextView: UITextView! {
        didSet {
            infoTextView.font = .owRegular(size: 14)
            infoTextView.textColor = TM.palette.input_text
        }
    }
    
    @IBOutlet weak var placeholderLabel: UILabel! {
        didSet {
            placeholderLabel.text = LM.dls.group_description
            placeholderLabel.set(textColor: TM.palette.input_placeholder, font: .owRegular(size: 12))
        }
    }
    
    @IBOutlet weak var nextButton: UIButton! {
        didSet {
            nextButton.setTitleForAllStates(LM.dls.g_confirm)
        }
    }
    @IBOutlet weak var backButton: UIButton! {
        didSet {
            backButton.setTitleForAllStates(LM.dls.g_cancel)
        }
    }
    
    @IBOutlet weak var infoTitleLabel: UILabel! {
        didSet {
            infoTitleLabel.text = LM.dls.group_info_label_title_string
            infoTitleLabel.set(textColor: TM.palette.bg_fill_new, font: .owRegular(size: 12))
        }
    }
    
    @IBOutlet weak var settingsView: UIView!
    
    @IBOutlet weak var settingsTitleLabel: UILabel! {
        didSet {
            settingsTitleLabel.text = LM.dls.group_setting_title
            settingsTitleLabel.set(textColor: TM.palette.bg_fill_new, font: .owRegular(size: 12))
        }
    }
    @IBOutlet weak var manageMembersLabel: UILabel! {
        didSet {
            manageMembersLabel.set(textColor: TM.palette.label_main_1, font: .owRegular(size: 14))
            manageMembersLabel.text = LM.dls.group_member_mgmgt_title
        }
    }
    @IBOutlet weak var manageMembersView: UIView!
    @IBOutlet weak var editGroupInfoButton: UIButton! {
        didSet {
            editGroupInfoButton.isHidden = true
        }
    }
    @IBOutlet weak var editGroupNameBtn: UIButton! {
        didSet {
            editGroupNameBtn.isHidden = true
        }
    }
    @IBOutlet weak var groupNotificationButton: UIButton! {
        didSet {
            groupNotificationButton.setTitleForAllStates(LM.dls.chat_notifications_turn_off_title)
            groupNotificationButton.set(textColor: TM.palette.label_main_1, font: .owRegular(size:14))
            
        }
    }
    @IBOutlet weak var bottomButtonView: UIView!
    @IBOutlet weak var manageCommunityView: UIView!
    @IBOutlet weak var manageCommunityLabel: UILabel! {
        didSet {
            manageCommunityLabel.set(textColor: TM.palette.label_main_1, font: .owRegular(size: 14))
            manageCommunityLabel.text = LM.dls.chat_community_mgmt_label
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
    
    
    func bindUI() {
        (groupNameTextField.rx.text <-> viewModel.groupName).disposed(by: bag)
        (infoTextView.rx.text <-> viewModel.groupInfo).disposed(by: bag)
       
        viewModel.groupInfo.map({ !($0?.isEmpty ?? true) })
            .bind(to: placeholderLabel.rx.isHidden)
            .disposed(by: bag)
        self.groupNameTextField.rx.controlEvent(UIControlEvents.editingDidEnd).map { self.state == .Create }.subscribe (onNext: { status in
            self.groupNameTextField.isEnabled = status
        }).disposed(by: bag)
        
        
        self.infoTextView.rx.didEndEditing.map { self.state == .Create }.subscribe(onNext: { status in
            self.infoTextView.isEditable = status
        }).disposed(by: bag)
        
        self.viewModel.output.bottomButtonIsEnabled
            .bind(to:self.nextButton.rx.isEnabled)
            .disposed(by:bag)
        
        self.viewModel.output.groupImage
            .bind(to:self.groupImageView.rx.image)
            .disposed(by: bag)
        
        self.viewModel.groupName.map { $0?.firstCharacterAsString ?? "" }.bind(to: self.imageViewLabel.rx.text).disposed(by: bag)
        
        self.backButton.rx.klrx_tap.drive(onNext:{
            self.dismiss(animated: true, completion: nil)
        }).disposed(by: bag)
        
        self.nextButton.rx.klrx_tap.drive(onNext:{
            self.viewModel.createGroup()
        }).disposed(by: bag)

        self.viewModel.getRoomNotificationStatus().map {
            self.viewModel.notificaitonStatus.accept($0)
            self.groupNotificationButton.rx.tap.scan(self.viewModel.notificaitonStatus.value){ state, _ in
                self.viewModel.shouldChangeMessageNotification = true
                self.groupNotificationButton.isSelected = !self.groupNotificationButton.isSelected
                return state
                }.bind(to: self.viewModel.notificaitonStatus).disposed(by: self.bag)
            return $0
            }.bind(to: self.groupNotificationButton.rx.isSelected).disposed(by: bag)
        
        
        self.manageCommunityView.rx.klrx_tap.drive(onNext:{
            let vc = CommunityManagementViewController.instance(from: CommunityManagementViewController.Config(postMsgStatus: self.viewModel.groupModel.value?.isPostMsg ?? true, didUpdatePostStatus:{ status in
                self.viewModel.groupModel.value?.isPostMsg = status
                self.viewModel.shouldUpdateGroup.accept(true)
            }))
            self.navigationController?.pushViewController(vc)
        }).disposed(by: bag)
        
        self.viewModel.output.groupCreationComplete.subscribe(onNext:{ groupId in
            var fetchGroupBag = DisposeBag()
            self.viewModel.fetchGroupInfoFromServer(for: groupId).subscribe({ _ in
                self.state = .Edit
                self.setupUIForEdit()
                fetchGroupBag = DisposeBag()
            }).disposed(by: fetchGroupBag)
        }).disposed(by: bag)
        
        self.viewModel.output.animateHUDSubject.asObservable().subscribe(onNext: { (status) in
            if status {
                self.hud.startAnimating(inView:self.view)
            }else {
                self.hud.stopAnimating()
            }
        }).disposed(by: bag)
        
        self.viewModel.output.errorMessageSubject.asObservable()
            .bind(to:self.rx.message)
            .disposed(by:bag)
        
        self.viewModel.output.exitGroupCompleted.asObservable().subscribe(onNext: { _ in
            self.dismiss(animated: true, completion: nil)
        }).disposed(by: bag)
        
    }
    
    func setupUIForEdit() {
        self.groupNameTextField.isEnabled = false
        self.infoTextView.isEditable = false
        self.manageCommunityView.isHidden = true
        switch  self.state {
        case .Create:
            self.settingsView.isHidden = true
            self.editGroupInfoButton.isHidden = true
            self.groupIconButton.isHidden = false
            self.groupNameTextField.isEnabled = true
            self.infoTextView.isEditable = true
        case .Edit:
            self.addEditButtons()
            self.manageCommunityView.isHidden = false
            fallthrough
        case .Normal:
            self.navigationItem.rightBarButtonItem = self.optionsBarButton
            self.settingsView.isHidden = false
            self.manageMembersView.rx.klrx_tap.drive(onNext:{ _ in
                let vc = GroupMembersViewController.instance(from: GroupMembersViewController.Config(groupInfo: self.viewModel.groupModel.value!))
                self.navigationController?.pushViewController(vc)
            }).disposed(by: bag)
            bottomButtonView.isHidden = true
            
        }
    }
    
    private func addEditButtons() {
        editGroupNameBtn.isHidden = false
        self.groupIconButton.isHidden = false
        self.editGroupInfoButton.isHidden = false

        editGroupNameBtn.rx.klrx_tap.drive(onNext:{ _ in
            self.groupNameTextField.isEnabled = true
            self.groupNameTextField.becomeFirstResponder()
        }).disposed(by: bag)
        
        self.editGroupInfoButton.rx.klrx_tap.drive(onNext:{ _ in
            self.infoTextView.becomeFirstResponder()
            self.infoTextView.isEditable = true
        }).disposed(by: bag)
    }
    
    @objc func navBarBackTapped() {
        if self.state == .Edit {
            self.viewModel.updateGroupInfo().asObservable().subscribe(onNext: { _ in
                self.didUpdateGroupInfo?(self.viewModel?.groupModel.value)
                self.popOrDismiss()
            }).disposed(by:bag)
        }else if self.viewModel.shouldChangeMessageNotification {
            self.viewModel.muteRoomNotifications(status: self.viewModel.notificaitonStatus.value).asObservable().subscribe(onNext: { _ in
                self.popOrDismiss()
            }).disposed(by: bag)
        }else {
           self.popOrDismiss()
        }
    }
    
    private func popOrDismiss() {
        if self.navigationController?.viewControllers.count ?? 0 > 1 {
            self.navigationController?.popViewController()
        }else if (self.presentingViewController != nil) || (self.navigationController?.presentingViewController?.presentedViewController == self.navigationController) {
            self.dismiss(animated: true, completion: nil)
        }else {
            self.navigationController?.popViewController()
        }
    }
    
    func showImgSourceActionSheet(){
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
    
    
    func showOptionActions() {
        let showQRCode = UIAlertAction.init(title: LM.dls.show_qr_code, style: .default) { _ in
            guard let groupInfo = self.viewModel.groupModel.value else {
                return
            }
            let vc = UserIMQRCodeViewController.instance(from: UserIMQRCodeViewController.Config(uid: groupInfo.groupID, title: LM.dls.group_qr_code, imageURL: groupInfo.headImg, groupTitle: groupInfo.groupName))
            
            self.navigationController?.pushViewController(vc)
        }
        let leaveGroup = UIAlertAction.init(title: LM.dls.exit_group, style: .default) { _ in
            self.showAlert(title: LM.dls.confirm_exit, message: nil, buttonTitles: [LM.dls.g_cancel, LM.dls.g_confirm]) { [unowned self] (index) in
                if index == 1 {
                    self.viewModel.leaveGroup()
                }
            }
        }
        let deleteGroup = UIAlertAction.init(title: LM.dls.delete_group, style: .default) { _ in
            self.showAlert(title: LM.dls.confirm_delete_group, message: nil, buttonTitles: [LM.dls.g_cancel, LM.dls.g_confirm]) { [unowned self] (index) in
                if index == 1 {
                    self.viewModel.deleteGroup()
                }
            }
        }
        let cancelImage = #imageLiteral(resourceName: "btnAlertCancelNormal.png")
        deleteGroup.setValue(cancelImage.withRenderingMode(.alwaysOriginal), forKey: "image")
        let qrCodeImage = #imageLiteral(resourceName: "setting_icon_qrcode.png")
        showQRCode.setValue(qrCodeImage.withRenderingMode(.alwaysOriginal), forKey: "image")
        let leave = #imageLiteral(resourceName: "popovers_btn_leave.png")
        leaveGroup.setValue(leave.withRenderingMode(.alwaysOriginal), forKey: "image")
        
        let cancelAction = UIAlertAction.init(title: LM.dls.g_cancel, style: .cancel, handler: nil)
        
        let alertController = UIAlertController.init(title: LM.dls.group_setting_title, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(showQRCode)
        if self.viewModel.groupModel.value?.groupOwnerUID == IMUserManager.manager.userModel.value?.uID {
            alertController.addAction(deleteGroup)
        }else {
            alertController.addAction(leaveGroup)
        }
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
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
}

extension CreateNewGroupViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let resizedImg = image.scaleImage(toSize: targetSize(for: image))!
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
