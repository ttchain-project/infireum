//
//  WithdrawalAddressViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/7.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class WithdrawalAddressViewController: KLModuleViewController, WithdrawalChildVC, KLVMVC {
    
    @IBOutlet weak var toAddrTitleLabel: UILabel!
    @IBOutlet weak var addrbookBtn: UIButton!
    @IBOutlet weak var addrTextField: OWInputTextField!
    @IBOutlet weak var fromAddrTitleLabel: UILabel!
    @IBOutlet weak var fromWalletBtn: UIButton!
    @IBOutlet weak var fromAddrLabel: UILabel!
    
    typealias ViewModel = WithdrawalAddressViewModel
    var viewModel: WithdrawalAddressViewModel!
    var bag: DisposeBag = DisposeBag.init()
    
    struct Config {
        let asset: Asset
    }
    
    typealias Constructor = Config
    func config(constructor: WithdrawalAddressViewController.Config) {
        view.layoutIfNeeded()
        addrTextField.sepInset = 8
        
        viewModel = ViewModel.init(
            input: WithdrawalAddressViewModel.InputSource(asset: constructor.asset, toAddressInout: addrTextField.rx.text, toAddressCoinId: constructor.asset.coinID!),
            output: ()
        )
        
        startMonitorThemeIfNeeded()
        startMonitorLangIfNeeded()
        
        bindViewModel()
    }
    
    var preferedHeight: CGFloat {
        return view.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
    }
    
    var isAllFieldsHaveValue: Observable<Bool> {
        return viewModel.hasValidInfo
    }
    
    lazy var onTapChangeToAddress: Driver<Void> = {
        return addrbookBtn.rx.tap.asDriver()
    }()
    
    lazy var onTapChangeFromWallet: Driver<Void> = {
        return fromWalletBtn.rx.tap.asDriver()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func bindViewModel() {
        viewModel.fromAsset
            .map {
                $0.wallet!.name!
            }
            .subscribe(onNext: {
                [unowned self] in self.fromWalletBtn.set(image: #imageLiteral(resourceName: "doneBlue"), title: $0, titlePosition: .left, additionalSpacing: 8, state: .normal)
            })
            .disposed(by: bag)
        
        viewModel.fromAsset.map { $0.wallet!.address! }.bind(to: fromAddrLabel.rx.text).disposed(by: bag)
    }
    
    override func renderLang(_ lang: Lang) {
        let dls = lang.dls
        toAddrTitleLabel.text = dls.withdrawal_label_toAddr
        addrbookBtn.set(image: #imageLiteral(resourceName: "doneBlue"),
                        title: dls.withdrawal_btn_common_used_addr,
                        titlePosition: .left,
                        additionalSpacing: 8,
                        state: .normal)
        addrTextField.set(placeholder: dls.withdrawal_placeholder_toAddr)
        
        fromAddrTitleLabel.text = dls.withdrawal_label_fromAddr
    }
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        view.backgroundColor = palette.bgView_sub
        toAddrTitleLabel.set(textColor: palette.label_main_1, font: .owRegular(size: 17))
        addrbookBtn.set(color: palette.label_main_1, font: UIFont.owRegular(size: 14))
        addrTextField.set(textColor: palette.input_text, font: .owRegular(size: 17), placeHolderColor: palette.input_placeholder)
        addrTextField.sepline.backgroundColor = palette.sepline
        
        fromAddrTitleLabel.set(textColor: palette.label_main_1, font: .owRegular(size: 17))
        fromWalletBtn.set(color: palette.label_main_1, font: UIFont.owRegular(size: 17))
        fromAddrLabel.set(textColor: palette.input_text, font: .owRegular(size: 17))
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
