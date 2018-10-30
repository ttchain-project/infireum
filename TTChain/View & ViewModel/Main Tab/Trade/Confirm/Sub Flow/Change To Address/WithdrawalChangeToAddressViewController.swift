//
//  WithdrawalChangeToAddressViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/15.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class WithdrawalChangeToAddressViewController: KLModuleViewController, KLVMVC {
    
    @IBOutlet weak var addressBase: UIView!
    @IBOutlet weak var addressTitleLabel: UILabel!
    @IBOutlet weak var addressbookBtn: UIButton!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var addressCheck: UIImageView!
    @IBOutlet weak var addressSepline: UIView!
    
    @IBOutlet weak var walletBase: UIView!
    @IBOutlet weak var walletTitleLabel: UILabel!
    @IBOutlet weak var walletTableView: UITableView!
    
    struct Config {
        let source: LightningTransRecordCreateSource
    }
    
    private lazy var qrCodeBtn: UIButton = {
        return createRightBarButton(target: self, selector: #selector(toQRCode), image: #imageLiteral(resourceName: "btnNavScannerqrNormal"), shouldClear: true)
    }()
    
    typealias Constructor = Config
    typealias ViewModel = WithdrawalChangeToAddressViewModel
    var viewModel: WithdrawalChangeToAddressViewModel!
    var bag: DisposeBag = DisposeBag.init()
    var sourceConfirm: Observable<ToAddressSource> {
        return _sourceConfirm.asObservable()
    }
    
    private let _sourceConfirm: PublishRelay<ToAddressSource> = PublishRelay.init()
    deinit {
        if let source = viewModel.getSelectedSource() {
            _sourceConfirm.accept(source)
        }
    }
    
    func config(constructor: WithdrawalChangeToAddressViewController.Config) {
        view.layoutIfNeeded()
        setupTableView()
        viewModel = ViewModel.init(
            input: WithdrawalChangeToAddressViewModel.InputSource(
                source: constructor.source,
                walletSelect: walletTableView.rx.modelSelected(Wallet.self).asDriver(),
                addressInout: addressTextField.rx.text,
                toAddressBookInput: addressbookBtn.rx.tap.asDriver(),
                toQRCodeScannerInput: qrCodeBtn.rx.tap.asDriver()
            ),
            output: ()
        )
        
        bindViewModel()
        
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
    }
    
    private func setupTableView() {
        walletTableView.register(WithdrawalConfirmChangeWalletTableViewCell.nib, forCellReuseIdentifier: WithdrawalConfirmChangeWalletTableViewCell.cellIdentifier())
        walletTableView.separatorStyle = .none
    }
    
    override func renderLang(_ lang: Lang) {
        let dls = lang.dls
        title = dls.ltTx_changeToAddress_title
        addressTitleLabel.text = dls.ltTx_changeToAddress_label_toAddress
        addressbookBtn.set(image: #imageLiteral(resourceName: "arrowNavBlue"),
                           title: dls.ltTx_changeToAddress_btn_common_used_addr,
                           titlePosition: .left,
                           additionalSpacing: 8,
                           state: .normal)
        
        let coin = viewModel.input.source.to.toCoin
        addressTextField.set(placeholder: dls.ltTx_changeToAddress_placeholder_input_valid_addr(coin!.fullname!)
        )
        
        walletTitleLabel.text = dls.ltTx_changeToAddress_label_toWallet
    }
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        
        view.backgroundColor = palette.bgView_sub
        
        renderNavBar(tint: palette.nav_item_1, barTint: palette.nav_bg_1)
        renderNavTitle(color: palette.nav_item_1, font: .owMedium(size: 18))
        changeLeftBarButtonToDismissToRoot(tintColor: palette.nav_item_1, image: #imageLiteral(resourceName: "arrowNavBlack"), title: nil)
        qrCodeBtn.set(color: palette.application_main)
        changeNavShadowVisibility(true)
        
        addressTitleLabel.set(textColor: palette.label_main_1, font: .owRegular(size: 14))
        addressbookBtn.set(color: palette.application_main, font: UIFont.owRegular(size: 12), image: #imageLiteral(resourceName: "arrowNavBlue"))
        addressbookBtn.set(image: #imageLiteral(resourceName: "arrowNavBlue"), title: nil, titlePosition: .left, additionalSpacing: 8, state: .normal)
        
        addressTextField.set(textColor: palette.input_text, font: .owRegular(size: 13), placeHolderColor: palette.input_placeholder)
        addressSepline.backgroundColor = palette.sepline
        
        walletTitleLabel.set(textColor: palette.label_main_1, font: .owRegular(size: 14))
    }
    
    private func bindViewModel() {
        viewModel.wallets.bind(to: walletTableView.rx.items(cellIdentifier: WithdrawalConfirmChangeWalletTableViewCell.cellIdentifier(), cellType: WithdrawalConfirmChangeWalletTableViewCell.self)) {
            [unowned self]
            row, wallet, cell in
            guard let asset = self.viewModel.getAssetToDisplayFromWallet(wallet) else { return }
            let isSelected = self.viewModel.isWalletSelected(wallet)
            cell.config(asset: asset, isUsable: true, isSelected: isSelected)
        }
        .disposed(by: bag)
        
        addressTextField.rx.controlEvent(UIControlEvents.editingDidBegin).subscribe(onNext: {
            [unowned self] _ in
            if let str = self.addressTextField.text, str.count > 0 {
                self.viewModel.updateRemoteAddress(str)
            }
        })
        .disposed(by: bag)
        
        viewModel.selectedSource.map {
            source -> Bool in
            switch source {
            case .local: return true
            case .remote: return false
            }
        }
        .bind(to: addressCheck.rx.isHidden)
        .disposed(by: bag)
        
        viewModel.selectedSource
            .subscribe(onNext: {
                [unowned self]
                _ in
                self.walletTableView.reloadData()
            })
            .disposed(by: bag)
        
        viewModel.onChooseAddressFromAddressbook
            .drive(onNext:{
                [unowned self] mainCoinID in
                self.toAddressbook(mainCoinID: mainCoinID)
            })
            .disposed(by: bag)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Route
    private func toAddressbook(mainCoinID: String) {
        let nav = AddressBookViewController.navInstance(from: AddressBookViewController.Config(
                identity: Identity.singleton!,
                purpose: .select(targetMainCoinID: mainCoinID)
            )
        )
        
        if let vc = nav.viewControllers[0] as? AddressBookViewController  {
            vc.onSelect.subscribe(onNext: {
                [unowned self] unit in
                nav.dismiss(animated: true, completion: nil)
                self.viewModel
                    .updateRemoteAddress(unit.address!)
            })
            .disposed(by: bag)
        }
        
        present(nav, animated: true, completion: nil)
    }
    
    @objc private func toQRCode() {
        let source = viewModel.input.source
        let mainCoinID = source.to.toCoin!.walletMainCoinID!
        let vc = OWQRCodeViewController.navInstance(
            from: OWQRCodeViewController._Constructor(
                purpose: .withdrawal(mainCoinID),
                resultCallback: { [unowned self] (result, purpose, scanningType) in
                    switch result {
                    case .address(let addr, chainType: _, coin: let coin, amt: _):
                        // Ensure the source qrcode is from the same coin
                        if let detectedCoin = coin {
                            //This ensure that the chain of detected address is same as the chain we want to transfer to.
                            guard detectedCoin.walletMainCoinID == source.to.toCoin?.walletMainCoinID else {
                                return
                            }
                        }
                        
                        self.viewModel.updateRemoteAddress(addr)
                        self.navigationController?
                            .presentedViewController?
                            .dismiss(animated: true, completion: nil)
                        
                    default: break
                    }
                },
                isTypeLocked: true
            )
        )
        
        present(vc, animated: true, completion: nil)
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
