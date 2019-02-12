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
    var viewModel: UserProfileViewModel!
        
    typealias ViewModel = UserProfileViewModel
    
    var bag: DisposeBag = DisposeBag.init()

    fileprivate var imagePicker: UIImagePickerController!

    typealias Constructor = Void
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
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var recoveryPasswordButton: UIButton!
    
    func config(constructor: Void) {
        self.view.layoutIfNeeded()
       
        self.startMonitorLangIfNeeded()
        self.startMonitorThemeIfNeeded()
        
        self.userNameTextField.text = imUser?.nickName
        if let img = imUser?.headImg  {
            self.profileImageView.image = img

        }
        
        editProfileButton.rx.tap.asDriver().drive(onNext: { _ in
            self.showImgSourceActionSheet()
        }).disposed(by: bag)
        
        self.userNameTextField.rx.controlEvent([.editingDidBegin, .editingDidEnd]).asObservable().asObservable()
            .subscribe(onNext: { _ in
                self.saveButton.isEnabled = true
            })
            .disposed(by: bag)
        
        self.saveButton.rx.tap.asDriver().drive(onNext: { [unowned self] _ in
            if self.didUpdateProfileImage  {
                //UpdateImage
                self.updateProfilePhoto()
            } else if self.imUser!.nickName != self.userNameTextField.text {
                self.updateUserName()
            }
        }).disposed(by: bag)
        
        self.recoveryPasswordButton.rx.tap.asDriver().drive(onNext: { [unowned self] _ in
           self.setRecoveryPassword()
        }).disposed(by: bag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.setGradientColor()
    }
    
    override func renderLang(_ lang: Lang) {
        self.saveButton.setTitle(lang.dls.ab_update_btn_save, for: .normal)
        self.userNameTextField.placeholder = lang.dls.myIdentity_label_name
        self.recoveryPasswordButton.setTitle(lang.dls.user_profile_transfer_account, for: .normal)
    }
    
    override func renderTheme(_ theme: Theme) {
        
        self.saveButton.backgroundColor = theme.palette.application_main
        self.recoveryPasswordButton.backgroundColor = theme.palette.application_main
        
        self.userNameTextField.set(textColor: theme.palette.input_text, font: .owRegular(size: 25), placeHolderColor: theme.palette.input_placeholder)
        
        
    }

    
    func updateProfilePhoto() {
        
        guard let image = self.profileImageView.image else {
            return
        }
        let parameter = UploadHeadImageAPI.Parameters.init(personalOrGroupId:imUser!.uID , isGroup: false, image: UIImageJPEGRepresentation(image, 0.5)!)
        
        Server.instance.uploadHeadImg(parameters: parameter).asObservable().subscribe(onNext: { (result) in
            switch result {
            case .success(let model):
                
                if let url = URL.init(string: model.image), let data = try? Data.init(contentsOf: url) {
                    IMUserManager.manager.userModel.value!.headImg = UIImage.init(data: data)
                }
                LocalIMUser.updateLocalIMUser()
                
                if self.imUser!.nickName != self.userNameTextField.text {
                    //UpdateName
                    self.updateUserName()
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            case .failed(error: let error):
                print("error %@", error)
            }
        }).disposed(by: bag)
        
    }
    
    func updateUserName() {
        guard let userName = self.userNameTextField.text, userName.count > 0 else {
            self.showSimplePopUp(with: "Error", contents: "Name cannot be nil", cancelTitle: "Ok") { _ in
                self.userNameTextField.becomeFirstResponder()
            }
            return
        }
        let parameter = UpdateUserAPI.Parameters.init(uid: (imUser?.uID)! , nickName: userName, introduction: imUser?.introduction ?? "")

        Server.instance.updateUserData(parameters: parameter).asObservable().subscribe(onNext: { (result) in
            switch result {
            case .success(_):
                self.imUser?.nickName = self.userNameTextField.text!
                LocalIMUser.updateLocalIMUser()
                self.navigationController?.popViewController(animated: true)
            case .failed(error: let error):
                print("error %@", error)
            }
        }).disposed(by: bag)
    }
    
    func setRecoveryPassword() {
        
        self.getRecoveryPasswordFromUser().subscribe(onSuccess: { password in
            guard let id = IMUserManager.manager.userModel.value?.uID else { return }
            Server.instance.setRecoveryPassword(withIMUserId: id, recoveryPassword: password).asObservable().subscribe(onNext: {
                [weak self] result in
                guard let `self` = self else { return }
                switch result {
                case .success: DLogDebug("set recovery key successful.")
                EZToast.present(on: self, content: "Password set successfully")
                case .failed(error: let error):
                    DLogError(error)
                    EZToast.present(on: self, content: error.localizedDescription)
                }
            }).disposed(by:self.bag)
        }).disposed(by: bag)
    }
    
    func getRecoveryPasswordFromUser() -> Single<String> {
        return Single.create { [unowned self] (handler) -> Disposable in
            let palette = TM.palette
            let dls = LM.dls
            let alert = UIAlertController.init(
                title: "IM Recovery Password",
                message: "Please set a password to recover your IM account on another device",
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
                tf.set(placeholder:"Enter recovery password")
                textField = tf
                tf.rx.text.map { $0?.count ?? 0 }.map { $0 > 0 }.bind(to: confirm.rx.isEnabled).disposed(by: self.bag)
            }
            
            alert.addAction(cancel)
            alert.addAction(confirm)
            self.present(alert, animated: true, completion: nil)
            
            return Disposables.create()
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
            let resizedImg = image.scaleImage(toSize: targetSize(for: image))!
            self.didUpdateProfileImage = true
            self.profileImageView.image = resizedImg
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
