//
//  UINavigationController+QuickBarItemSetup.swift
//  UniversalModule
//
//  Created by keith.lee on 2016/10/12.
//  Copyright © 2016年 git4u. All rights reserved.
//

import UIKit

extension UIViewController {
    //MARK: 將View的行為綁定到左邊的side menu
    @discardableResult func barButton(target: Any, selector: Selector, tintColor: UIColor? = .black, image: UIImage? = nil, title: String? = nil) -> (UIBarButtonItem, UIButton) {
        let button = UIButton(type: .system)
        if let tintColor = tintColor {
            button.tintColor = tintColor
        }
        
        var resultImage = image
        if let tc = tintColor, let _image = image {
            let newImage = _image.withRenderingMode(.alwaysTemplate)
            UIGraphicsBeginImageContextWithOptions(_image.size, false, newImage.scale)
            tc.set()
            newImage.draw(in: CGRect(x:0, y:0, width:_image.size.width, height:newImage.size.height))

            resultImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
        }

        button.setTitle(title, for: .normal)
        button.setImage(resultImage, for: .normal)
        button.frame = CGRect(origin: .zero, size: CGSize(width: 30, height: 30))
        button.addTarget(target, action: selector, for: .touchUpInside)
        
        let barButton = UIBarButtonItem(customView: button)

        return (barButton, button)
    }

    func createCustomRightBarButton( img:UIImage, target:Any, action:Selector) {
        
        let button = UIButton.init(type: .custom)
        
        var resultImage = img
        let _image = resultImage
        let newImage = _image.withRenderingMode(.alwaysOriginal)
        UIGraphicsBeginImageContextWithOptions(_image.size, false, newImage.scale)
        newImage.draw(in: CGRect(x:0, y:0, width:_image.size.width, height:newImage.size.height))
        resultImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        button.setImage(resultImage, for: .normal)
        button.frame = CGRect(origin: .zero, size: CGSize(width: 30, height: 30))
        button.addTarget(target, action: action, for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton

    }
    
    @discardableResult func changeLeftBarButton(target: Any, selector: Selector, tintColor: UIColor? = .black, image: UIImage? = nil, title: String? = nil) -> UIButton {
        let btns = barButton(target: target, selector: selector, tintColor: tintColor, image: image, title: title)
        self.navigationItem.leftBarButtonItem = btns.0
        return btns.1
    }


    @discardableResult func changeLeftBarButtonToDismissToRoot(tintColor: UIColor? = .black, image: UIImage? = nil, title: String? = nil) -> UIButton {
        return changeLeftBarButton(target: self, selector: #selector(UIViewController.dismissRoot(sender:)), tintColor: tintColor, image: image, title: title)
    }

    @discardableResult func changeLeftBarButtonToPopToRoot(tintColor: UIColor? = .black, image: UIImage? = nil, title: String? = nil) -> UIButton {
        return changeLeftBarButton( target: self, selector: #selector(UIViewController.popToRoot(sender:)), tintColor: tintColor, image: image, title: title)
    }
    
    @discardableResult func createRightBarButton(
        target: Any, selector: Selector,
        image: UIImage? = nil, title: String? = nil,
        toColor tintColor: UIColor? = UIColor.blue,
        shouldClear: Bool = false,
        size: CGSize? = nil
        ) -> UIButton {
        
        let button = UIButton(type: .system)
        button.tintColor = tintColor!
        let s = size ?? CGSize(width: 30, height: 30)
        button.frame = CGRect(origin: .zero, size: s)
        button.addTarget(target, action: selector, for: .touchUpInside)
        var resultImage = image
        if let img = image {
            resultImage = img
            if let tc = tintColor {
                let newImage = img.withRenderingMode(.alwaysTemplate)
                var imgSize : CGSize
                imgSize = s
                
                UIGraphicsBeginImageContextWithOptions(imgSize, false, newImage.scale)
                
                tc.set()
                newImage.draw(in: CGRect(x:0, y:0, width: s.height, height: s.height))
                resultImage = UIGraphicsGetImageFromCurrentImageContext()!
                UIGraphicsEndImageContext()
            }
        }
        
        button.setImage(resultImage, for: .normal)
        button.setTitle(title, for: .normal)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
//        button.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: 8, bottom: 8, right: 8)
        button.contentMode = .center
        button.titleLabel?.contentMode = .center
        button.contentVerticalAlignment = .fill
        
        let barButton = UIBarButtonItem(customView: button)
        if shouldClear {
            self.navigationItem.rightBarButtonItem = barButton
        }else {
            if let rBs = self.navigationItem.rightBarButtonItems {
                self.navigationItem.rightBarButtonItems = rBs + [barButton]
            }else {
                self.navigationItem.rightBarButtonItem = barButton
            }
        }
        
        
        return button
    }

    
    //MARK: 將View的行為綁定到右邊的side menu
    func changeBackBarButton(toColor tintColor: UIColor? = .black, image: UIImage? = nil, title: String? = nil) {
        changeLeftBarButton(target: self, selector: #selector(UIViewController.pop(sender:)), tintColor: tintColor, image: image, title: title)
    }
    
    func disablePushBackButton(){
        let clearView = UIView.init()
        clearView.backgroundColor = UIColor.clear
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: clearView)
    }
    
    @objc func pop(sender:NSObject?){
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    @objc func popToRoot(sender: NSObject?){
        let _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func dismissRoot(sender:NSObject?){
        self.dismiss(animated: true, completion: nil)
    }
    
    func renderNavTitle(color: UIColor, font: UIFont) {
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedStringKey.foregroundColor : color,
            NSAttributedStringKey.font : font
        ]
    }
    
    func renderNavBar(tint: UIColor, barTint: UIColor) {
        navigationController?.navigationBar.tintColor = tint
        navigationController?.navigationBar.barTintColor = barTint
        if barTint == .clear {
            makeNavBarTransparent()
        }
    }
    
    func changeNavShadowVisibility(_ hasShadow: Bool) {
        if hasShadow {
            navigationController?.navigationBar.renderShadow()
        }else {
            navigationController?.navigationBar.clearShadow()
        }
    }
    
    func makeNavBarTransparent() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.setBackgroundImage(#imageLiteral(resourceName: "navTitleImage").resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0 ,right: 0), resizingMode: .stretch), for: .default)

        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = .clear
    }
}
