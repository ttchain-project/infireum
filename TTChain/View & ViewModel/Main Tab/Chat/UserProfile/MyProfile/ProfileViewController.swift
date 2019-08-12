//
//  ProfileViewController.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/1/21.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import PhotosUI

final class ProfileViewController: KLModuleViewController, KLVMVC {
    enum Purpose {
        case IMProfile
        case SettingProfile
    }
    var purpose:Purpose!
    var viewModel: ProfileViewModel!
        
    typealias ViewModel = ProfileViewModel
    
    var bag: DisposeBag = DisposeBag.init()

    struct Config {
        let purpose :ProfileViewController.Purpose
    }
    
    func config(constructor: ProfileViewController.Config) {
        self.view.layoutIfNeeded()
        self.purpose = constructor.purpose
        self.viewModel = ProfileViewModel.init(input: ProfileViewModel.InputSource(userName:self.userNameTextField.rx.text),
                                               output: ProfileViewModel.OutputSource())
        self.startMonitorLangIfNeeded()
        self.startMonitorThemeIfNeeded()
        setupTextFields()

        self.bindUI()
        if self.purpose == .IMProfile {
            self.accountView.isHidden = true
            self.passwordView.isHidden = true
        }else {
            self.showQRCodeBtn.isHidden = true
        }
    }
    
    fileprivate var imagePicker: UIImagePickerController!
    typealias Constructor = Config
    var didUpdateProfileImage: Bool = false

    var imUser: IMUser? = {
        guard let imUser = IMUserManager.manager.userModel.value else {
            return nil
        }
        return imUser
    }()
    
    @IBOutlet weak var profileImageView: UIImageView! {
        didSet {
            profileImageView.cornerRadius = profileImageView.height/2
        }
    }
    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userNameTextField: OWInputTextField!
//    @IBOutlet weak var saveButton: UIButton! {
//        didSet {
//            saveButton.isHidden = true
//        }
//    }
    
    @IBOutlet weak var showQRCodeBtn: UIButton!
//    @IBOutlet weak var recoveryPasswordButton: UIButton!
    
    @IBOutlet weak var idTitleLabel: UILabel!
    @IBOutlet weak var idTextField: OWInputTextField! {
        didSet {
            idTextField.delegate = self
        }
    }

    
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var accountNameTextfield: OWInputTextField!
    
    @IBOutlet weak var accountPasswordLabel: UILabel!
    @IBOutlet weak var accountPasswordTextfield: OWInputTextField!
    
    @IBOutlet weak var accountView: UIStackView!
    @IBOutlet weak var passwordView: UIStackView!
    
    lazy var textFields:[OWInputTextField] = [userNameTextField,idTextField,accountNameTextfield,accountPasswordTextfield]
    
