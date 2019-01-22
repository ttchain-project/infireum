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
//import SKPhotoBrowser
final class ProfileViewController: KLModuleViewController, KLVMVC {
    var viewModel: UserProfileViewModel!
    
    
    
    typealias ViewModel = UserProfileViewModel
    
    var bag: DisposeBag = DisposeBag.init()

    fileprivate var imagePicker: UIImagePickerController!

    typealias Constructor = Void
    var didUpdateProfileImage: Bool = false
    fileprivate var hasAuthedCamera: Bool {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch status {
        case .authorized, .notDetermined:
            return true
        default:
            return false
        }
    }
    
    fileprivate var hasAuthedPhotoLibrary: Bool {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized, .notDetermined:
            return true
        default:
            return false
        }
    }
    var imUser: IMUser? = {
        guard let imUser = IMUserManager.manager.userModel.value else {
            return nil
        }
        return imUser
    }()
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
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
            
            if self.imUser!.nickName != self.userNameTextField.text {
                //UpdateName
            }
            if self.didUpdateProfileImage  {
                //UpdateImage
                self.updateProfilePhoto()
            }
        }).disposed(by: bag)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.setGradientColor()
    }
    
    override func renderLang(_ lang: Lang) {
        self.saveButton.setTitle("Save", for: .normal)
        self.userNameTextField.placeholder = "Enter Name"
    }
    
    override func renderTheme(_ theme: Theme) {
        
        self.saveButton.backgroundColor = theme.palette.application_main
        self.userNameTextField.set(textColor: theme.palette.input_text, font: .owRegular(size: 25), placeHolderColor: theme.palette.input_placeholder)
    }
    fileprivate func displayCamera() {
        guard hasAuthedCamera else {
            return
        }
        
        imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .camera
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    fileprivate func displayImageSource() {
        guard hasAuthedPhotoLibrary else {
            
            return
        }
        
        imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    fileprivate func showImgSourceActionSheet() {
        let actionSheet = UIAlertController.init(title: "Choose a picture", message: nil, preferredStyle: .actionSheet)
        
        let camera = UIAlertAction.init(title: "Camera", style: .default) { (_) in
            self.displayCamera()
        }
        
        let gallery = UIAlertAction.init(title: "Gallery", style: .default) { (_) in
            self.displayImageSource()
        }
        
        let cancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(camera)
        actionSheet.addAction(gallery)
        actionSheet.addAction(cancel)
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    func updateProfilePhoto() {
        
        guard let image = self.profileImageView.image else {
            return
        }
        let parameter = UploadHeadImageAPI.Parameters.init(personalOrGroupId:imUser!.uID , isGroup: false, image: UIImageJPEGRepresentation(image, 0.5)!)
        
        Server.instance.uploadHeadImg(parameters: parameter).asObservable().subscribe(onNext: { (result) in
            switch result {
            case .success(_):
                LocalIMUser.updateLocalIMUser()
                guard let vc = self.navigationController?.popViewController(animated: true) else {
                    return
                }
                EZToast.present(on: vc, content: "User Profile Updated")
            case .failed(error: let error):
                print("error %@", error)
            }
        }).disposed(by: bag)
        
    }
    
    func updateUserName() {
       
        let parameter = UpdateUserAPI.Parameters.init(uid: (imUser?.uID)! , nickName: self.userNameTextField.text!, introduction: imUser?.introduction ?? "")

        Server.instance.updateUserData(parameters: parameter).asObservable().subscribe(onNext: { (result) in
            switch result {
            case .success(_):
                self.navigationController?.popViewController(animated: true)
            case .failed(error: let error):
                print("error %@", error)
            }
        }).disposed(by: bag)
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
