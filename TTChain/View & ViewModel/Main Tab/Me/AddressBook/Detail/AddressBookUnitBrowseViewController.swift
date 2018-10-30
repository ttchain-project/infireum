//
//  AddressBookUnitBrowseViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/17.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class AddressBookUnitBrowseViewController: KLModuleViewController, KLVMVC {
    
    @IBOutlet weak var nameTitleLabel: UILabel!
    @IBOutlet weak var nameContentLabel: UILabel!
    @IBOutlet weak var nameSepline: UIView!
    
    @IBOutlet weak var noteTitleLabel: UILabel!
    @IBOutlet weak var noteContentLabel: UILabel!
    @IBOutlet weak var noteSepline: UIView!
    
    @IBOutlet weak var addressTitleLabel: UILabel!
    @IBOutlet weak var copyAddressBtn: UIButton!
    @IBOutlet weak var addressContentLabel: UILabel!
    @IBOutlet weak var addressSepline: UIView!
    
    struct Config {
        let unit: AddressBookUnit
    }
    
    typealias Constructor = Config
    typealias ViewModel = AddressBookUnitBrowseViewModel
    var viewModel: AddressBookUnitBrowseViewModel!
    var bag: DisposeBag = DisposeBag.init()
    func config(constructor: AddressBookUnitBrowseViewController.Config) {
        view.layoutIfNeeded()
        viewModel = ViewModel.init(
            input: AddressBookUnitBrowseViewModel.InputSource(
                unit: constructor.unit,
                copyAddrInput: copyAddressBtn.rx.tap.asDriver()
            ),
            output: ()
        )
        
        bindViewModel()
        
        startMonitorThemeIfNeeded()
        startMonitorLangIfNeeded()
    }
    
    override func renderLang(_ lang: Lang) {
        let dls = lang.dls
        title = dls.abInfo_title
        
        let mainCoinName = viewModel.input.unit.mainCoin!.inAppName!
        addressTitleLabel.text = dls.abInfo_label_address_type(mainCoinName)
        editBtn.setTitleForAllStates(dls.abInfo_btn_edit)
        
        nameTitleLabel.text = dls.abInfo_label_name
        noteTitleLabel.text = dls.abInfo_label_note
        
    }
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        changeBackBarButton(toColor: palette.nav_item_1, image: #imageLiteral(resourceName: "arrowNavBlack"), title: nil)
        renderNavBar(tint: palette.nav_item_1, barTint: palette.nav_bg_1)
        renderNavTitle(color: palette.nav_item_1, font: .owMedium(size: 18))
        changeNavShadowVisibility(true)
        
        editBtn.set(color: palette.nav_item_1, font: UIFont.owMedium(size: 18))
        nameTitleLabel.set(textColor: palette.label_main_1, font: .owRegular(size: 14))
        nameContentLabel.set(textColor: palette.label_main_1, font: .owRegular(size: 14))
        noteTitleLabel.set(textColor: palette.label_main_1, font: .owRegular(size: 14))
        noteContentLabel.set(textColor: palette.label_main_1, font: .owRegular(size: 14))
        addressTitleLabel.set(textColor: palette.label_main_1, font: .owRegular(size: 14))
        addressContentLabel.set(textColor: palette.label_main_1, font: .owRegular(size: 14))
        
        nameSepline.backgroundColor = palette.sepline
        noteSepline.backgroundColor = palette.sepline
        addressSepline.backgroundColor = palette.sepline
    }
    
    private func bindViewModel() {
        let unit = viewModel.unit
        unit.map {
            $0.name
        }
        .bind(to: nameContentLabel.rx.text)
        .disposed(by: bag)
        
        unit.map {
            $0.note
        }
        .bind(to: noteContentLabel.rx.text)
        .disposed(by: bag)
        
        unit.map {
            $0.address
        }
        .bind(to: addressContentLabel.rx.text)
        .disposed(by: bag)
        
        viewModel.onAddressCopied
            .drive(onNext: {
                [unowned self] in self.showAddrCopiedToast()
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
    
    private func showAddrCopiedToast() {
        EZToast.present(on: self, content: LM.dls.g_toast_addr_copied)
    }
    
    
    //MARK: - Edit
    private lazy var editBtn: UIButton = {
        return createRightBarButton(target: self, selector: #selector(toEdit), shouldClear: true, size: CGSize.init(width: 50, height: 44))
    }()
    
    @objc private func toEdit() {
        let vc = EditABUnitViewController.instance(from: EditABUnitViewController.Config(source: ABEditSourceType.abUnit(viewModel.getUnit()))
        )
        
        navigationController?.pushViewController(vc, animated: false)
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
