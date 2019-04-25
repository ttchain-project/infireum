//
//  LightTransDetailViewController.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/4/16.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class LightTransDetailViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    @IBOutlet weak var coinIconImgView: UIImageView! {
        didSet {
            coinIconImgView.image = self.viewModel.input.asset.value.coin!.iconImg
        }
    }
        
    @IBOutlet weak var totalAmountLabel: UILabel! {
        didSet {
            self.viewModel.output.amountStr.bind(to:self.totalAmountLabel.rx.text).disposed(by: bag)
        }
    }
    @IBOutlet weak var fiatAmtLabel: UILabel! {
        didSet {
            self.viewModel.output.fiatAmtStr.bind(to:self.fiatAmtLabel.rx.text).disposed(by: bag)
        }
    }
    @IBOutlet weak var lightTransButton: UIButton!
    @IBOutlet weak var receiveButon: UIButton! {
        didSet {
            receiveButon.rx.klrx_tap.asDriver().drive(onNext: { _ in
                self.showDepositAction()
            }).disposed(by:bag)
        }
    }
    @IBOutlet weak var txDetailButton: UIButton!
    
    
    var viewModel:LightTransDetailViewModel!
    var bag:DisposeBag = DisposeBag.init()
    
    init(withViewModel viewModel: LightTransDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: LightTransDetailViewController.className, bundle: nil)
        self.viewModelBinding()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.setGradientColor(color1: UIColor.init(red: 44, green: 60, blue: 78)?.cgColor, color2: UIColor.init(red: 24, green: 34, blue: 39)?.cgColor)
    }
    
    func setupUI() {
        
        let pallete = ThemeManager.palette
        self.totalAmountLabel.set(textColor: pallete.label_main_1, font: .owDemiBold(size: 32))
        self.fiatAmtLabel.set(textColor: pallete.label_main_1, font: .owDemiBold(size: 16))
        
        self.lightTransButton.set(
            textColor: pallete.btn_bgFill_enable_text,
            font: .owRegular(size:14),
            text: LM.dls.lightningTx_title,
            backgroundColor: pallete.recordStatus_failed)
        
        self.receiveButon.set(
            textColor: pallete.btn_bgFill_enable_text,
            font: .owRegular(size:14),
            text: LM.dls.lightning_receipt_btn_title,
            backgroundColor: pallete.recordStatus_deposit)
        
        self.txDetailButton.set(
            textColor: pallete.btn_bgFill_enable_text,
            font: .owRegular(size:14),
            text: LM.dls.transaction_details_btn_title,
            backgroundColor: pallete.nav_bg_clear)
        
        renderNavBar(tint: pallete.nav_item_2, barTint: pallete.nav_bg_clear)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        renderNavTitle(color: pallete.nav_item_2, font: .owMedium(size: 20))

        changeLeftBarButtonToDismissToRoot(tintColor: pallete.nav_item_2, image: #imageLiteral(resourceName: "arrowNavBlack"))
    }
    
    func viewModelBinding() {
        self.viewModel.input.asset.map {
            $0.coin?.inAppName
        }.bind(to: self.navigationItem.rx.title).disposed(by: bag)
    }
    
    func showTransferAction(asset:Asset) {
        let nav = WithdrawalBaseViewController.navInstance(from: WithdrawalBaseViewController.Config(asset: asset, defaultToAddress: nil,defaultAmount:nil))
        present(nav, animated: true, completion: nil)
        
    }
    func showDepositAction() {
        let viewModel = LightReceiptQRCodeViewModel.init(asset: self.viewModel.input.asset.value)
        let vc = LightReceiptQRCodeViewController.init(viewModel: viewModel)
        self.navigationController?.pushViewController(vc)
    }
}
