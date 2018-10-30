//
//  ChangePrefFiatViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/16.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ChangePrefFiatViewController: KLModuleViewController, KLVMVC {
    
    var bag: DisposeBag = DisposeBag.init()
    struct Config {
        let identity: Identity
    }
    
    typealias Constructor = Config
    typealias ViewModel = ChangePrefFiatViewModel
    var viewModel: ChangePrefFiatViewModel!
    
    private lazy var saveBtn: UIButton = {
        return createRightBarButton(
            target: self,
            selector: #selector(saveFiatSelection),
            shouldClear: true,
            size: CGSize.init(width: 50, height: 44)
        )
    }()
    
    func config(constructor: ChangePrefFiatViewController.Constructor) {
        view.layoutIfNeeded()
        setupTableView()
        viewModel = ViewModel.init(
            input: ChangePrefFiatViewModel.InputSource(
                identity: constructor.identity, fiatSelectInput: tableView.rx.modelSelected(Fiat.self).asDriver()
            ),
            output: ()
        )
        
        bindViewModel()
        
        startMonitorThemeIfNeeded()
        startMonitorLangIfNeeded()
    }
    
    override func renderLang(_ lang: Lang) {
        let dls = lang.dls
        title = dls.changePrefFiat_title
        saveBtn.setTitleForAllStates(dls.changePrefFiat_btn_save)
    }
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        renderNavBar(tint: palette.nav_item_1, barTint: palette.nav_bg_1)
        renderNavTitle(color: palette.nav_item_1, font: .owMedium(size: 18))
        changeBackBarButton(toColor: palette.nav_item_1, image: #imageLiteral(resourceName: "arrowNavBlack"), title: nil)
        changeNavShadowVisibility(true)
        saveBtn.set(color: palette.nav_item_1, font: UIFont.owRegular(size: 16))
        
        view.backgroundColor = palette.bgView_sub
    }
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupTableView() {
        tableView.register(SelectFiatTableViewCell.nib, forCellReuseIdentifier: SelectFiatTableViewCell.cellIdentifier())
        tableView.separatorStyle = .none
    }
    
    private func bindViewModel() {
        viewModel.fiats.bind(to: tableView.rx.items(cellIdentifier: SelectFiatTableViewCell.cellIdentifier(), cellType: SelectFiatTableViewCell.self)) {
            [unowned self]
            row, fiat, cell in
            cell.config(fiat: fiat, isSelected: self.viewModel.isFiatSelected(fiat))
        }
        .disposed(by: bag)
        
        viewModel.selectedFiat.subscribe(onNext: { [unowned self] _ in self.tableView.reloadData() }).disposed(by: bag)
    }
    
    @objc private func saveFiatSelection() {
        viewModel.save()
        pop(sender: nil)
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
