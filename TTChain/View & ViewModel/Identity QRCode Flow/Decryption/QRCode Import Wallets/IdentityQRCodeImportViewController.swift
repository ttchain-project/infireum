//
//  IdentityQRCodeImportViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/9/14.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxOptional

final class IdentityQRCodeImportViewController: KLModuleViewController, KLVMVC {

    struct Config {
        let purpose: IdentityQRCodeDecryptionFlow.Purpose
        let infoContent: IdentityQRCodeContent
        let resultCallback: (IdentityQRCodeDecryptionFlow.Result) -> Void
    }
    
    typealias ViewModel = IdentityQRCodeImportViewModel
    typealias Constructor = Config
    
    var viewModel: IdentityQRCodeImportViewModel!
    var bag: DisposeBag = DisposeBag.init()
    
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var nextStepBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    private var resultCallBack: ((IdentityQRCodeDecryptionFlow.Result) -> Void)?
    private var purpose: IdentityQRCodeDecryptionFlow.Purpose!
    
    func config(constructor: Config) {
        purpose = constructor.purpose
        resultCallBack = constructor.resultCallback
        
        view.layoutIfNeeded()
        configTableView()
        
        viewModel = ViewModel.init(
            input: IdentityQRCodeImportViewModel.InputSource(
                infoContent: constructor.infoContent
            ),
            output: ()
        )
        
        viewModel.datasource.configureCell = {
            [weak self]
            source, tv, idxPath, wallet -> UITableViewCell in
            
            let cell = tv.dequeueReusableCell(withIdentifier: IdentityQRCodeImportTableViewCell.cellIdentifier()) as! IdentityQRCodeImportTableViewCell
            guard let wSelf = self else { return cell }
            cell.config(
                walletName: wallet.name,
                isExist: wSelf.viewModel.isWalletUnitExistInLocal(wallet)
            )
            
            return cell
        }
        
        viewModel
            .sectionModelSources
            .bind(to: tableView.rx.items(
                dataSource: viewModel.datasource)
            )
            .disposed(by: bag)
        
        bindUI()
        
        startMonitorThemeIfNeeded()
        startMonitorLangIfNeeded()
        startMonitorNetworkStatusIfNeeded()
    }
    
    private func configTableView() {
        tableView.delegate = self
        tableView.register(IdentityQRCodeImportTableViewHeader.nib, forHeaderFooterViewReuseIdentifier: IdentityQRCodeImportTableViewHeader.nameOfClass)
        tableView.register(IdentityQRCodeImportTableViewCell.nib, forCellReuseIdentifier: IdentityQRCodeImportTableViewCell.cellIdentifier())
        tableView.separatorStyle = .none
    }
    
    override func renderLang(_ lang: Lang) {
        let dls = lang.dls
        title = dls.qrCodeImport_list_title
        noteLabel.text = dls.qrCodeImport_list_label_will_not_import_existed_wallets
        nextStepBtn.setTitleForAllStates(dls.g_next)
    }
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        renderNavBar(tint: palette.nav_item_2, barTint: palette.nav_bg_clear)
        renderNavTitle(color: palette.nav_item_2, font: .owMedium(size: 20))
        
        changeLeftBarButtonToDismissToRoot(
            tintColor: palette.nav_item_2,
            image: #imageLiteral(resourceName: "navBarBackButton")
        )
        
        noteLabel.set(textColor: palette.specific(color: .owPinkRed),
                      font: .owRegular(size: 12))
        
        nextStepBtn.set(color: palette.btn_bgFill_enable_text,
                        font: .owRegular(size: 14),
                        backgroundColor: palette.btn_bgFill_enable_bg)
    }
    
    private func bindUI() {
        bindNextStep()
    }
    
    private func bindNextStep() {
        nextStepBtn.rx
            .tap
            .asDriver()
            .drive(onNext: {
                [weak self]
                _ in
                self?.toInfoSetup()
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
    
    private func toInfoSetup() {
        let vc = IdentityQRCodeImportInfoFillUpViewController.instance(from: IdentityQRCodeImportInfoFillUpViewController.Config(purpose: purpose, infoContent: viewModel.input.infoContent, resultCallback: { [weak self] (result) in
            self?.resultCallBack?(result)
        }))
        
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

extension IdentityQRCodeImportViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: IdentityQRCodeImportTableViewHeader.nameOfClass) as! IdentityQRCodeImportTableViewHeader
        if section == viewModel.systemWalletSection {
            view.config(headerType: .system)
        }else if section == viewModel.importedWalletSection {
            view.config(headerType: .imported)
        }else {
            return nil
        }
        
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
}


