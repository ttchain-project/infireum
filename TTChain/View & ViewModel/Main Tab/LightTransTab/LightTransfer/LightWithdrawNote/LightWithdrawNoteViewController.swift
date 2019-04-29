//
//  LightWithdrawNoteViewController.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/4/29.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class LightWithdrawNoteViewController: KLModuleViewController, KLVMVC {
   
    @IBOutlet weak var noteTitle: UILabel!
    @IBOutlet weak var noteTextField: UITextField!
    
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
    
    func config(constructor: LightWithdrawNoteViewController.Config) {
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
        noteTitle.text = dls.abInfo_label_note
        noteTextField.set(placeholder: dls.transfer_note_placeholder)
        
    }
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        view.backgroundColor = palette.bgView_sub
        noteTitle.set(textColor: palette.label_main_1, font: .owRegular(size: 17))
        noteTextField.set(textColor: palette.input_text, font: .owRegular(size: 17), placeHolderColor: palette.input_placeholder)
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
