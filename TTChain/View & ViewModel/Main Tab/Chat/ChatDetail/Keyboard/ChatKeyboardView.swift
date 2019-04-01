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
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var inputContentView: UIView!
    @IBOutlet weak var inputContentViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var blockView: UIView! {
        didSet { blockView.isHidden = !isBlock }
    }
    @IBOutlet weak var recorderKeyboardSwitchButton: UIButton!
    
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
        
        if self.input!.roomType == .pvtChat {
            self.functions.append(contentsOf:[FunctionModel.init(title: LM.dls.chat_secret_setting, image: UIImage(named: "iconSecretColor"), type: .startSecretChat),
                                  FunctionModel.init(title: LM.dls.chat_room_audio_call, image: #imageLiteral(resourceName: "iconCallColor"), type: .makeAudioCall)]
            )
            self.collectionView.reloadData()
        }
    }
    
    var inputContentViewHeight: CGFloat {
        return inputContentView?.bounds.height ?? 0
    }
    var inputContentViewBottomOffset: CGFloat {
        return inputContentViewBottomConstraint?.constant ?? 0
    }
    
    var functions: [FunctionModel] = [FunctionModel.init(title: LM.dls.chat_room_receipt, image: UIImage(named: "iconEnvelopeColor"), type: .addReceipt),
                                      FunctionModel.init(title: LM.dls.chat_room_image, image: UIImage(named: "iconPhotosColor"), type: .addPhoto),
                                      FunctionModel.init(title: LM.dls.chat_room_camera, image: UIImage(named: "iconCameraColor"), type: .openCamera),
                                      FunctionModel.init(title: LM.dls.chat_room_red_env, image: UIImage(named: "iconEnvelopeColor"), type: .redEnv)
                                      
]
    
    
    //TODO: Change this implementation, looks very lame :-\
    /*
     FunctionModel.init(title: "圖片", image: UIImage(named: "iconPhotosColor"), type: .addPhoto),
     FunctionModel.init(title: "相機", image: UIImage(named: "iconCameraColor"), type: .openCamera),
     FunctionModel.init(title: "影片", image: UIImage(named: "iconFilmColor"), type: .addVideo),
     FunctionModel.init(title: "紅包", image: UIImage(named: "iconEnvelopeColor"), type: .addRedEnvelope),
     FunctionModel.init(title: "通話", image: UIImage(named: "iconCallColor"), type: .makeAudioCall),
     FunctionModel.init(title: LM.dls.chat_room_video_call, image: UIImage(named: "iconVideoColor"), type: .makeVideoCall),
 */
    
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
        

        sendButton.setImage(#imageLiteral(resourceName: "iconSendActive"), for: .normal)
        sendButton.setImage(#imageLiteral(resourceName: "iconSendGray"), for: .disabled)
        sendButton.isEnabled = false
        textField.rx.text
            .replaceNilWith("")
            .map { $0.count > 0 }
            .bind(to: self.sendButton.rx.isEnabled).disposed(by: bag)
    }
    
    func initMoreButton() {
        moreButton.rx.tap.asDriver().drive(onNext: {
            self.textField.resignFirstResponder()
            
            let offset = self.inputContentViewBottomConstraint.constant
            
            self.animateInputContentView(offset: offset == 0 ? 156 : 0)
            
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
    }
    
    func listenKeyboardNotification() {
        
        return Observable
            .from([
                NotificationCenter.default.rx.notification(NSNotification.Name.UIKeyboardWillShow)
                    .map { notification -> CGFloat in
                        (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height ?? 0
                },
                NotificationCenter.default.rx.notification(NSNotification.Name.UIKeyboardWillHide)
                    .map { _ -> CGFloat in
                        0
                }
                ])
            .merge().subscribe(onNext: { [weak self](height) in
                guard let `self` = self else {
                    return
                }
                self.animateInputContentView(offset: height)
            }).disposed(by: bag)

    }
    
//    @objc func keyboardWillShow(notification: Notification) {
//        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
//            animateInputContentView(offset: keyboardFrame.cgRectValue.height)
//        }
//    }
//
//    @objc func keyboardWillHide(notification: Notification) {
//        animateInputContentView(offset: 0)
//    }
//
    
    func configRecorderButton() {
        
        self.recorderKeyboardSwitchButton.rx.tap.asDriver().drive(onNext: { _ in
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
        
        self.recordAudioButton.rx.controlEvent([.touchDown]).subscribe(onNext: { _ in
            self.startRecording()
        }).disposed(by: bag)

        self.recordAudioButton.rx.controlEvent([.touchUpInside]).subscribe(onNext: { _ in
            DLogInfo("End Recording")
            self.finishRecording(success: true)
        }).disposed(by: bag)
        
        self.recordAudioButton.rx.controlEvent([.touchCancel]).subscribe(onNext: { _ in
            DLogInfo("Cancel Recording")
            self.finishRecording(success: false)
        }).disposed(by: bag)
        
    }
    
    func animateInputContentView(offset: CGFloat) {
        self.setNeedsLayout()
        
        inputContentViewBottomConstraint.constant = offset
        
        UIView.animate(withDuration: 0.3) {
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
                            //Start Recording
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
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let audioFileName = documentsPath.appendingPathComponent("AudioFileRecoding11.3gpp")
        let audioFilePath = URL.init(fileURLWithPath: audioFileName)
        return audioFilePath
    }
    func startRecording() {
        DLogInfo("Start Recording")

        let audioFilePath = self.getAudioFilePath()
        DLogInfo("File at \(FileManager.default.fileExists(atPath: audioFilePath.absoluteString))")
        do {
            try FileManager.default.removeItem(at: audioFilePath)
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
        let width = 0.25 * UIScreen.main.bounds.size.width
        
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
}

extension ChatKeyboardView: AVAudioRecorderDelegate,AVAudioPlayerDelegate {
    
}
