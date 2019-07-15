//
//  UserIMQRCodeViewController.swift
//  OfflineWallet
//
//  Created by Ajinkya Sharma on 2018/10/22.
//  Copyright © 2018 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class UserIMQRCodeViewController: KLModuleViewController, KLVMVC {
    
    typealias ViewModel = UserQRCodeViewModel
    typealias Constructor = Config
    
    struct Config {
        let uid :String
        let title:String
        let imageURL:String?
        let groupTitle:String
    }
    @IBOutlet weak var qrCodeImageView: UIImageView!
    @IBOutlet weak var uidLabel: UILabel!
    @IBOutlet weak var uidCopyButton: UIButton!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var saveImageBtn: UIButton!
    @IBOutlet weak var containerView: UIView!
    
    
    var bag: DisposeBag = DisposeBag.init()
    var viewModel: UserQRCodeViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startMonitorThemeIfNeeded()
        startMonitorLangIfNeeded()
        
    }
    
    override func renderLang(_ lang: Lang) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        uidLabel.set(textColor: .black,
                     font: .owMedium(size:12 ))
        self.view.backgroundColor = .cloudBurst
        changeBackBarButton(toColor: palette.nav_item_2, image: #imageLiteral(resourceName: "btn_previous_light"))
        renderNavBar(tint: palette.nav_item_2, barTint: palette.nav_bar_tint)
        renderNavTitle(color: palette.nav_item_2, font: .owRegular(size: 20))
        createRightBarButton(target: self, selector: #selector(shareQRCode), image: #imageLiteral(resourceName: "btn_share.png"), toColor: palette.nav_item_2)
        
    }
    
    func config(constructor: UserIMQRCodeViewController.Config) {
        view.layoutIfNeeded()
        let output = UserQRCodeViewModel.Output()
        viewModel = ViewModel.init(input: UserQRCodeViewModel.Input.init(uid:constructor.uid), output: output)
        viewModel.output.image.bind(to: qrCodeImageView.rx.image).disposed(by: bag)
        self.uidLabel.text = self.viewModel.uID.value
        self.navigationItem.title = constructor.title
        self.uidCopyButton.rx.tap.asDriver()
            .throttle(1)
            .drive(onNext: {
                [unowned self] in
                UIPasteboard.general.string = self.viewModel.uID.value
                self.view.makeToast(LM.dls.g_toast_addr_copied)
            })
            .disposed(by: bag)
        
        saveImageBtn.rx.klrx_tap.drive(onNext:{[unowned self] _ in
            let img = self.containerView.screenshot
            ImageSaver.saveImage(image: img!, onViewController: self).subscribe(onSuccess: nil, onError: nil).disposed(by: self.bag)
        }).disposed(by: bag)
        if let imageURL = constructor.imageURL {
            self.userImageView.setProfileImage(image: imageURL, tempName: constructor.groupTitle)
        }
        self.nameLabel.text = constructor.groupTitle
    }
    
    @objc func shareQRCode() {
        let img = containerView.screenshot!
        let activityVC = UIActivityViewController.init(activityItems: [img], applicationActivities: nil)
        present(activityVC, animated: true, completion: nil)
    }
}
