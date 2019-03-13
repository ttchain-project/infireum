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
            
//            switch callStatus {
//            case nil:
//
//            case .dialing?:
//
//            case .connected?:
//
//            default:
//
//            }
        }).disposed(by: bag)
        
        self.endCallButton.rx.tap.subscribe(onNext: {
            [unowned self] in
            AVCallHandler.handler.cancelCall()
            self.dismiss(animated: true, completion: nil)
        }).disposed(by: bag)
    }
}
