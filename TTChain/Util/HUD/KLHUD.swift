//
//  KLHUD.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/20.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
//import ChainableAnimations
import Cartography

class KLHUD: UIView {
    enum HUDType {
        case spinner
        case img(UIImage)
    }
    
    var effectView: UIVisualEffectView!
    var descLabel: UILabel!
    var spinner: NVActivityIndicatorView = NVActivityIndicatorView.init(frame: .zero, type: .ballSpinFadeLoader, color: .clear, padding: nil)
    var imgView: UIImageView = UIImageView.init(frame: .zero)
    var type: HUDType = .spinner
    
    //MARK: - Locating Subviews constant
    
    static var spinnerTopPadding: CGFloat = 16
    static var spinnerToLabelPadding: CGFloat = 8
    static var labelToBottomPadding: CGFloat = 16
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private var originFrame: CGRect = .zero
    
    public init(
        type: HUDType,
        frame: CGRect,
        descText desc: String = "Loading...",
        font: UIFont = UIFont.systemFont(ofSize: 14),
        spinnerColor: UIColor = .black,
        textColor: UIColor = .black,
        backgroundColor: UIColor? = nil
        ) {
        
        let descLabel = UILabel.init(text: desc)
        
        descLabel.font = font
        
        descLabel.textColor = textColor
        descLabel.text = desc
        
        super.init(frame: frame)
        
        //        translatesAutoresizingMaskIntoConstraints = false
        
        self.descLabel = descLabel
        originFrame = frame
        //        self.backgroundColor = .clear
        if let bgC = backgroundColor {
            self.backgroundColor = bgC.withAlphaComponent(0.8)
        }else {
            self.backgroundColor = UIColor.owPaleGrey.withAlphaComponent(0.8)
        }
        
        self.cornerRadius = 5
        self.type = type
        
        configureBlurEffect()
        configureSpinner(withColor: spinnerColor)
        configureLabel()
        configureImgView()
        
        updateType(type, text: desc)
    }
    
    
    private func configureBlurEffect() {
        effectView = UIVisualEffectView.init(frame: CGRect.init(origin: .zero, size: originFrame.size))
        effectView.effect = UIBlurEffect.init(style: UIBlurEffectStyle.light)
        
        addSubview(effectView)
        
        constrain(effectView) { (effect) in
            let superV = effect.superview!
            effect.top == superV.top
            effect.bottom == superV.bottom
            effect.trailing == superV.trailing
            effect.leading == superV.leading
        }
        
    }
    
    private func configureSpinner(withColor c: UIColor) {
        //        spinner.translatesAutoresizingMaskIntoConstraints = false
        var frame = originFrame
        frame.size.height *= 0.5
        frame.size.height -= (KLHUD.spinnerTopPadding + KLHUD.spinnerToLabelPadding * 0.5)
        
        frame.origin.y = KLHUD.spinnerTopPadding
        
        //        frame.origin.x = 8
        //        frame.size.width -= 16
        
        spinner.frame = frame
        spinner.contentMode = .center
        spinner.color = c
        
        addSubview(spinner)
        positionSpinner(inView: self)
    }
    
    private func positionSpinner(inView view: UIView) {
        //        view.addSubview(spinner)
        constrain(spinner) { (spin) in
            let superView = spin.superview!
            spin.top == (superView.top + KLHUD.spinnerTopPadding)
            spin.bottom == superView.centerY - (KLHUD.spinnerToLabelPadding * 0.5)
            spin.centerX == superView.centerX
            spin.width == 60
        }
    }
    
    private func configureLabel() {
        //        descLabel.translatesAutoresizingMaskIntoConstraints = false
        descLabel.textAlignment = .center
        descLabel.lineBreakMode = .byWordWrapping
        descLabel.contentMode = .center
        descLabel.numberOfLines = 0
        descLabel.minimumScaleFactor = 0.1
        
        addSubview(descLabel)
        positionLabel(inView: self)
    }
    
    private func positionLabel(inView view: UIView) {
        //        descLabel.layer.anchorPoint = CGPoint.init(x: 0.5, y: 0.5)
        //        descLabel.backgroundColor = .red
        constrain(descLabel) { (label) in
            let superView = label.superview!
            label.top == superView.centerY + (KLHUD.spinnerToLabelPadding * 0.5)
            label.bottom >= superView.bottom - KLHUD.labelToBottomPadding
            label.centerX == superView.centerX
            label.width == superView.width - 10
        }
    }
    
