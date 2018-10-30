//
//  DeletetABUnitAddressViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/17.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class DeletetABUnitAddressViewController: KLModuleViewController, KLVMVC {
    
    typealias Constructor = Void
    typealias ViewModel = DeleteABUnitViewModel
    var viewModel: DeleteABUnitViewModel!
    var bag: DisposeBag = DisposeBag.init()
    
    func config(constructor: Void) {
        view.layoutIfNeeded()
        viewModel = ViewModel.init(input: (), output: ())
        startMonitorThemeIfNeeded()
        startMonitorLangIfNeeded()
    }
    
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var sepline: UIView!
    
    var deleteRequest: Driver<Void> {
        return deleteBtn.rx.tap.asDriver().flatMapLatest {
            [unowned self] in self.confirmDelete().asDriver(onErrorJustReturn: false)
        }
            .filter { $0 }
            .map { _ in () }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        deleteBtn.set(color: palette.application_alert, font: UIFont.owRegular(size: 17))
        sepline.backgroundColor = palette.sepline
    }
    
    override func renderLang(_ lang: Lang) {
        deleteBtn.setTitleForAllStates(lang.dls.ab_update_btn_delete_addressbook)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func confirmDelete() -> Observable<Bool> {
        return Observable.create({[unowned self] (observer) -> Disposable in
            let dls = LM.dls
            let alert = UIAlertController.init(
                title: dls.ab_update_alert_confirm_delete_addressbook_title,
                message: nil,
                preferredStyle: .alert
            )
            let cancel = UIAlertAction.init(title: dls.g_cancel,
                                            style: .cancel,
                                            handler: { (_) in
                                                observer.onNext(false)
                                            })
            
            let delete = UIAlertAction.init(title: dls.g_confirm,
                                            style: .destructive,
                                            handler: { (_) in
                                                observer.onNext(true)
                                            })
            
            alert.addAction(cancel)
            alert.addAction(delete)
            
            self.parent?.present(alert, animated: true, completion: nil)
            
            return Disposables.create()
        })
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
