//
//  ChatKeyboardView.swift
//  OfflineWallet
//
//  Created by Lifelong-Study on 2018/10/17.
//  Copyright © 2018 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import AVFoundation

class FunctionModel {
    var title: String = ""
    var image: UIImage? = nil
    var type : ChatKeyboardView.ChatFunctionEnum
    init(title: String, image: UIImage?, type :ChatKeyboardView.ChatFunctionEnum) {
        self.title = title
        self.image = image
        self.type = type
    }
}


class ChatKeyboardView: XIBView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var moreButton: UIButton!
//    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.placeholder = LM.dls.chat_keyboard_placeholder
        }
    }
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var inputContentView: UIView!
    @IBOutlet weak var inputContentViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var blockView: UIView! {
        didSet { blockView.isHidden = !isBlock }
    }
    @IBOutlet weak var recorderKeyboardSwitchButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var recordAudioButton: UIButton!
    
    @IBOutlet weak var privateChatBannerView: UIView!
    @IBOutlet weak var privateChatDurationTitleLabel: UILabel!
    
    enum ChatFunctionEnum : Int{
        
        case addPhoto = 0
        case openCamera = 1
        case startSecretChat = 2
        case addReceipt
        case redEnv
        case makeAudioCall
        case makeVideoCall
        case sendDocument
    }
    
    struct Input {
        var roomType:RoomType
    }
    
    struct Output {
        var didChangeViewHeight: (CGFloat) -> Void
        var onSelectChatFunction:(FunctionModel) -> Void
        var onVoiceMessageSuccess:(Data) -> Void
    }
    
    var input: Input? = nil
    var output: Output? = nil
    var isBlock: Bool = false {
        didSet { blockView.isHidden = !isBlock }
    }
    
    func config(input: Input, output: Output) {
        self.input = input
        self.output = output
        
    }
    
    var inputContentViewHeight: CGFloat {
        return inputContentView?.bounds.height ?? 0
    }
    var inputContentViewBottomOffset: CGFloat {
        return inputContentViewBottomConstraint?.constant ?? 0
    }
    
    var functions: [FunctionModel] = [FunctionModel.init(title: LM.dls.chat_room_receipt, image:#imageLiteral(resourceName: "chat_btn_request.png") , type: .addReceipt),
                                      FunctionModel.init(title: LM.dls.chat_room_image, image: UIImage(named: "iconPhotosColor"), type: .addPhoto),
                                      FunctionModel.init(title: LM.dls.chat_room_camera, image: UIImage(named: "iconCameraColor"), type: .openCamera),
                                      FunctionModel.init(title: LM.dls.send_file_title, image: UIImage(named: "iconFileColor"), type: .sendDocument),
                                      FunctionModel.init(title: LM.dls.chat_room_red_env, image: #imageLiteral(resourceName: "chat_btn_redenvelope.png"), type: .redEnv)
                                      
]

    
    var bag: DisposeBag = DisposeBag()
    
    var recorder: AVAudioRecorder?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        inputContentViewBottomConstraint.constant = 0
        initTextField()
        initMoreButton()
        initCollectionView()
        configRecorderButton()
        setupRecordAudioButton()
        listenKeyboardNotification()
        self.initPvtChatBanner()
    }
    
    func initTextField() {
        textField.inputView = nil
        
        textField.rx.text
            .replaceNilWith("")
            .map { $0.count > 0 }
            .bind(to: recorderKeyboardSwitchButton.rx.isHidden).disposed(by: bag)
        
        textField.rx.text
            .replaceNilWith("")
            .map { $0.count == 0 }
            .bind(to: sendButton.rx.isHidden).disposed(by: bag)
    }
    
    func initMoreButton() {
        moreButton.rx.tap.asDriver().drive(onNext: {[weak self] _ in
           
            self?.textField.resignFirstResponder()
            
            let offset = self?.inputContentViewBottomConstraint.constant
            
            self?.animateInputContentView(offset: offset == 0 ? 78 : 0)
            self?.moreButton.isSelected = !(self?.moreButton.isSelected ?? false)
        }).disposed(by: bag)
    }
    
    func initPvtChatBanner() {
        self.privateChatBannerView.backgroundColor = .owPumpkinOrange
        self.privateChatDurationTitleLabel.textColor = .white
        self.privateChatBannerView.isHidden = true
        self.privateChatDurationTitleLabel.set(textColor: .white, font: .owRegular(size: 10))
    }
    
    func initCollectionView() {
        collectionView.register(UINib(nibName: "KeyboardFunctionCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "KeyboardFunctionCollectionViewCell")
        collectionView.backgroundColor = .yellowGreen
    }
    
    func listenKeyboardNotification() {
        
        return Observable
            .from([
                NotificationCenter.default.rx.notification(NSNotification.Name.UIKeyboardWillShow)
                    .map { notification -> CGFloat in
                       var keyboardHeight =  (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height ?? 0
                        if #available(iOS 11.0, *) {
                            let bottomInset = self.superview?.safeAreaInsets.bottom ?? 0
                            keyboardHeight -= bottomInset
                        }
                        return keyboardHeight
                },
                NotificationCenter.default.rx.notification(NSNotification.Name.UIKeyboardWillHide)
                    .map { _ -> CGFloat in
                        0
                }
                ])
            .merge().subscribe(onNext: { [weak self] (height) in
                guard let `self` = self else {
                    return
                }
                self.moreButton.isSelected = false
                self.animateInputContentView(offset: height)
            }).disposed(by: bag)

    }
    
    func configRecorderButton() {
        
        self.recorderKeyboardSwitchButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            guard let `self` = self else {
                return
            }
            self.recorderKeyboardSwitchButton.isSelected = !self.recorderKeyboardSwitchButton.isSelected
            self.textField.isHidden = self.recorderKeyboardSwitchButton.isSelected
            self.recordAudioButton.isHidden = !self.recorderKeyboardSwitchButton.isSelected
            if self.recorderKeyboardSwitchButton.isSelected {
                self.prepareRecording()
            }
        }).disposed(by: bag)
        
    }
    
    func setupRecordAudioButton() {
        self.recordAudioButton.isHidden = true
        self.recordAudioButton.cornerRadius = self.recordAudioButton.height/2
        self.recordAudioButton.borderColor = .black
        self.recordAudioButton.borderWidth = 0.5
        self.recordAudioButton.setTitleColor(.black, for: .normal)
        self.recordAudioButton.setTitle(LM.dls.record_audio_start_button, for: .normal)
        self.recordAudioButton.setTitle(LM.dls.record_audio_stop_to_send_button, for: .highlighted)
        
        self.recordAudioButton.rx.controlEvent([.touchDown]).subscribe(onNext: {[weak self] _ in
            self?.startRecording()
        }).disposed(by: bag)

        self.recordAudioButton.rx.controlEvent([.touchUpInside]).subscribe(onNext: {[weak self] _ in
            DLogInfo("End Recording")
            self?.finishRecording(success: true)
        }).disposed(by: bag)
        
        self.recordAudioButton.rx.controlEvent([.touchCancel]).subscribe(onNext: { [weak self] _ in
            DLogInfo("Cancel Recording")
            self?.finishRecording(success: false)
        }).disposed(by: bag)
        
    }
    
    func animateInputContentView(offset: CGFloat) {
        self.setNeedsLayout()
        
        inputContentViewBottomConstraint.constant = offset
        
        UIView.animate(withDuration: 0.25) {
            self.layoutIfNeeded()
        }
        
        self.output?.didChangeViewHeight(inputContentViewHeight + inputContentViewBottomOffset)
    }
    
    func prepareRecording() {
        
        let recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryRecord)
            try recordingSession.setActive(true)
            switch recordingSession.recordPermission(){
            case .undetermined:
                recordingSession.requestRecordPermission() { [unowned self] allowed in
                    DispatchQueue.main.async {
                        if allowed {
                            self.recordAudioButton.isEnabled = true
                        } else {
                            self.recordAudioButton.isEnabled = false
                        }
                    }
                }
            case .granted:
                DLogInfo("start recording")
            case .denied:
                self.superview?.viewContainingController()!.showSimplePopUp(
                    with: "",
                    contents: LM.dls.access_denied_mic,
                    cancelTitle: LM.dls.g_confirm,
                    cancelHandler: nil
                )
            }
        } catch {
            
        }
    }
    
    var audioPlayer : AVAudioPlayer?

    func getAudioFilePath() -> URL {
        let audioFileName = NSTemporaryDirectory().appendingPathComponent("AudioFileRecoding11.3gpp")
        let audioFilePath = URL.init(fileURLWithPath: audioFileName)
        return audioFilePath
    }
    
    func startRecording() {
        DLogInfo("Start Recording")
        
        let audioFilePath = self.getAudioFilePath()
        DLogInfo("File at \(FileManager.default.fileExists(atPath: audioFilePath.absoluteString))")
        do {
            try FileManager.default.removeItem(at: audioFilePath)
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryRecord)
        } catch let error as NSError {
            print("Error: \(error.domain)")
        }
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
            AVAudioFileTypeKey:Int(kAudioFile3GPType)
        ]
        
        do {
            recorder = try AVAudioRecorder(url: audioFilePath, settings: settings)
        } catch {
            finishRecording(success: false)
        }
        guard let recorder = self.recorder else {
            return
        }
        recorder.delegate = self
        recorder.record()
    }
    
    func finishRecording(success:Bool) {
        recorder?.stop()
        recorder = nil
        if success {
            DLogInfo("Success")
            let filePath = self.getAudioFilePath().absoluteString
            DLogInfo(filePath)
            guard let data = try? Data.init(contentsOf: self.getAudioFilePath()) else {
                return
            }
            self.output?.onVoiceMessageSuccess(data)
        } else {
            self.superview?.viewContainingController()!.showSimplePopUp(
                with: "",
                contents: LM.dls.recording_failed,
                cancelTitle: LM.dls.g_ok,
                cancelHandler: nil
            )
            
        }
    }
    //
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = 0.20 * UIScreen.main.bounds.size.width
        
        return CGSize.init(width: width, height: 78)
    }
    
    //
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return functions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "KeyboardFunctionCollectionViewCell", for: indexPath) as? KeyboardFunctionCollectionViewCell
        
        cell?.descriptionLabel.text = functions[indexPath.row].title
        cell?.imageView.image       = functions[indexPath.row].image
        
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("\(indexPath.row)")
       
            self.output?.onSelectChatFunction(self.functions[indexPath.row])
        }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
    }
}

extension ChatKeyboardView: AVAudioRecorderDelegate,AVAudioPlayerDelegate {
    
}
