//
//  UpdatetABUnitAddressViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/17.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class UpdatetABUnitAddressViewController: KLModuleViewController, KLVMVC {

    struct Config {
        let source: ABEditSourceType
    }
    
    typealias Constructor = Config
    typealias ViewModel = UpdatetABUnitAddressViewModel
    var viewModel: UpdatetABUnitAddressViewModel!
    var bag: DisposeBag = DisposeBag.init()
    
    var finishClearAddr: Observable<Void> {
        return _finishClearAddr.asObservable()
    }
    
    private var _finishClearAddr: PublishRelay<Void> = PublishRelay.init()
    
    func config(constructor: UpdatetABUnitAddressViewController.Config) {
        view.layoutIfNeeded()
        viewModel = ViewModel.init(input: UpdatetABUnitAddressViewModel.InputSource(sourceType: constructor.source, addressInout: addrTextView.rx.text), output: ()
        )
        
        bindViewModel()
        bindBtnAction()
        startMonitorThemeIfNeeded()
        startMonitorLangIfNeeded()
    }
    
    private func bindBtnAction() {
        clearBtn.rx.tap.subscribe(onNext: {
            [unowned self] in self.showClearAlert()
        })
        .disposed(by: bag)
        
        qrCodeScanBtn.rx.tap.asDriver()
            .drive(onNext: {
                [unowned self] in
                self.presentQRCode()
            })
            .disposed(by: bag)
    }
    
    private func bindViewModel() {
        viewModel.mainCoin.map { $0.inAppName! + ":" }
            .bind(to: chainTypeLabel.rx.text)
            .disposed(by: bag)
        
        addrTextView.rx.text.map { $0?.count ?? 0 }.map { $0 > 0 }.bind(to: addrPlaceholderLabel.rx.isHidden).disposed(by: bag)
    }
    
    override func renderLang(_ lang: Lang) {
        addrPlaceholderLabel.text = lang.dls.ab_update_placeholder_input_valid_address
    }
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        addrTextView.textColor = palette.input_text
        addrTextView.font = UIFont.owRegular(size: 13)
        
        addrPlaceholderLabel.set(textColor: palette.input_placeholder, font: .owRegular(size: 13))
        
        chainTypeLabel.set(textColor: palette.label_main_1, font: .owRegular(size: 14))
        
        seplines.forEach { (sepline) in
            sepline.backgroundColor = palette.sepline
        }
    }
    
    @IBOutlet weak var clearBtn: UIButton!
    @IBOutlet weak var chainTypeLabel: UILabel!
    @IBOutlet var seplines: [UIView]!
    
    @IBOutlet weak var addrTextView: UITextView!
    @IBOutlet weak var addrPlaceholderLabel: UILabel!
    @IBOutlet weak var qrCodeScanBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        addrTextView.textContainerInset = .zero
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func showClearAlert() {
        let dls = LM.dls
        let alert = UIAlertController.init(
            title: dls.ab_update_alert_confirm_delete_address_title,
            message: nil,
            preferredStyle: .alert
        )
        
        let cancel = UIAlertAction.init(title: dls.g_cancel,
                                        style: .cancel,
                                        handler: nil)
        
        let confirm = UIAlertAction.init(title: dls.g_confirm,
                                         style: .default) {
            [unowned self] (_) in
            self.viewModel.deleteAddressInfo()
            self._finishClearAddr.accept(())
        }
        
        alert.addAction(cancel)
        alert.addAction(confirm)
        
        parent?.present(alert, animated: true, completion: nil)
    }
    
    private var qrCodeVC: UINavigationController?
    private func presentQRCode() {
        qrCodeVC = OWQRCodeViewController.navInstance(
            from: OWQRCodeViewController._Constructor(
                purpose: .addContacts(viewModel.getMainCoinID()),
                resultCallback: { [unowned self] (result, purpose, scanningType) in
                    switch result {
                    case .address(let addr, chainType: _, coin: _, amt: _):
                        self.viewModel.updateAddress(to: addr)
                        self.qrCodeVC?.dismiss(animated: true, completion: {
                            self.qrCodeVC = nil
                        })
                    default: break
                    }
                },
                isTypeLocked: true
            )
        )
        
        parent?.present(qrCodeVC!, animated: true, completion: nil)
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
