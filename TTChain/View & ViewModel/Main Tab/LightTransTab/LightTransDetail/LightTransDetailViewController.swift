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
    @IBOutlet weak var lightTransButton: UIButton! {
        didSet {
            lightTransButton.rx.klrx_tap.asDriver().drive(onNext: { _ in
                self.showTransferAction()
            }).disposed(by:bag)
        }
    }
    @IBOutlet weak var receiveButon: UIButton! {
        didSet {
            receiveButon.rx.klrx_tap.asDriver().drive(onNext: { _ in
                self.showDepositAction()
            }).disposed(by:bag)
        }
    }
    @IBOutlet weak var txDetailButton: UIButton! {
        didSet {
            txDetailButton.rx.klrx_tap.asDriver().drive(onNext: { _ in
                let vc = AssetDetailViewController.navInstance(
                    from: AssetDetailViewController.Config(asset: self.viewModel.input.asset.value,purpose:AssetDetailViewController.Purpose.lightTx)
                )
                //        let assetVC = AssetDetailViewController.instance(from: AssetDetailViewController.Config(asset: asset))
                self.present(vc, animated: true, completion: nil)
            }).disposed(by: bag)
        }
    }
    
    
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
        self.view.setGradientColor(cgColors: [UIColor.init(white: 0, alpha: 1).cgColor,UIColor.cloudBurst.cgColor])
    }
    
    func setupUI() {
        
        let pallete = ThemeManager.palette
        self.totalAmountLabel.set(textColor: pallete.label_main_2, font: .owDemiBold(size: 32))
        self.fiatAmtLabel.set(textColor: pallete.label_main_2, font: .owDemiBold(size: 16))
        
        self.lightTransButton.set(
            textColor: pallete.btn_bgFill_enable_text,
            font: .owRegular(size:14),
            text: LM.dls.lightningTx_title,
            backgroundColor: pallete.recordStatus_withdrawal)
        
        self.receiveButon.set(
            textColor: pallete.btn_bgFill_enable_text,
            font: .owRegular(size:14),
            text: LM.dls.lightning_receipt_btn_title,
            backgroundColor: pallete.recordStatus_deposit)
        
        self.txDetailButton.set(
            textColor: UIColor.summerSky,
            font: .owRegular(size:14),
            text: LM.dls.transaction_details_btn_title,
            backgroundColor: pallete.nav_bg_clear,
            borderInfo: (color: UIColor.summerSky, width: 1))
        
        renderNavBar(tint: pallete.nav_item_2, barTint: pallete.nav_bar_tint)
        renderNavTitle(color: pallete.nav_item_2, font: .owMedium(size: 20))
        changeLeftBarButtonToDismissToRoot(tintColor: pallete.nav_item_2, image: #imageLiteral(resourceName: "btn_previous_light"))
    }
    
    func viewModelBinding() {
        self.viewModel.input.asset.map {
            $0.coin?.inAppName?.replacingOccurrences(of: "BTCN", with: "BTC")
        }.bind(to: self.navigationItem.rx.title).disposed(by: bag)
    }
    
    func showTransferAction() {
        let vc = LightTransferViewController.instance(from: LightTransferViewController.Config(asset: self.viewModel.input.asset.value, purpose: LightTransferViewController.Purpose.ifrcTransfer))
        self.navigationController?.pushViewController(vc)
    }
    func showDepositAction() {
        let viewModel = LightReceiptQRCodeViewModel.init(asset: self.viewModel.input.asset.value)
        let vc = LightReceiptQRCodeViewController.init(viewModel: viewModel)
        self.navigationController?.pushViewController(vc)
    }
}