    private func configureImgView() {
        imgView.contentMode = .scaleAspectFit
        addSubview(imgView)
        positionImgView(inView: self)
    }
    
    private func positionImgView(inView view: UIView) {
        constrain(imgView) { (img) in
            let superView = img.superview!
            img.top == (superView.top + KLHUD.spinnerTopPadding)
            img.bottom == superView.centerY - (KLHUD.spinnerToLabelPadding * 0.5)
            img.centerX == superView.centerX
            img.width == 60
        }
    }
    
    //MARK: - Public Functions
    //MARK: Animation
    
    private var viewW: NSLayoutConstraint!
    private var viewH: NSLayoutConstraint!
    
    
    var viewConstrainGroup: ConstraintGroup!
    var transparentBlocker: UIView?
    
    private func showBlocker(inView view: UIView) {
        hideBlocker()
    
        transparentBlocker = UIView.init(frame: view.bounds)
        transparentBlocker?.backgroundColor = .clear
        view.addSubview(transparentBlocker!)
    }
    
    private func hideBlocker() {
        if let _block = transparentBlocker {
            _block.removeFromSuperview()
            transparentBlocker = nil
        }
    }
    
    func startAnimating(inView view: UIView? = nil) {
        print("----StartAnimate----")
        updateType(.spinner)
        if let _view = view {
            showBlocker(inView: _view)
        }
        
        DispatchQueue.main.async {
            if self.superview != nil {
                constrain(clear: self.viewConstrainGroup)
                self.removeFromSuperview()
                
                //            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.55, execute: {
                self.startAnimating(inView: view)
                //            })
                return
            }else {
                view?.addSubview(self)
                self.viewConstrainGroup = constrain(self, block: { (s) in
                    let sup = s.superview!
                    s.center == sup.center
                    self.viewW = s.width == self.originFrame.width
                    self.viewH = s.height == self.originFrame.height
                })
            }
            
            var targetFrame = self.originFrame
            targetFrame.origin.x = view!.bounds.width * 0.5 - (targetFrame.width * 0.5)
            targetFrame.origin.y = view!.bounds.height * 0.5 - (targetFrame.height * 0.5)
            
            
            self.isHidden = false
            self.alpha = 0
            self.viewW.constant = 0
            self.viewH.constant = 0
            self.layoutIfNeeded()
            //        self.spinner.isHidden = false
            
            //        print(view!.center.x)
            //        print(view!.center.y)
            
            //        self.layer.anchorPoint = CGPoint.init(x: 0.5, y: 0.5)
            view?.bringSubview(toFront: self)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.viewW.constant = targetFrame.width
                self.viewH.constant = targetFrame.height
                //            self.center = view!.center
                self.alpha = 1
                self.layoutIfNeeded()
                self.descLabel.layoutIfNeeded()
            }) { (_) in
                
            }
            
//            switch self.type {
//            case .img:
//                break
//            case .spinner:
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
                    self.spinner.startAnimating()
                }
//            }
            
        }
    }
    
    
    func stopAnimating() {
        print("----StartAnimate----")
        hideBlocker()
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIViewAnimationOptions.curveEaseIn, animations: {
            if let w = self.viewW, let h = self.viewH {
                w.constant = 0
                h.constant = 0
            }
            self.viewW?.constant = 0
            self.viewH?.constant = 0
            //            self.center = view!.center
            self.alpha = 0
            self.layoutIfNeeded()
            self.descLabel.layoutIfNeeded()
        }) { (_) in
            self.isHidden = true
            if let group = self.viewConstrainGroup {
                constrain(clear: group)
            }
            
            self.removeFromSuperview()
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
            self.spinner.stopAnimating()
        }
        
        
    }
    
    
    func updateType(_ type: HUDType, text: String? = nil) {
        defer {
            self.type = type
        }
        
        if let _text = text {
            descLabel.text = _text
        }
        
        switch type {
        case .img(let img):
            imgView.image = img
            imgView.isHidden = false
            spinner.isHidden = true
        case .spinner:
            imgView.isHidden = true
            spinner.isHidden = false
        }
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}
