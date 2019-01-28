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
    
    @IBOutlet weak var privateChatBannerView: UIView!
    @IBOutlet weak var privateChatDurationTitleLabel: UILabel!
    
    enum ChatFunctionEnum : Int{
        
        case addPhoto = 0
        case openCamera = 1
        case startSecretChat = 2
        case addReceipt
        case makeAudioCall
        case makeVideoCall
    }
    
    struct Input {
        
    }
    
    struct Output {
        var didChangeViewHeight: (CGFloat) -> Void
        var onSelectChatFunction:(FunctionModel) -> Void

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
    
    let functions: [FunctionModel] = [
                                      FunctionModel.init(title: "圖片", image: UIImage(named: "iconPhotosColor"), type: .addPhoto),
                                      FunctionModel.init(title: "相機", image: UIImage(named: "iconCameraColor"), type: .openCamera),
                                      FunctionModel.init(title: "密聊", image: UIImage(named: "iconSecretColor"), type: .startSecretChat),
                                       FunctionModel.init(title: "Receipt", image: UIImage(named: "iconEnvelopeColor"), type: .addReceipt)
]
    
    //TODO: Change this implementation, looks very lame :-\
    /*
     FunctionModel.init(title: "圖片", image: UIImage(named: "iconPhotosColor"), type: .addPhoto),
     FunctionModel.init(title: "相機", image: UIImage(named: "iconCameraColor"), type: .openCamera),
     FunctionModel.init(title: "影片", image: UIImage(named: "iconFilmColor"), type: .addVideo),
     FunctionModel.init(title: "紅包", image: UIImage(named: "iconEnvelopeColor"), type: .addRedEnvelope),
     FunctionModel.init(title: "通話", image: UIImage(named: "iconCallColor"), type: .makeAudioCall),
     FunctionModel.init(title: "視訊", image: UIImage(named: "iconVideoColor"), type: .makeVideoCall),
 */
    
    var bag: DisposeBag = DisposeBag()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        inputContentViewBottomConstraint.constant = 0
        initTextField()
        initMoreButton()
        initCollectionView()
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            animateInputContentView(offset: keyboardFrame.cgRectValue.height)
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        animateInputContentView(offset: 0)
    }
    
    func animateInputContentView(offset: CGFloat) {
        self.setNeedsLayout()
        
        inputContentViewBottomConstraint.constant = offset
        
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
        
        self.output?.didChangeViewHeight(inputContentViewHeight + inputContentViewBottomOffset)
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
