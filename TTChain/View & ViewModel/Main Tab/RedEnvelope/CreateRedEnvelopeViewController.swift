//
//  CreateRedEnvelopeViewController.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/3/22.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit
import RxSwift


class CreateRedEnvelopeViewController: UIViewController {

    @IBOutlet weak var coinTypeTitleLabel: UILabel!
    @IBOutlet weak var selectedCoinNameLabel: UILabel!
    
    @IBOutlet weak var selectedCoinAmountLabel: UILabel!
    @IBOutlet weak var selectCoinButon: UIButton!
    @IBOutlet weak var amountToTransferTitleLabel: UILabel!
    @IBOutlet weak var amountTransferTextField: UITextField!
    @IBOutlet weak var numberOfPeopleTitleLabel: UILabel!
    @IBOutlet weak var numberOfPeopleTextField: UITextField!
    @IBOutlet weak var distributionTypeTitleLabel: UILabel!
    @IBOutlet weak var equalDistributionLabal: UILabel!
    @IBOutlet weak var randomDisrtibutionLabel: UILabel!
    @IBOutlet weak var equalDistributionButton: UIButton!
     @IBOutlet weak var randomDistributionButton: UIButton!
    
    @IBOutlet weak var expirationTimeTitleLabel
    : UILabel!
    @IBOutlet weak var expirationTimeLabel
    : UILabel!
    @IBOutlet weak var expirationTimeSelectionButton: UIButton!
    
    @IBOutlet weak var scheduleTitleLabel
    : UILabel!
    @IBOutlet weak var sendInfFutureSelectionLabel
    : UILabel!
    @IBOutlet weak var sendInfFutureSelectionSwitch: UISwitch!
    @IBOutlet weak var sendInFutureTimeLabel
    : UILabel!
    @IBOutlet weak var sendInfutureSelectionButton: UIButton!
    
    @IBOutlet weak var messageTitleLabel: UILabel!
    @IBOutlet weak var messageTextView: KLPlaceholderTextView!
    @IBOutlet weak var messageCountLabel: UILabel!
    
    @IBOutlet weak var infoMessageLabelOne: UILabel!
    @IBOutlet weak var infoMessageLabelTwo: UILabel!
    
    @IBOutlet weak var sendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    private let viewModel: CreateRedEnvelopeViewModel
   
    init(viewModel: CreateRedEnvelopeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: CreateRedEnvelopeViewController.className, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
