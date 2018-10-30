//
//  WithdrawalRemarksViewController.swift
//  OfflineWallet
//
//  Created by Ajinkya Sharma on 2018/10/9.
//  Copyright © 2018 gib. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

final class WithdrawalRemarksViewController: KLModuleViewController, KLVMVC {
    
    
    typealias ViewModel = WithdrawalRemarkViewModel
    var viewModel: WithdrawalRemarkViewModel!

    var bag =  DisposeBag.init()
    
    struct Config{
        
    }
    typealias Constructor = Config
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    var preferedHeight: CGFloat {
        return view.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var noteTextField: UITextField!
    
    func config(constructor: WithdrawalRemarksViewController.Config) {
        view.layoutIfNeeded()

        viewModel = ViewModel.init(
            input: WithdrawalRemarkViewModel.InputSource(remarkInOut: noteTextField.rx.text),
            output: ()
        )
        
        startMonitorThemeIfNeeded()
        startMonitorLangIfNeeded()


    }
    
    override func renderLang(_ lang: Lang) {
        let dls = lang.dls
        titleLabel.text = dls.abInfo_label_note
        noteTextField.set(placeholder: "请输入20字以内的描述")
    }
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        view.backgroundColor = palette.bgView_main
        titleLabel.set(textColor: palette.label_main_1, font: .owRegular(size: 14))
        noteTextField.set(textColor: palette.input_text, font: .owRegular(size: 13), placeHolderColor: palette.input_placeholder)
        noteTextField.rx.text.orEmpty
            .scan("") { (previous, new) -> String in
                if new.count > 30 {
                    return previous ?? String(new.prefix(30))
                } else if new.contains("\n"){
                    return previous ?? String(new.prefix(30))
                }else {
                    return new
                }
            }.subscribe(noteTextField.rx.text)
            .disposed(by: bag)
    }
    
}

extension WithdrawalRemarksViewController : UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
}
