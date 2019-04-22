//
//  IncomingCallViewController.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/3/13.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import AudioToolbox
import AVFoundation

final class IncomingCallViewController: KLModuleViewController,KLVMVC {
    
    var viewModel: IncomingCallViewModel!
    
    @IBOutlet weak var testLabel: UILabel!
    typealias ViewModel = IncomingCallViewModel
    
    var bag: DisposeBag = DisposeBag.init()
    var audioPlayer:AVAudioPlayer!
    
    typealias Constructor = Config
    
    struct Config {
        let callModel:CallMessageModel
        let headImage:String?
        let callTitle:String
        let didReceiveCall: (Bool) -> Void
    }
    
    private var didAcceptCall: ((Bool) -> Void)?
    
    func config(constructor: IncomingCallViewController.Config) {
        self.view.layoutIfNeeded()
        self.viewModel = IncomingCallViewModel.init(input: IncomingCallViewModel.InputSource(callModel: constructor.callModel,strin:self.testLabel), output: ())
        self.startIncomingTone()
        self.callTitleLabel.text = constructor.callTitle
        self.callMessageLabel.text = constructor.callModel.message
        self.didAcceptCall = constructor.didReceiveCall
        self.bindUI()

        guard let url = constructor.headImage else {
            self.profileImageView.image = #imageLiteral(resourceName: "userAvatarDefault01180")
            return
        }
        
        self.profileImageView.setProfileImage(image: url, tempName: constructor.callTitle)
    }
    
    @IBOutlet weak var callTitleLabel: UILabel!
    @IBOutlet weak var callMessageLabel: UILabel!
    @IBOutlet weak var declineCall: UIButton!
    @IBOutlet weak var acceptCall: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
  
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    func bindUI() {
        self.declineCall.rx.tap.subscribe(onNext: {
            [unowned self] in
            self.viewModel.timerBag.dispose()

            self.dismiss(animated: false, completion: {
                self.didAcceptCall!(false)
                self.audioPlayer.stop()
            })
        }).disposed(by: bag)
        
        self.acceptCall.rx.tap.subscribe(onNext: {
            [unowned self] in
            self.viewModel.timerBag.dispose()
            self.audioPlayer.stop()
            self.dismiss(animated: false, completion: {
                self.didAcceptCall!(true)
            })
        }).disposed(by: bag)
        
        AVCallHandler.handler.currentCallingStatus.asObservable().subscribe(onNext: {[weak self] (status) in
            guard let `self` = self else {
                return
            }
            
            if case .disconnected? = status {
                self.viewModel.timerBag.dispose()
                self.audioPlayer.stop()
                self.dismiss(animated: true, completion: {
                    self.didAcceptCall = nil
                })
            }
        }).disposed(by: bag)
    }
    
    func startIncomingTone() {
        guard let url = Bundle.main.path(forResource: "ringtone", ofType: "wav") else {
            return
        }
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)

            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: url))
            audioPlayer?.play()
            audioPlayer?.numberOfLoops = -1
        }
        catch let error{
            print(error)
        }
        
        
    }
}
