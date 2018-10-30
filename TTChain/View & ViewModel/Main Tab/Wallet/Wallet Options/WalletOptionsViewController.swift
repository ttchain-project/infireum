//
//  WalletOptionsViewController.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2018/10/29.
//  Copyright © 2018 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class WalletOptionsViewController:KLModuleViewController, KLVMVC {
    var viewModel: WalletOptionsViewModel!
    
    typealias ViewModel = WalletOptionsViewModel

    func config(constructor: Void) {
        
    }
    typealias Constructor = Void
    
    var bag: DisposeBag = DisposeBag.init()

    @IBOutlet weak var USDAmountLabel: UILabel!
 
    @IBOutlet weak var settingsButton: UIButton!
    
    @IBOutlet weak var btcAddressLabel: UILabel!
    @IBOutlet weak var btcValueLabel: UILabel!
    @IBOutlet weak var btcSetting: UIImageView!
    @IBOutlet weak var btcAddressCopy: UIImageView!
    
    @IBOutlet weak var ethAddressLabel: UILabel!
    @IBOutlet weak var ethValueLabel: UILabel!
    @IBOutlet weak var ethSetting: UIImageView!
    @IBOutlet weak var ethAddressCopy: UIImageView!
    
    @IBOutlet weak var rscSetting: UIImageView!
    @IBOutlet weak var rscAddressCopy: UIImageView!
    @IBOutlet weak var rscAddressLabel: UILabel!
    @IBOutlet weak var rscValueLabel: UILabel!
   
    @IBOutlet weak var airdropSetting: UIImageView!
    @IBOutlet weak var airdropAddressCopy: NSLayoutConstraint!
    @IBOutlet weak var airdropAddressLabel: UILabel!
    @IBOutlet weak var airdropValueLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let navBar = self.navigationController?.navigationBar else {
            return
        }
        self.viewModel = WalletOptionsViewModel.init(input: (), output: ())
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        navBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        self.bindViewModel()
        // Do any additional setup after loading the view.
    }
    
    private func bindViewModel() {
        self.viewModel.btcWallet.subscribe(onNext: { (wallet) in
            self.btcAddressLabel.text = wallet?.address
            
        }).disposed(by: bag)
        
        self.viewModel.ethWallet.subscribe(onNext: { (wallet) in
            self.ethAddressLabel.text = wallet?.address
        }).disposed(by: bag)
    }

    
}
