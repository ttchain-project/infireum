//
//  SuccessWalletViewController.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/7/18.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit
import RxSwift

class SuccessWalletViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.titleLabel.text = purpose == ImportWalletViaPrivateKeyViewController.Purpose.import ? LM.dls.new_wallet_imported_msg : LM.dls.new_wallet_created_msg
        self.subTitleLabel.text = LM.dls.wallet_import_success_subtitle_msg
        // Do any additional setup after loading the view.
    }
    @IBOutlet weak var doneButton: UIButton!{
        didSet {
            doneButton.setTitle(LM.dls.g_confirm, for: .normal)
            doneButton.set(color: TM.palette.label_sub, font: .owRegular(size:14))
            self.doneButton.rx.klrx_tap.drive(onNext:{
                self.completion()
            }).disposed(by: bag)
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.set(textColor: TM.palette.label_main_1, font: .owMedium(size: 18))
        }
    }
    @IBOutlet weak var subTitleLabel: UILabel!{
        didSet {
            subTitleLabel.set(textColor: TM.palette.label_main_1, font: .owRegular(size: 14))
        }
    }
    var bag = DisposeBag()
    var purpose : ImportWalletViaPrivateKeyViewController.Purpose!
    var completion:(()->Void)!
    init(purpose:ImportWalletViaPrivateKeyViewController.Purpose,
         completion:@escaping (()->Void)) {
        self.purpose = purpose
        self.completion = completion
        super.init(nibName: SuccessWalletViewController.nameOfClass, bundle: nil)
        self.providesPresentationContextTransitionStyle = true
        self.definesPresentationContext = true
        self.modalPresentationStyle = UIModalPresentationStyle.overFullScreen

    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
