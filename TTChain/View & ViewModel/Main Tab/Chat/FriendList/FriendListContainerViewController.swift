//
//  FriendListContainerViewController.swift
//  OfflineWallet
//
//  Created by Ajinkya Sharma on 2018/11/15.
//  Copyright © 2018 gib. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Cartography


final class FriendListContainerViewController: KLModuleViewController,KLVMVC {
   
    enum Purpose {
        case Browse
        case Search
    }
    
    struct Input {
        let purpose:Purpose
    }
    
    var friendListVC : FriendsListViewController!
    var viewModel: FriendListContainerViewModel!
    typealias ViewModel = FriendListContainerViewModel
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet var leftContraintForTextField: NSLayoutConstraint!
    @IBOutlet var searchTextfieldWidthConstraint: NSLayoutConstraint!
    
    var purpose: Purpose = .Browse
    @IBOutlet weak var searchTextField: UITextField!
    func config(constructor: Input) {
        self.view.layoutIfNeeded()
        self.viewModel = ViewModel.init(input: (), output: ())
        self.friendListVC = FriendsListViewController.instance(searchTextInOut: self.searchTextField.rx.text, searchStatus: self.viewModel.searchStatus)
        self.moveFriendListVC()
        self.setupSearchTextField()
        self.bindView()
        startMonitorLangIfNeeded()
        startMonitorThemeIfNeeded()
       self.purpose = constructor.purpose
        
        switch self.purpose {
        case .Search:
            perform(#selector(showSearchView), with: nil, afterDelay: 0.5)

//            showSearchView()
        default:
            return
        }
    }
    
    var bag: DisposeBag = DisposeBag.init()
    typealias Constructor = Input
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func moveFriendListVC() {
        addChildViewController(friendListVC)
        containerView.addSubview(friendListVC.view)
        friendListVC.didMove(toParentViewController: self)
        constrain(friendListVC.view) { (view) in
            let sup = view.superview!
            view.top == sup.top
            view.bottom == sup.bottom
            view.trailing == sup.trailing
            view.leading == sup.leading
        }
    }
    
    override func renderTheme(_ theme: Theme) {
        let palette = theme.palette
        renderNavBar(tint: palette.nav_item_2, barTint: .clear)
        renderNavTitle(color: palette.nav_item_2, font: .owMedium(size: 20))
        self.titleLabel.set(textColor: palette.nav_item_2, font: .owMedium(size: 18))
        self.backButton.setImageForAllStates(#imageLiteral(resourceName: "arrowNavBlack").withRenderingMode(.alwaysTemplate))
        self.backButton.tintColor = palette.nav_item_2
        
        self.view.backgroundColor = palette.application_main
    }
    override func renderLang(_ lang: Lang) {
        self.titleLabel.text = lang.dls.contact_title
    }
    func bindView() {
        self.backButton.rx.tap.asDriver().drive(onNext: { _ in
            self.navigationController?.popViewController(animated: true)
        }).disposed(by: bag)
    }
    
    func setupSearchTextField() {
        
        let leftButton = UIButton.init(type: .custom)
        leftButton.frame = CGRect.init(x: 0, y: 0, width: 20, height: 20)
        let img = #imageLiteral(resourceName: "iconSearchDark")
        leftButton.setImageForAllStates(img.withRenderingMode(.alwaysTemplate))
        leftButton.tintColor = .white
        leftButton.rx.tap.asDriver().drive(onNext: {[unowned self] _ in
            if !self.viewModel.searchStatus.value {
                self.showSearchView()
            }
        }).disposed(by: bag)
        
        self.searchTextField.leftView = leftButton
        self.searchTextField.delegate = self
        self.searchTextField.leftViewMode = .always
    }
    
    @objc func showSearchView() {
        self.leftContraintForTextField.isActive = true
        self.searchTextfieldWidthConstraint.isActive = false
        self.viewModel.searchStatus.accept(true)
        self.titleLabel.isHidden = true
        self.searchTextField.becomeFirstResponder()
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    func hideSearchView()  {
        self.leftContraintForTextField.isActive = false
        self.searchTextfieldWidthConstraint.isActive = true
        self.viewModel.searchStatus.accept(false)
        self.titleLabel.isHidden = false
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
            self.searchTextField.resignFirstResponder()
        }
    }
}

extension FriendListContainerViewController : UITextFieldDelegate {
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.hideSearchView()
        return true
    }

}