    let editImageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 30, height: 30))
    let copyImgView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 30, height: 30))
    let editPasswordImgView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 30, height: 30))

    private lazy var hud = {
        return KLHUD.init(
            type: .spinner,
            frame: CGRect.init(
                origin: .zero,
                size: .init(width: 100, height: 100)
            )
        )
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    func setupTextFields() {
        
        editImageView.image = #imageLiteral(resourceName: "btn_edit.png")
        self.userNameTextField.rightView = editImageView
        self.userNameTextField.rightViewMode = .always
        editImageView.rx.klrx_tap.drive(onNext: { () in
            self.userNameTextField.becomeFirstResponder()
        }).disposed(by: bag)
        editImageView.contentMode = .scaleAspectFit
        
        copyImgView.image = #imageLiteral(resourceName: "Copy.png")
        copyImgView.contentMode = .scaleAspectFit
        self.idTextField.rightView = copyImgView
        self.idTextField.rightViewMode = .always
        copyImgView.rx.klrx_tap.drive(onNext: {() in
            UIPasteboard.general.string = self.idTextField.text
            EZToast.present(on: self, content: LM.dls.copied_successfully)
        }).disposed(by: bag)
        
        editPasswordImgView.image = #imageLiteral(resourceName: "btn_edit.png")
        self.accountPasswordTextfield.rightView = editPasswordImgView
        self.accountPasswordTextfield.rightViewMode = .always
        editPasswordImgView.rx.klrx_tap.drive(onNext: { () in
//            self.accountPasswordTextfield.becomeFirstResponder()
        }).disposed(by: bag)
        editPasswordImgView.contentMode = .scaleAspectFit
        
    }
    
    override func renderLang(_ lang: Lang) {
        self.title = lang.dls.personal_information
//        self.saveButton.setTitle(lang.dls.ab_update_btn_save, for: .normal)
        self.userNameTextField.placeholder = lang.dls.myIdentity_label_name
//        self.recoveryPasswordButton.setTitle(lang.dls.user_profile_transfer_account, for: .normal)
        self.userNameLabel.text = lang.dls.chat_nick_name
        self.idTitleLabel.text = lang.dls.tab_chat + "ID"
        self.showQRCodeBtn.setTitleForAllStates(lang.dls.show_qr_code)
        
        self.accountNameLabel.text = lang.dls.createID_placeholder_name
        self.accountPasswordLabel.text = lang.dls.createID_placeholder_password
    }
    
    override func renderTheme(_ theme: Theme) {
        renderNavBar(tint: theme.palette.nav_item_2, barTint: theme.palette.nav_bar_tint)
        renderNavTitle(color: theme.palette.nav_item_2, font: .owRegular(size: 20))
        changeLeftBarButton(target: self, selector: #selector(backButtonTapped), tintColor: theme.palette.nav_bg_1, image: #imageLiteral(resourceName: "btn_previous_light"))
        self.view.backgroundColor = .white
//        self.saveButton.backgroundColor = theme.palette.btn_bgFill_enable_bg
//        self.recoveryPasswordButton.backgroundColor = theme.palette.application_main
        
        for textField in textFields {
            textField.set(textColor: theme.palette.input_text, font: .owRegular(size: 14), placeHolderColor: theme.palette.input_placeholder)
            textField.sepline.backgroundColor = .black
        }
        
        self.userNameLabel.set(textColor: theme.palette.btn_bgFill_enable_bg, font: .owRegular(size: 12))
        self.idTitleLabel.set(textColor: theme.palette.btn_bgFill_enable_bg, font: .owRegular(size: 12))
        
        self.accountNameLabel.set(textColor: theme.palette.btn_bgFill_enable_bg, font: .owRegular(size: 12))
        self.accountPasswordLabel.set(textColor: theme.palette.btn_bgFill_enable_bg, font: .owRegular(size: 12))
        self.showQRCodeBtn.set(textColor: .white, font: .owRegular(size:14), backgroundColor: .creamCan)
        self.showQRCodeBtn.cornerRadius = showQRCodeBtn.height/2
    }

    func bindUI() {
//        self.recoveryPasswordButton.isHidden = true
        
//        self.userNameTextField.text = imUser?.nickName
        self.idTextField.text = imUser?.uID
        self.accountNameTextfield.text = Identity.singleton?.name
        
        if let img = imUser?.headImgUrl  {
            self.profileImageView.setProfileImage(image: img, tempName: imUser?.nickName)
        }else {
            self.profileImageView.image = imUser?.headImg ?? ImageUntil.drawAvatar(text: (imUser?.nickName)!)
        }
        
        
        editProfileButton.rx.tap.asDriver().drive(onNext: { _ in
            self.showImgSourceActionSheet()
        }).disposed(by: bag)
        
        self.showQRCodeBtn.rx.tap.asDriver().drive(onNext: { [unowned self] _ in
            self.showQRCode()
        }).disposed(by: bag)
        
        self.viewModel.output.onUpdateComplete.subscribe(onNext:{
            if self.navigationController?.viewControllers.count ?? 0 > 1 {
                self.navigationController?.popViewController(animated: true)
            }else {
                self.dismiss(animated: true, completion: nil)
            }
        }).disposed(by: bag)
        
        self.viewModel.output.animateHud.observeOn(MainScheduler.instance).subscribe(onNext:{ status in
            if status {
                self.hud.startAnimating(inView: self.view)
            }else {
                self.hud.stopAnimating()
            }
        }).disposed(by: bag)
        self.viewModel.output.messageSubject.bind(to:self.rx.message).disposed(by: bag)
    }
    
    func updateProfilePhoto() {
         let image = self.profileImageView.image?.updateImageOrientionUpSide() ?? self.profileImageView.image
        self.viewModel.updateProfilePic(image:image!)
    }
    
    func updateUserName() {
        self.viewModel.updateUserName()
    }
    
    func setRecoveryPassword() {
        self.getRecoveryPasswordFromUser().subscribe(onSuccess: { password in
            self.viewModel.setRecoveryPassword(password: password)
        }).disposed(by: bag)
    }
    
    func getRecoveryPasswordFromUser() -> Single<String> {
        return Single.create { [unowned self] (handler) -> Disposable in
            let palette = TM.palette
            let dls = LM.dls
            let alert = UIAlertController.init(
                title: dls.user_profile_transfer_account,
                message: dls.user_profile_alert_transfer_account_message,
                preferredStyle: .alert
            )
            
            let cancel = UIAlertAction.init(title: dls.g_cancel,
                                            style: .cancel,
                                            handler: nil)
            var textField: UITextField!
            let confirm = UIAlertAction.init(title: dls.g_confirm,
                                             style: .default) {
                                                (_) in
                                                if let pwd = textField.text, pwd.count > 0 {
                                                    handler(.success(pwd))
                                                }
            }
            
            alert.addTextField { [unowned self] (tf) in
                tf.set(textColor: palette.input_text, font: .owRegular(size: 13), placeHolderColor: palette.input_placeholder)
                tf.set(placeholder:dls.user_profile_placeholder_transfer_account)
                textField = tf
                tf.rx.text.map { $0?.count ?? 0 }.map { $0 > 0 }.bind(to: confirm.rx.isEnabled).disposed(by: self.bag)
            }
            
            alert.addAction(cancel)
            alert.addAction(confirm)
            self.present(alert, animated: true, completion: nil)
            
            return Disposables.create()
        }
    }
    
    func showQRCode() {
        guard let user = IMUserManager.manager.userModel.value else {
            return
        }
        let vc = UserIMQRCodeViewController.instance(from: UserIMQRCodeViewController.Config(uid:user.uID, title:LM.dls.myQRCode,imageURL:user.headImgUrl,groupTitle:user.nickName!))
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func backButtonTapped() {
        if self.didUpdateProfileImage  {
            //UpdateImage
            self.updateProfilePhoto()
        } else if self.imUser!.nickName != self.userNameTextField.text {
            self.updateUserName()
        }else {
            if self.navigationController?.viewControllers.count ?? 0 > 1 {
                self.navigationController?.popViewController(animated: true)
            }else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}

extension ProfileViewController {
    
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

extension ProfileViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
//            let resizedImg = image.scaleImage(toSize: targetSize(for: image))!
            self.didUpdateProfileImage = true
            self.profileImageView.image = image
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


extension UIImage {
    
    func updateImageOrientionUpSide() -> UIImage? {
        if self.imageOrientation == .up {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        if let normalizedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return normalizedImage
        }
        UIGraphicsEndImageContext()
        return nil
    }
}

extension ProfileViewController :UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField  {
        case idTextField, accountNameTextfield:
            return false
        default:
            return true
        }
    }
}
