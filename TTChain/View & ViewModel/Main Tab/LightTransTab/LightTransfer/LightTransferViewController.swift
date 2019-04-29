//
//  LightTransferViewController.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/4/26.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Cartography

final class LightTransferViewController: KLModuleViewController, KLVMVC {
    var viewModel: WithdrawalBaseViewModel!
    
    func config(constructor: LightTransferViewController.Config) {
        
    }
    
    
    typealias ViewModel = WithdrawalBaseViewModel
    var bag: DisposeBag = DisposeBag()
    typealias Constructor = Config

    struct Config {
        let asset:Asset
    }
    
    private var assetVC: WithdrawalAssetViewController!
    private var addressVC: WithdrawalAddressViewController!
    private var feeVC: UIViewController!
    private var remarkNoteVC : WithdrawalRemarksViewController!
    private var feeInfoProvider:LightWithdrawalFeeViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBOutlet weak var scrollView: UIScrollView!
    
}
