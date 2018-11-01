//
//  AJNavigationController.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2018/11/1.
//  Copyright © 2018 gib. All rights reserved.
//

import UIKit
import Cartography
import RxSwift
import RxCocoa

class AJNavigationController: UINavigationController {
    
    private var navBarImageView: UIImageView?
    private var titleLabel: UILabel?
    private var backButton: UIButton?
    private var settingsButton: UIButton?
    private var menuDoughnutButton : UIButton?
    
    lazy var onDoughnutAction: Driver<Void> = {
        guard menuDoughnutButton != nil else {
            return Driver.empty()
        }
        return menuDoughnutButton!.rx.tap.asDriver()
    }()
    
    lazy var onBackButtonAction: Driver<Void> = {
        guard backButton != nil else {
            return Driver.empty()
        }
        return backButton!.rx.tap.asDriver()
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let viewHeight = self.view.height
        let height = CGFloat(93.5)
        navigationBar.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: height)
        self.setupNavBar()
        self.addComponents()
        // Do any additional setup after loading the view.
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func setupNavBar() {
        navigationBar.isTranslucent = true
        navigationBar.barStyle = .blackTranslucent
        
        navBarImageView = UIImageView(image: #imageLiteral(resourceName: "navTitleImage"))
        navBarImageView!.contentMode = .scaleAspectFill
        navBarImageView!.clipsToBounds = true
        navBarImageView!.translatesAutoresizingMaskIntoConstraints = false
        
        //        logoImageView.frame = (navigationController?.navigationBar.frame)!
        view.insertSubview(navBarImageView!, belowSubview: navigationBar)
        
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        view.backgroundColor = .clear
        NSLayoutConstraint.activate([
            navBarImageView!.leftAnchor.constraint(equalTo: view.leftAnchor),
            navBarImageView!.rightAnchor.constraint(equalTo: view.rightAnchor),
            navBarImageView!.topAnchor.constraint(equalTo: view.topAnchor),
            navBarImageView!.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor)
            ])
        //        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named:"navTitleImage"),
        //                                                                    for: .default)
    }

    
    func addComponents() {
        
        
        let backButton = UIButton.init(type: .custom)
        self.navBarImageView?.addSubview(backButton)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        constrain(backButton) { (button) in
            button.left == button.superview!.left + 20
            button.centerY == button.superview!.centerY
            button.height == 30
            button.width == 25
        }
        self.backButton = backButton
        
        self.navBarImageView?.isUserInteractionEnabled = true
        
        let menuDoughnut = UIButton.init(type: .custom)
        self.navBarImageView?.addSubview(menuDoughnut)
        menuDoughnut.setImageForAllStates(#imageLiteral(resourceName: "LOGO"))
        menuDoughnut.translatesAutoresizingMaskIntoConstraints = false
        constrain(menuDoughnut) { (button) in
            button.left == button.superview!.left + 20
            button.centerY == button.superview!.centerY
            button.height == 45
            button.width == 45
        }
        self.menuDoughnutButton = menuDoughnut
        
        let settingsButton = UIButton.init(type: .custom)
        self.navBarImageView?.addSubview(settingsButton)
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        constrain(settingsButton) { (button) in
            button.right == button.superview!.right + 20
            button.centerY == button.superview!.centerY
            button.height == 45
            button.width == 45
        }
        self.settingsButton = settingsButton
        
        let titleLabel = UILabel.init(text: title)
        self.navBarImageView?.addSubview(titleLabel)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        constrain(titleLabel,settingsButton,menuDoughnut) { label,setting, doughNut in
            label.center == (label.superview?.center)!
//            label.width == (label.superview?.width)! * 0.7
            label.left == doughNut.right + 20
            label.right == setting.left - 20
        }
        
        self.titleLabel = titleLabel
    }
    
    func setTitleString(title: String) {
        self.titleLabel!.text = title
    }
    func showBackButton() {
        self.menuDoughnutButton?.isHidden = true
        self.backButton?.isHidden = false
    }
    func showMenuDoughnut() {
        self.menuDoughnutButton?.isHidden = false
        self.backButton?.isHidden = true
    }
    
}
