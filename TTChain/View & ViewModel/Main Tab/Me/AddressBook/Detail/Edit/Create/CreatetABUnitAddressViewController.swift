//
//  CreatetABUnitAddressViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/17.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class CreatetABUnitAddressViewController: KLModuleViewController, KLVMVC {
    
    @IBOutlet weak var addIcon: UIImageView!
    @IBOutlet weak var addLabel: UILabel!
    @IBOutlet weak var sepline: UIView!
    
    public var onChooseAddUnitOfMainCoin: Driver<Coin> {
        return view.rx.klrx_tap.flatMapLatest {
                [unowned self] in self.startChooseMainCoin()
            }
            .filter { $0 != nil }
            .map { $0! }
    }
    
    private func startChooseMainCoin() -> Driver<Coin?> {
        return Observable<Coin?>.create({ [unowned self] (observer) -> Disposable in
            //Change to dynamic source
            let dls = LM.dls
            let actionSheet = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
            let allMainCoins = MainCoinTypStorage.supportMainCoinIDs.compactMap { Coin.getCoin(ofIdentifier: $0) }
            
            for coin in allMainCoins {
                autoreleasepool {
                    let action = UIAlertAction.init(
                        title: dls
                            .ab_update_actionsheet_createAddress_general(
                                coin.inAppName!
                            ),
                        style: .default,
                        handler: {
                            _ in
                            observer.onNext(coin)
                        }
                    )
                    
                    actionSheet.addAction(action)
                }
            }
            
            let cancel = UIAlertAction.init(
                title: dls.g_cancel,
                style: .cancel,
                handler: { (_) in
                    observer.onNext(nil)
                })
            
            actionSheet.addAction(cancel)
            
            self.parent?.present(actionSheet, animated: true, completion: nil)
            return Disposables.create()
        }).asDriver(onErrorJustReturn: nil)
    }
    
    typealias Constructor = Void
    typealias ViewModel = CreatetABUnitAddressViewModel
    var viewModel: CreatetABUnitAddressViewModel!
    var bag: DisposeBag = DisposeBag.init()
    func config(constructor: Void) {
        view.layoutIfNeeded()
        viewModel = ViewModel.init(input: (), output: ())
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
    }
    
    override func renderLang(_ lang: Lang) {
        addLabel.text = lang.dls.ab_update_label_createAddress
    }

    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        addLabel.set(textColor: palette.application_main, font: .owRegular(size: 14))
        sepline.backgroundColor = palette.sepline
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
