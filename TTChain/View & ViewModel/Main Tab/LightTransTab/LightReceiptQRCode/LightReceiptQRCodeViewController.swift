//
//  LightReceiptQRCodeViewController.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/4/25.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class LightReceiptQRCodeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()

        self.saveButton.rx.klrx_tap.drive(onNext:{ [unowned self] _ in
            self.copuButton.isHidden = true

            guard let snapshot = self.qrcodeImageView.superview?.screenshot else {
                self.copuButton.isHidden = false
                return
            }
            self.copuButton.isHidden = false
            ImageSaver.saveImage(image: snapshot, onViewController: self).subscribe(onSuccess: { _ in
            },onError:{ error in
                DLogInfo(error)
            }).disposed(by: self.bag)
        }).disposed(by: bag)
    }

    @IBOutlet weak var coinIcon: UIImageView!  {
        didSet {
            coinIcon.image = self.viewModel.input.asset.coin?.iconImg
        }
    }
    @IBOutlet weak var lightTransferLabel: UILabel! {
        didSet {
            if self.viewModel.input.asset.wallet?.walletMainCoinID == Coin.ttn_identifier {
                lightTransferLabel.text = LM.dls.lightningTx_title
            }else {
                lightTransferLabel.text = self.viewModel.input.asset.wallet?.name
            }
        }
    }
    @IBOutlet weak var addressLabel: UILabel! {
        didSet {
            self.viewModel.selectedAsset.map { $0.wallet?.address }.bind(to: addressLabel.rx.text).disposed(by: bag)
        }
    }
    @IBOutlet weak var copuButton: UIButton! {
        didSet {
            copuButton.rx.klrx_tap.asDriver().drive(onNext: { _ in
                UIPasteboard.general.string = self.viewModel.input.asset.wallet?.address ?? ""
               self.view.makeToast(LM.dls.g_toast_addr_copied)
            }).disposed(by: bag)
        }
    }
    @IBOutlet weak var qrcodeImageView: UIImageView! {
        didSet {
            viewModel.qrCode.bind(to: qrcodeImageView.rx.image).disposed(by: bag)
        }
    }
    
    @IBOutlet weak var saveButton: UIButton! {
        didSet {
            saveButton.backgroundColor = .creamCan
        }
    }
    
    var bag:DisposeBag = DisposeBag.init()
    
    var viewModel:LightReceiptQRCodeViewModel
    init(viewModel:LightReceiptQRCodeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: LightReceiptQRCodeViewController.className, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.setGradientColor(color1: UIColor.init(red: 44, green: 60, blue: 78)?.cgColor, color2: UIColor.init(red: 24, green: 34, blue: 39)?.cgColor)
    }
    
    func setupView() {
        let pallete = ThemeManager.palette
        self.lightTransferLabel.set(textColor: .black, font: .owMedium(size:16))
        self.addressLabel.set(textColor: UIColor.owWarmGrey, font: .owMedium(size:11))
        renderNavTitle(color: pallete.nav_item_2, font: .owMedium(size: 20))
        changeBackBarButton(toColor: pallete.nav_item_2, image: #imageLiteral(resourceName: "btn_previous_light"))
        createRightBarButton(target: self, selector: #selector(startSharing), image: #imageLiteral(resourceName: "btnNavShareNormal"), title: nil, toColor: pallete.nav_item_2, shouldClear: true)
        self.navigationItem.title = LM.dls.walletOverview_btn_deposit
    }
    
    @objc private func startSharing() {
        self.copuButton.isHidden = true
        guard let img = self.qrcodeImageView.superview?.screenshot else {
            self.copuButton.isHidden = false

            return
        }
        self.copuButton.isHidden = false

        let activityVC = UIActivityViewController.init(activityItems: [img], applicationActivities: nil)
        present(activityVC, animated: true, completion: nil)
    }
}
