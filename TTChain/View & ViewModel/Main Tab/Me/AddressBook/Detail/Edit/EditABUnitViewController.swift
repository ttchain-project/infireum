//
//  EditABUnitViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/17.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Cartography

final class EditABUnitViewController: KLModuleViewController, KLVMVC {
    
    struct Config {
        let source: ABEditSourceType
    }
    
    typealias Constructor = Config
    typealias ViewModel = EditABUnitViewModel
    var viewModel: EditABUnitViewModel!
    var bag: DisposeBag = DisposeBag.init()
    
    private func createChildVC(with constructor: Config) {
        createVC = CreatetABUnitAddressViewController.instance()
        updateVC = UpdatetABUnitAddressViewController.instance(from: UpdatetABUnitAddressViewController.Config(source: constructor.source))
        deleteVC = DeletetABUnitAddressViewController.instance()
        
        addChildViewController(createVC)
        createVC.didMove(toParentViewController: self)
        updateBase.addSubview(createVC.view)
        
        constrain(createVC.view) { (view) in
            view.edges == view.superview!.edges
        }
        
        addChildViewController(updateVC)
        updateVC.didMove(toParentViewController: self)
        updateBase.addSubview(updateVC.view)
        
        constrain(updateVC.view) { (view) in
            view.edges == view.superview!.edges
        }
        
        addChildViewController(deleteVC)
        deleteVC.didMove(toParentViewController: self)
        deleteBase.addSubview(deleteVC.view)
        
        constrain(deleteVC.view) { (view) in
            view.edges == view.superview!.edges
        }
        
        switch constructor.source {
        case .abUnit:
            createVC.view.isHidden = true
        case .plain:
            updateVC.view.isHidden = true
            deleteVC.view.isHidden = true
        case .scannedSource:
            createVC.view.isHidden = true
        }
    }
    
    func config(constructor: EditABUnitViewController.Config) {
        view.layoutIfNeeded()
        createChildVC(with: constructor)
        viewModel = ViewModel.init(
            input: EditABUnitViewModel.InputSource(
                source: constructor.source,
                nameInout: nameTextField.rx.text,
                noteInout: noteTextField.rx.text,
                addressInput: updateVC.viewModel.address
            ),
            output: ()
        )
        
        bindChildVCActions()
        bindViewModel()
        
        startMonitorThemeIfNeeded()
        startMonitorLangIfNeeded()
    }
    
    private func bindViewModel() {
        viewModel.isAllFieldsHasValue.bind(to: saveBtn.rx.isEnabled).disposed(by: bag)
    }
    
    override func renderLang(_ lang: Lang) {
        let dls = lang.dls
        switch viewModel.input.source {
        case .abUnit:
            title = dls.ab_update_title_edit
        case .plain, .scannedSource:
            title = dls.ab_update_title_create
        }
        
        nameTextField.set(placeholder: dls.ab_update_placeholder_name)
        noteTextField.set(placeholder: dls.ab_update_placeholder_note)
        saveBtn.setTitleForAllStates(dls.ab_update_btn_save)
    }
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        renderNavTitle(color: palette.nav_item_1, font: .owMedium(size: 18))
        renderNavBar(tint: palette.nav_item_1, barTint: palette.nav_bg_1)
        if navigationController?.viewControllers.first == self {
            changeLeftBarButtonToDismissToRoot(tintColor: palette.nav_item_1, image: #imageLiteral(resourceName: "arrowNavBlack"), title: nil)
        }else {
            changeBackBarButton(toColor: palette.nav_item_1, image: #imageLiteral(resourceName: "arrowNavBlack"), title: nil)
        }
        
        changeNavShadowVisibility(true)
        saveBtn.set(color: palette.nav_item_1, font: UIFont.owRegular(size: 18))
        
        nameTextField.sepline.backgroundColor = palette.sepline
        noteTextField.sepline.backgroundColor = palette.sepline
        nameTextField.sepInset = 8
        noteTextField.sepInset = 8
        
        nameTextField.set(textColor: palette.input_text, font: .owRegular(size: 14), placeHolderColor: palette.input_placeholder)
        noteTextField.set(textColor: palette.input_text, font: .owRegular(size: 14), placeHolderColor: palette.input_placeholder)
    }
    
    private lazy var saveBtn: UIButton = {
        return createRightBarButton(target: self, selector: #selector(save), shouldClear: true, size: CGSize.init(width: 50, height: 44))
    }()
    
    @objc private func save() {
        guard let addressInfo = updateVC.viewModel.getAddressInfo() else {
            return errorDebug(response: ())
        }
        
        hud.updateType(.spinner, text: LM.dls.ab_update_hud_saving)
        hud.startAnimating(inView: self.view)
        viewModel.save(mainCoinID: addressInfo.mainCoinID, address: addressInfo.addr)
            .subscribe(onSuccess: { [unowned self] (result) in
                self.hud.stopAnimating()
                switch result {
                case .success:
                    if self.navigationController?.viewControllers.first == self {
                        self.dismiss(animated: true, completion: nil)
                    }else {
                        self.pop(sender: nil)
                    }
                case .failed(error: let err):
                    self.showAPIErrorResponsePopUp(from: err,
                                                   cancelTitle: LM.dls.g_cancel)
                }
            })
            .disposed(by: bag)
    }
    
    private lazy var hud: KLHUD = {
        return KLHUD.init(type: .spinner,
                          frame: CGRect.init(origin: .zero,
                                             size: CGSize.init(width: 100, height: 100)
                                            )
                         )
    }()
    
    private func bindChildVCActions() {
        createVC.onChooseAddUnitOfMainCoin.drive(onNext: {
            [unowned self] coin in
            self.createVC.view.isHidden = true
            self.updateVC.view.isHidden = false
            self.updateVC.viewModel.updateMainCoinID(to: coin.walletMainCoinID!)
        })
            .disposed(by: bag)
        
        updateVC.finishClearAddr.subscribe(onNext: {
            [unowned self] in
            self.createVC.view.isHidden = false
            self.updateVC.view.isHidden = true
        })
            .disposed(by: bag)
        
        deleteVC.deleteRequest
            .asObservable()
            .flatMapLatest {
                [unowned self] _ -> RxAPIVoidResponse in
                self.hud.updateType( .spinner, text: LM.dls.ab_update_hud_saving)
                self.hud.startAnimating(inView: self.view)
                return self.viewModel.delete()
            }
            .subscribe(onNext: {
                [unowned self]
                result in
                self.hud.stopAnimating()
                switch result {
                case .failed(error: let err):
                    self.showAPIErrorResponsePopUp(from: err,
                                                   cancelTitle: LM.dls.g_cancel)
                case .success:
                    if self.navigationController?.viewControllers.first == self {
                        self.dismiss(animated: true, completion: nil)
                    }else {
                        self.popToRoot(sender: nil)
                    }
                }
            })
            .disposed(by: bag)
    }
    
    @IBOutlet weak var nameTextField: OWInputTextField!
    @IBOutlet weak var noteTextField: OWInputTextField!
    @IBOutlet weak var updateBase: UIView!
    @IBOutlet weak var deleteBase: UIView!
    
    private var createVC: CreatetABUnitAddressViewController!
    private var updateVC: UpdatetABUnitAddressViewController!
    private var deleteVC: DeletetABUnitAddressViewController!
        
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
