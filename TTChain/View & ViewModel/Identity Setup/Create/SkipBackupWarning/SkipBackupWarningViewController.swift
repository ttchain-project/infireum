//
//  SkipBackupWarningViewController.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/7/18.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit
import RxSwift

class SkipBackupWarningViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    var bag = DisposeBag()
    var completion:((Bool) -> Void)
    @IBOutlet weak var titleLabel:UILabel! {
        didSet {
            titleLabel.set(textColor: .white, font: .owRegular(size:18), text: LM.dls.backup_skip_msg_title)
        }
    }
    @IBOutlet weak var subTitleLabel:UILabel! {
        didSet {
            subTitleLabel.set(textColor: .white, font: .owRegular(size:14), text: LM.dls.back_up_skip_warning_msg)
        }
    }
    @IBOutlet weak var confirmButton:UIButton! {
        didSet {
            confirmButton.set(textColor: .white, font: .owRegular(size:14),
                              text: LM.dls.qrCodeExport_btn_backup_qrcode)
            confirmButton.rx.klrx_tap.drive(onNext:{
                self.completion(true)
            }).disposed(by: bag)
        }
    }
    
    @IBOutlet weak var skipButton:UIButton! {
        didSet {
            skipButton.set(textColor: .bittersweet, font: .owRegular(size:14),
                           text: LM.dls.qrcodeExport_alert_btn_skip,
                           borderInfo: (color: UIColor.bittersweet, width: 1.0))
            
            skipButton.rx.klrx_tap.drive(onNext:{
                self.completion(false)
            }).disposed(by: bag)
        }
    }

    init(completion:@escaping ((Bool) -> Void)) {
        self.completion = completion
        super.init(nibName: SkipBackupWarningViewController.className, bundle: nil)
        self.providesPresentationContextTransitionStyle = true
        self.definesPresentationContext = true
        self.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
