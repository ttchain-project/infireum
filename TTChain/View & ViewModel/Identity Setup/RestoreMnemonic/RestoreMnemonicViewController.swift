//
//  RestoreMnemonicViewController.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/7/16.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class RestoreMnemonicViewController: KLModuleViewController,KLVMVC {
    var viewModel: RestoreMnemonicViewModel!
    
    
    enum Direction { case left, right }

    typealias ViewModel = RestoreMnemonicViewModel
    
    var bag: DisposeBag = DisposeBag()
    
    typealias Constructor = Void
    
    func config(constructor: Void) {
        self.view.layoutIfNeeded()
      
        self.viewModel = RestoreMnemonicViewModel.init(input: RestoreMnemonicViewModel.Input(), output: RestoreMnemonicViewModel.Output())
        self.startMonitorLangIfNeeded()
        self.startMonitorThemeIfNeeded()
        self.bindUI()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    @IBOutlet weak var backButton: UIButton! {
        didSet {
            
        }
    }
    @IBOutlet weak var nextButton: UIButton! {
        didSet {
            
        }
    }
    @IBOutlet var mnemonicFields: [OWInputTextField]!
    var textFieldsIndexes:[UITextField:Int] = [:]
    
    func setNextResponder(_ index:Int?, direction:Direction) {
        guard let index = index else { return }
        if direction == .left {
            index == 0 ?
                (_ = mnemonicFields.first?.resignFirstResponder()) :
                (_ = mnemonicFields[(index - 1)].becomeFirstResponder())
        } else {
            index == mnemonicFields.count - 1 ?
                (_ = mnemonicFields.last?.resignFirstResponder()) :
                (_ = mnemonicFields[(index + 1)].becomeFirstResponder())
        }
    }
    
    override func renderTheme(_ theme: Theme) {
        self.hideDefaultNavBar()
        nextButton.set(
            font: UIFont.owRegular(size: 14),
            backgroundColor: theme.palette.btn_bgFill_enable_bg
        )
        
        for index in 0 ..< mnemonicFields.count {
            textFieldsIndexes[mnemonicFields[index]] = index
            let tx = mnemonicFields[index]
            tx.delegate = self
            tx.set(textColor: theme.palette.input_text, font: .owRegular(size: 14), placeHolderColor: theme.palette.input_placeholder)
            tx.sepline.backgroundColor = .gray
        }
        
        nextButton.setTitleColor(theme.palette.btn_bgFill_enable_text, for: .normal)
        nextButton.setTitleColor(theme.palette.btn_bgFill_disable_text, for: .disabled)
        titleLabel.set(textColor: theme.palette.label_main_1, font: .owRegular(size: 14))
        subtitleLabel.set(textColor: theme.palette.label_main_1, font: .owRegular(size: 12))
    }
    override func renderLang(_ lang: Lang) {
        
        backButton.setTitleForAllStates(lang.dls.g_cancel)
        nextButton.setTitleForAllStates(lang.dls.g_next)
        titleLabel.text = lang.dls.sign_in_using_mnemonic_title
        subtitleLabel.text = lang.dls.sign_in_mnemonic_subtitle
    }

    func bindUI() {
        self.backButton.rx.klrx_tap.drive(onNext:{ _ in
            if (self.presentingViewController != nil) || (self.navigationController?.presentingViewController?.presentedViewController == self.navigationController) {
                self.dismiss(animated: true, completion: nil)
            }else {
                self.navigationController?.popViewController(animated: true)
            }
        }).disposed(by: bag)
        
        self.nextButton.rx.klrx_tap.drive(onNext:{ _ in
            
            let mnemonicString = self.mnemonicFields!.reduce("") { $0 + " " + ($1.text ?? "") }.removingPrefix(" ")
            self.viewModel.createWalletWithMnemonics(mnemonicString)
        }).disposed(by: bag)
        
        self.viewModel.output.errorMessageSubject.bind(to:self.rx.message).disposed(by:bag)
        self.viewModel.output.mnemonicValidated.subscribe(onNext:{ [weak self] mnemonic in
            self?.toIdentityRestore(mnemonic)
        }).disposed(by: bag)
    }
    
    func toIdentityRestore(_ mnemonic:String) {
        let vc = IdentityRestoreViewController.instance(from: IdentityRestoreViewController.Config(mnemonic: mnemonic))
        self.navigationController?.pushViewController(vc)
    }
}

extension RestoreMnemonicViewController:UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        var replacementStr = string
        //Currently this logic is not being used
//        if string.count > 1 {
//            replacementStr = string.firstCharacterAsString ?? ""
//        }
//        if range.length == 0 {
//            textField.text = replacementStr
////            setNextResponder(textFieldsIndexes[textField], direction: .right)
//       } else if range.length == 1 {
//            textField.text = replacementStr
//            if replacementStr.isEmpty {
//                setNextResponder(textFieldsIndexes[textField], direction: .left)
//            }else {
////                setNextResponder(textFieldsIndexes[textField], direction: .right)
//            }
//        }
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let tf = textField as? OWInputTextField else {
            return
        }
        tf.sepline.backgroundColor = .yellowGreen
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let tf = textField as? OWInputTextField else {
            return
        }
        tf.sepline.backgroundColor = (tf.text ?? "").count > 0 ? .yellowGreen : .gray
    }
}
