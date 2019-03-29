//
//  ReceiveRedEnvelopeViewController.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/3/26.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit

class ReceiveRedEnvelopeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    @IBOutlet weak var gradientView: UIView!
    
    override func viewDidLayoutSubviews() {
         super.viewDidLayoutSubviews()
        let color1 = UIColor(red:254,green: 135,blue: 98)?.cgColor
        let color2 = UIColor(red:230,green: 75,blue: 75)?.cgColor
        self.gradientView.setGradientColor(color1:color1, color2: color2)

    }
    @IBOutlet weak var redEnveloperSenderNameLabel: UILabel! {
        didSet {
            redEnveloperSenderNameLabel.font = .owMedium(size:16)
            redEnveloperSenderNameLabel.textColor = .owWhite
            redEnveloperSenderNameLabel.text = viewModel.output.title
        }
    }
    
    @IBOutlet weak var redEnvelopeMessageLabel: UILabel! {
        didSet {
            redEnvelopeMessageLabel.font = .owMedium(size:18)
            redEnvelopeMessageLabel.textColor = .owWhite
            redEnvelopeMessageLabel.text = viewModel.output.message
            viewModel.output.isReceiveButtonHiddenSubject.map { $0 == false }
                .bind(to: redEnvelopeMessageLabel.rx.isHidden).disposed(by: viewModel.disposeBag)
        }
    }
    
    @IBOutlet weak var redEvelopeStatusLabel: UILabel! {
        didSet {
            redEvelopeStatusLabel.textColor = .owWhite
            redEvelopeStatusLabel.font = .owMedium(size:14)
            redEvelopeStatusLabel.text = viewModel.output.status
        }
    }
    @IBOutlet weak var acceptButton: UIButton! {
        didSet {
            acceptButton.cornerRadius = acceptButton.height/2
            acceptButton.backgroundColor = UIColor.init(red: 230, green: 75, blue: 75)
            acceptButton.setTitle("Accept", for: .normal)
            acceptButton.setTitleColor(UIColor.white, for: .normal)
            acceptButton.rx.tap.bind(to: viewModel.input.receiveTapSubject).disposed(by: viewModel.disposeBag)
            viewModel.output.isReceiveButtonHiddenSubject.bind(to: acceptButton.rx.isHidden)
                .disposed(by: viewModel.disposeBag)
        }
    }
    
    @IBOutlet weak var laterButton: UIButton! {
        didSet {
            laterButton.cornerRadius = laterButton.height/2
            laterButton.borderColor = UIColor.owSilver
            laterButton.setTitle("Dismiss", for: .normal)
            laterButton.setTitleColor(UIColor.owSilver, for: .normal)
            laterButton.borderWidth = 1
            laterButton.rx.tap.bind(to: viewModel.input.closeTapSubject).disposed(by: viewModel.disposeBag)
        }
    }
    
    @IBOutlet weak var settingLabel: UILabel!
    
    private let viewModel: RedEvelopeInfoViewModel
    
    init(viewModel: RedEvelopeInfoViewModel) {
        self.viewModel = viewModel
        super.init(nibName: ReceiveRedEnvelopeViewController.className, bundle: nil)
        viewModel.output.messageSubject.bind(to: rx.message).disposed(by: viewModel.disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
