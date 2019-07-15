//
//  WalletsContainerViewController.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/6/14.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Cartography

enum WalletChildType {
    case mainChain
    case stableChain
    case stockCoin
}
final class WalletsContainerViewController: KLModuleViewController,KLVMVC {
    
    var viewModel: WalletsContainerViewModel!
    typealias ViewModel = WalletsContainerViewModel
    typealias Constructor = Void
    var childWalletsViewController:WalletsViewController!
    
    var bag: DisposeBag = DisposeBag()
    var selectedChild:WalletChildType = .mainChain
    func config(constructor: Void) {
        self.view.layoutIfNeeded()
        self.hideDefaultNavBar()
        self.navigationController?.isNavigationBarHidden = true

        self.viewModel = ViewModel.init(input: WalletsContainerViewModel.InputSource(), output: WalletsContainerViewModel.OutputSource())
        startMonitorThemeIfNeeded()
        startMonitorLangIfNeeded()
        self.bindUI()
        self.handleButtonSelection(childType: self.selectedChild)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var mainWalletBtn: UIButton!
    @IBOutlet weak var stableWalletBtn: UIButton!
    @IBOutlet weak var listWalletBtn: UIButton! {
        didSet {
            listWalletBtn.isHidden = true
        }
    }
    @IBOutlet weak var importWalletButton: UIButton!
    
    override func renderTheme(_ theme: Theme) {
        mainWalletBtn.set(textColor: .white, font: .owRegular(size:14), backgroundColor: .clear)
        stableWalletBtn.set(textColor: .white, font: .owRegular(size:14), backgroundColor: .clear)
        listWalletBtn.set(textColor: .white, font: .owRegular(size:14), backgroundColor: .clear)
        mainWalletBtn.setBackgroundImage(UIImage.init(color: theme.palette.bg_fill_new), for: .selected)
        stableWalletBtn.setBackgroundImage(UIImage.init(color: theme.palette.bg_fill_new), for: .selected)
        listWalletBtn.setBackgroundImage(UIImage.init(color: theme.palette.bg_fill_new), for: .selected)
    }
    override func renderLang(_ lang: Lang) {
        mainWalletBtn.setTitle(lang.dls.wallet_type_btn_main_chain, for: .normal)
        stableWalletBtn.setTitle(lang.dls.stable_coin, for: .normal)
        listWalletBtn.setTitle(lang.dls.sto_coin, for: .normal)
    }
    
    func bindUI() {
        self.mainWalletBtn.rx.klrx_tap.drive(onNext:{[unowned self] _ in
            if self.mainWalletBtn.isSelected {
                return
            }
            self.handleButtonSelection(childType: .mainChain)
        }).disposed(by: bag)
        self.stableWalletBtn.rx.klrx_tap.drive(onNext:{[unowned self] _ in
            if self.stableWalletBtn.isSelected {
                return
            }
            self.handleButtonSelection(childType: .stableChain)
        }).disposed(by: bag)
        self.listWalletBtn.rx.klrx_tap.drive(onNext:{[unowned self] _ in
            if self.listWalletBtn.isSelected {
                return
            }
            self.handleButtonSelection(childType: .stockCoin)
        }).disposed(by: bag)
        
        self.importWalletButton.rx.klrx_tap.drive(onNext: {[unowned self] _ in
//            let vc = xib(vc: ImportWalletTypeChooseViewController.self)
//            let nav = UINavigationController.init(rootViewController: vc)
            
            let vc = AddWalletViewController.navInstance()
            self.present(vc, animated: true, completion: nil)
        }).disposed(by: bag)
        
    }
    
    func handleButtonSelection(childType:WalletChildType) {
        switch childType {
        case .mainChain:
            self.mainWalletBtn.isSelected = true
            self.stableWalletBtn.isSelected = false
            self.listWalletBtn.isSelected = false
        case .stableChain:
            self.stableWalletBtn.isSelected = true
            self.mainWalletBtn.isSelected = false
            self.listWalletBtn.isSelected = false
        case .stockCoin:
            self.listWalletBtn.isSelected = true
            self.stableWalletBtn.isSelected = false
            self.mainWalletBtn.isSelected = false
        }
        self.selectedChild = childType
        self.configureChildView(childType: childType)
    }
    
    func configureChildView(childType:WalletChildType) {
        let coins = self.viewModel.getCoinsForChild(child:childType)
        let vc = WalletsViewController.instance(from: WalletsViewController.Config(coins: coins, assetSelected: {[unowned self] asset in
            self.toWalletDetail(asset: asset)
        }))
        if self.childViewControllers.count > 0 {
            _ = self.childViewControllers.map {
                willMove(toParentViewController: nil)
                $0.view.removeFromSuperview()
                $0.removeFromParentViewController()
            }
        }
        self.addChildViewController(vc)
        self.containerView.addSubview(vc.view)
        vc.didMove(toParentViewController: self)
        constrain(vc.view) { (v) in
            let s = v.superview!
            v.top == s.top
            v.bottom == s.bottom
            v.leading == s.leading
            v.trailing == s.trailing
        }
        self.childWalletsViewController = vc
    }
    
    func toWalletDetail(asset:Asset) {
        
        let source : MainWalletViewController.Source = {
            switch (asset.coin!.owChainType,self.selectedChild) {
        case (.btc,.mainChain):
            return MainWalletViewController.Source.BTC
        case (.eth,.mainChain):
            return MainWalletViewController.Source.ETH
        case (_,.stableChain):
                return MainWalletViewController.Source.StableCoin
        default:
            return MainWalletViewController.Source.BTC
            }
        }()
        
        let vc = MainWalletViewController.navInstance(from: MainWalletViewController.Config(entryPoint: .MainWallet, wallet: asset.wallet!, source:source))
        self.present(vc, animated: true, completion: nil)
    }
}
