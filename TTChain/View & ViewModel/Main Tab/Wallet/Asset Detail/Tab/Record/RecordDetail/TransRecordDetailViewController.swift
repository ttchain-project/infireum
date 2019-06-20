//
//  TransRecordDetailViewController.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/2/18.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class TransRecordDetailViewController: KLModuleViewController,KLVMVC  {
    
    
    @IBOutlet weak var transactionStatusLabel: UILabel!
    @IBOutlet weak var transactionDateLabel: UILabel!
    
    @IBOutlet weak var toLinkButton: UIButton!
    
    @IBOutlet weak var amountView: UIView!
    @IBOutlet weak var amountTitleLabel: UILabel!
    @IBOutlet weak var amountValueLabel: UILabel!
    
    @IBOutlet weak var minerFeeView: UIView!
    @IBOutlet weak var minorFeeTitleLabel: UILabel!
    @IBOutlet weak var minorFeeValueLabel: UILabel!

    @IBOutlet weak var recieptAddressView: UIView!
    @IBOutlet weak var recieptAddressTitleLabel: UILabel!
    @IBOutlet weak var recieptAddressValueLabel: UILabel!
    @IBOutlet weak var receiptAddressCopyBtn: UIButton!
   
    @IBOutlet weak var paymentAddressView: UIView!
    @IBOutlet weak var paymentAddressTitleLabel: UILabel!
    @IBOutlet weak var paymentAddressValueLabel: UILabel!
    @IBOutlet weak var paymentAddressCopyButtn: UIButton!
    
    
    @IBOutlet weak var notesView: UIView!
    @IBOutlet weak var notesTitleLabel: UILabel!
    @IBOutlet weak var notesContentLabel: UILabel!
    @IBOutlet weak var checkRedEnvButton: UIButton!
    
    
    @IBOutlet weak var txNumberTitleLabel: UILabel!
    @IBOutlet weak var txNumberContentLabel: UILabel!
    @IBOutlet weak var copyTxNumberBtn: UIButton!
    
    @IBOutlet weak var txBlockTitleLabel: UILabel!
    @IBOutlet weak var txBlocksContentLabel: UILabel!
    
    var bag: DisposeBag = DisposeBag.init()
    typealias  ViewModel = RecordDetailViewModel
    var viewModel: RecordDetailViewModel!
    func config(constructor: TransRecordDetailViewController.Config) {
        
        self.view.layoutIfNeeded()
        self.viewModel = ViewModel.init(input: RecordDetailViewModel.InputSource(record:constructor.transRecord, asset:constructor.asset), output: ())
        self.startMonitorLangIfNeeded()
        self.startMonitorThemeIfNeeded()
        self.setupUI()

    }
   
    struct Config {
        let transRecord:TransRecord
        let asset:Asset
    }
    typealias Constructor = Config
    
    override func renderTheme(_ theme: Theme) {
        
        changeBackBarButton(toColor: .white, image:#imageLiteral(resourceName: "btnCancelWhiteNormal"))
        
        self.transactionStatusLabel.set(textColor: theme.palette.label_main_1, font: .owMedium(size: 20))
        self.transactionDateLabel.set(textColor: theme.palette.label_main_1, font: .owMedium(size: 12))
        
        [self.amountTitleLabel,
         self.minorFeeTitleLabel,minorFeeValueLabel,
         self.paymentAddressTitleLabel,paymentAddressValueLabel,
         recieptAddressTitleLabel,recieptAddressValueLabel,
         notesTitleLabel,notesContentLabel].forEach
            { label in
                label?.set(textColor: theme.palette.label_main_1, font: .owMedium(size: 15))
        }
        
        self.amountValueLabel.set(textColor: theme.palette.label_main_1, font: .owMedium(size: 20))
        
        [self.txBlockTitleLabel,self.txBlocksContentLabel,
         self.txNumberTitleLabel,self.txNumberContentLabel].forEach {
            $0.set(textColor: theme.palette.label_main_2, font: .owMedium(size: 15))
        }
        
        self.toLinkButton.set(textColor: theme.palette.btn_bgFill_enable_text, font: .owMedium(size: 15), backgroundColor: UIColor.init(hexString: "EDBB4E"))
        self.toLinkButton.cornerRadius = self.toLinkButton.height/2
        
        self.view.backgroundColor = theme.palette.btn_bgFill_enable_bg2
    }
    
    override func renderLang(_ lang: Lang) {
        
        self.navigationItem.title = lang.dls.tx_record_detail_title(self.viewModel.input.asset.coin!.inAppName!)
        
        self.amountTitleLabel.text = lang.dls.assetDetail_tab_total
        self.minorFeeTitleLabel.text  = lang.dls.ltTx_label_minerFee
        self.paymentAddressTitleLabel.text = lang.dls.withdrawal_label_fromAddr
        self.recieptAddressTitleLabel.text = lang.dls.withdrawal_label_toAddr
        self.toLinkButton.setTitle(lang.dls.assetDetail_label_tx_go_check, for: .normal)
        self.notesTitleLabel.text = lang.dls.abInfo_label_note
        self.txNumberTitleLabel.text = lang.dls.tx_number_title
        self.txBlockTitleLabel.text = lang.dls.tx_block_number_title
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func setupUI() {
        
        self.transactionStatusLabel.text = self.viewModel.txStatusStr
        self.transactionDateLabel.text = self.viewModel.txDate
        self.amountValueLabel.text = self.viewModel.amtString
        self.paymentAddressValueLabel.text = viewModel.fromAddress
        self.recieptAddressValueLabel.text = viewModel.toAddress
        self.minorFeeValueLabel.text = viewModel.feeString
        self.notesContentLabel.text = viewModel.noteMessage
        self.txBlocksContentLabel.text = viewModel.blockNumbers
        self.txNumberContentLabel.text = viewModel.txId
        
        guard let url = viewModel.createTxURL() else {
            self.toLinkButton.isHidden = true
            return
        }
        self.toLinkButton.rx.tap.asDriver().drive(onNext: { () in
            let vc = ExploreDetailWebViewController.instance(from: ExploreDetailWebViewController.Config(model: nil,url:url))
            self.navigationController?.pushViewController(vc,animated:true)
        }).disposed(by: bag)
    }
    
    

}
