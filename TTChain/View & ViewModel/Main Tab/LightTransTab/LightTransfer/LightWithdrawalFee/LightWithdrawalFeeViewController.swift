//
//  LightWithdrawalFeeViewController.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/4/26.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class LightWithdrawalFeeViewController: KLModuleViewController,KLVMVC,WithdrawalChildVC {
    
    
    func config(constructor: LightWithdrawalFeeViewController.Config) {
        self.view.layoutIfNeeded()
        self.viewModel = LightWithdrawalFeeViewModel.init(input: LightWithdrawalFeeViewModel.Input(asset:constructor.asset), output: LightWithdrawalFeeViewModel.Output())
       
        Observable.of(FeeManager.getValue(fromOption: .ttn(.systemDefault))).map { (fee) -> String in
            return fee.asString(digits: 4) + "TTN"
        }.bind(to: self.totalMinorFee.rx.text).disposed(by: bag)
        
        self.minorFeeTitle.text = LM.dls.withdrawal_label_minerFee
    }
    
    var viewModel: LightWithdrawalFeeViewModel!
    
    typealias ViewModel = LightWithdrawalFeeViewModel
    
    var bag: DisposeBag = DisposeBag()
    
    typealias Constructor = Config

    struct Config {
        let asset:Asset
    }

    @IBOutlet weak var minorFeeTitle: UILabel!
    @IBOutlet weak var totalMinorFee: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    var preferedHeight: CGFloat {
        return view.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
    }
    
    var isAllFieldsHaveValue: Observable<Bool> {
        return Observable.of(true)
    }
}
