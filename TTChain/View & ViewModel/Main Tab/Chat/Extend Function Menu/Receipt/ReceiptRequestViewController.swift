//
//  ReceiptRequestViewController.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/1/28.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit

class ReceiptRequestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBOutlet weak var coinTitleLabel: UILabel!
    @IBOutlet weak var coinNameTextField: UITextField!
    @IBOutlet weak var receiptAmountLabel: UILabel!
    @IBOutlet weak var receiptAmounTextField: UITextField!
    private let coinPickerView: UIPickerView = UIPickerView.init()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.setGradientColor()
    }
}
