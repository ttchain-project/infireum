//
//  AddressBookViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/17.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class AddressBookViewController: KLModuleViewController, KLVMVC {
    
    enum Purpose {
        case browse
        case select(targetMainCoinID: String?)
        var limitMainCoinID: String? {
            switch self {
            case .browse: return nil
            case .select(targetMainCoinID: let mainCoinID): return mainCoinID
            }
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!
    
    struct Config {
        let identity: Identity
        let purpose: Purpose
    }
    
    typealias Constructor = Config
    typealias ViewModel = AddressBookViewModel
    var viewModel: AddressBookViewModel!
    var bag: DisposeBag = DisposeBag.init()

    func config(constructor: AddressBookViewController.Config) {
        view.layoutIfNeeded()
        setupTableView()
        viewModel = ViewModel.init(
            input: AddressBookViewModel.InputSource(
                identity: constructor.identity,
                mainCoinIDLimit: constructor.purpose.limitMainCoinID
            ),
            output: ()
        )
        
        bindViewModel()
        bindSelectAction(withPurpose: constructor.purpose)
        
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
    }
    
    override func renderLang(_ lang: Lang) {
        let dls = lang.dls
        title = dls.addressbook_title
        noDataLabel.text = dls.addressbook_label_empty_addressbook
    }
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        renderNavBar(tint: palette.nav_item_1, barTint: palette.nav_bg_1)
        renderNavTitle(color: palette.nav_item_1, font: .owMedium(size: 18))
        changeLeftBarButtonToDismissToRoot(tintColor: palette.nav_item_1, image: #imageLiteral(resourceName: "arrowNavBlack"), title: nil)
        changeNavShadowVisibility(true)
        createBtn.set(color: palette.btn_bgFill_enable_bg)
        
        view.backgroundColor = palette.bgView_sub
        noDataLabel.set(textColor: palette.label_sub, font: .owRegular(size: 11))
    }
    
    private func setupTableView() {
        tableView.register(AddressbookTableViewCell.nib, forCellReuseIdentifier: AddressbookTableViewCell.cellIdentifier())
        tableView.separatorStyle = .none
    }
    
    private func bindSelectAction(withPurpose purpose: Purpose) {
        let unitSelect =
            tableView.rx
                .modelSelected(AddressBookUnit.self)
                .filter { [unowned self] in self.viewModel.isUnitSelectable($0) }
        unitSelect.subscribe(onNext:{
            [unowned self] unit in
            switch purpose {
            case .browse: self.toDetail(withUnit: unit)
            case .select: self._onSelect.accept(unit)
            }
        })
        .disposed(by: bag)
    }
    
    private func bindViewModel() {
        viewModel.units.bind(to: tableView.rx.items(cellIdentifier: AddressbookTableViewCell.cellIdentifier(), cellType: AddressbookTableViewCell.self)) {
            [unowned self]
            row, unit, cell in
            cell.config(unit: unit, isSelectable: self.viewModel.isUnitSelectable(unit))
        }
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
    
    
    //MARK: - Selection Action
    public var onSelect: Observable<AddressBookUnit> {
        return _onSelect.asObservable()
    }
    
    private var _onSelect: PublishRelay<AddressBookUnit> = PublishRelay.init()
    
    private func toDetail(withUnit unit: AddressBookUnit) {
        let vc = AddressBookUnitBrowseViewController.instance(from: AddressBookUnitBrowseViewController.Config(unit: unit))
        navigationController?.pushViewController(vc)
    }
    
    //MARK: - Create
    private lazy var createBtn: UIButton = {
        return createRightBarButton(target: self, selector: #selector(toCreateView), image: #imageLiteral(resourceName: "btnAddNormal"), shouldClear: true)
    }()
    
    @objc private func toCreateView() {
        let mainCoinID = ChainType.btc.defaultCoin.walletMainCoinID!
        let vc = EditABUnitViewController.instance(from: EditABUnitViewController.Config(source: .plain(mainCoinID: mainCoinID)))
        navigationController?.pushViewController(vc)
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
