//
//  AudioCallViewController.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/3/11.
//  Copyright © 2019 gib. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

enum CallAction {
    case startCall
    case joinCall
}

final class AudioCallViewController:KLModuleViewController, KLVMVC {
    
    var viewModel: AudioCallViewModel!
    
    typealias ViewModel = AudioCallViewModel
    
    var bag: DisposeBag = DisposeBag.init()
    
    struct Config {
        let roomId:String
        let calleeName:String
        let calleeImage:URL? = nil
        let roomType:RoomType
        let callAction:CallAction
        var streamId:String? = nil
    }
    typealias Constructor = Config

    func config(constructor: AudioCallViewController.Config) {
        self.view.layoutIfNeeded()
        self.viewModel = AudioCallViewModel.init(input: AudioCallViewModel.Input.init(roomId: constructor.roomId, roomType: constructor.roomType), output:AudioCallViewModel.Output())
        self.startMonitorLangIfNeeded()
        self.startMonitorThemeIfNeeded()
        switch constructor.callAction {
        case .joinCall:
            DLogDebug("Join Call")
            guard constructor.streamId != nil else {
                return
            }
            self.viewModel.joinCall(forStreamId: constructor.streamId!)
            
        case .startCall:
            DLogDebug("Start Call")
            self.viewModel.initiateCall()
        }
        
        self.callTitleLabel.text = constructor.calleeName
        self.bindUI()

        guard constructor.calleeImage != nil else{
            self.callImageView.image = #imageLiteral(resourceName: "userAvatarDefault01180")
            return
        }
        self.callImageView.af_setImage(withURL: constructor.calleeImage!)
    }
    @IBOutlet weak var callTitleLabel: UILabel!
    @IBOutlet weak var callImageView: UIImageView!
    @IBOutlet weak var muteCallButton: UIButton!
    @IBOutlet weak var endCallButton: UIButton!
    @IBOutlet weak var speakerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func renderLang(_ lang: Lang) {
        self.callTitleLabel.text = ""
    }
    override func renderTheme(_ theme: Theme) {
        self.muteCallButton.setImage(#imageLiteral(resourceName: "iconCallMute"), for: .normal)
        self.muteCallButton.setImage(#imageLiteral(resourceName: "iconCallMuteOn"), for: .selected)
        
        self.speakerButton.setImage(#imageLiteral(resourceName: "iconCallSpeaker"), for: .normal)
        self.speakerButton.setImage(#imageLiteral(resourceName: "iconCallSpeakerOn.png"), for: .selected)
        
    }
    func bindUI() {
        AVCallHandler.handler.currentCallingStatus.asObservable().subscribe(onNext: { (callStatus) in
           
            if callStatus == nil {
                self.muteCallButton.isEnabled = false
                self.speakerButton.isEnabled = false
            }else {
                self.muteCallButton.isEnabled = true
                self.speakerButton.isEnabled = true
            }
            
            switch callStatus {

            case .connected?:
                print("start timer")
            case .disconnected?:
                self.dismiss(animated: true, completion: nil)
            default:
                print("a")
            }
        }).disposed(by: bag)
        
        self.endCallButton.rx.tap.subscribe(onNext: {
            AVCallHandler.handler.endCall()
            self.dismiss(animated: true, completion: nil)
        }).disposed(by: bag)
        
        self.muteCallButton.rx.tap.subscribe(onNext: {
            self.muteCallButton.isSelected = !self.muteCallButton.isSelected
            AVCallHandler.handler.muteCall(shouldMute: self.muteCallButton.isSelected)
        }).disposed(by: bag)
        
        self.speakerButton.rx.tap.subscribe(onNext: {
            self.speakerButton.isSelected = !self.speakerButton.isSelected
            AVCallHandler.handler.speakerOn(shouldOn: self.speakerButton.isSelected)
        }).disposed(by: bag)
        
    }
}
