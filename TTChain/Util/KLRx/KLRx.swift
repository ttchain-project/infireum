//
//  KLRx.swift
//  EZExchange
//
//  Created by Keith Lee on 2018/1/23.
//  Copyright © 2018年 GIT. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
protocol Rx {
    var bag: DisposeBag { get set }
}

extension Reactive where Base: UITextField {
    /// Rx Feature, The function is for UIPickerView as input view, if the textfield is closed before user select any row, auto select the first row of each component if the dataSource is not empty.
    ///
    /// - Parameter bag:
    func autoSelectFirstRowOfPickerViewIfNeeded(inBag bag: DisposeBag) {
        controlEvent(UIControlEvents.editingDidEnd)
            .filter {
                //                [unowned self]
                _ -> Bool in
                guard let inputView = self.base.inputView as? UIPickerView else { return false }
                let components = inputView.numberOfComponents
                guard components > 0 else { return false }
                for component in 0..<components {
                    let selectedRow = inputView.selectedRow(inComponent: component)
                    if selectedRow == -1 {
                        return true
                    }
                }
                
                return false
            }
            .take(1)
            .subscribe(onNext:{
                //                [unowned self] _ in
                let inputView = self.base.inputView as! UIPickerView
                
                for component in 0..<inputView.numberOfComponents {
                    if inputView.numberOfRows(inComponent: component) > 0 {
                        inputView.selectRow(0,
                                            inComponent: component,
                                            animated: true)
                        if let delegate = inputView.delegate {
                            delegate.pickerView?(inputView,
                                                 didSelectRow: 0,
                                                 inComponent: component)
                        }
                    }
                }
            })
            .disposed(by: bag)
    }
    
    var isSecured: Binder<Bool> {
        return Binder<Bool>.init(self.base, binding: { (field, _isSecured) in
            field.isSecureTextEntry = _isSecured
        })
    }
}

extension Reactive where Base: UIScrollView {
    public var contentSize: Observable<CGSize> {
        return observe(CGSize.self, "contentSize").map { $0! }
    }
}

extension Reactive where Base: UILabel {
    public var textColor: Binder<UIColor> {
        return Binder<UIColor>.init(self.base, binding: { (label, color) in
            label.textColor = color
        })
    }
}

//extension Reactive where Base: UIControl {
//    public var isEnabled: Observable<Bool> {
//        return observe(Bool.self, "isEnabled").map { $0! }
//    }
//}

/// APIRequester should be conformed by any class able to send api request, such kind of class should provide both api start annd finish observable to notify the requet state to the observer. This is mainly designed for view model, a view model able to send api request should provide these informations to the binding view. Then the binding view will able to update to correspond view state when catch a start/complete .next event.
protocol APIRequester {
    var onStartAPIRequest: Observable<()> { get }
    var onCompleteAPIRequest: Observable<()> { get }
}

protocol KLVMVC: Rx, KLInstanceSetupViewController {
    associatedtype ViewModel: Rx
    var viewModel: ViewModel! { get set }
}

infix operator <-> : AssignmentPrecedence
//Bidirectional bind RxSwift, swift 3
public func <-> <C:ControlPropertyType, E>(property: C, relay: BehaviorRelay<E>) -> Disposable where C.E == E {
    let bindToUIDisposable = relay.asObservable()
        .bind(to: property)
    
    let bindToVariable = property
        .subscribe(onNext: { n in
//            if let n = n {
                relay.accept(n)
//            }
        }, onCompleted:  {
            bindToUIDisposable.dispose()
        })
    
    return Disposables.create([bindToUIDisposable, bindToVariable])
}

/// Provide a custom two way binding between control property and variable with diff type, need two closure to define if the pass will success or not
///
/// - Parameters:
///   - property:
///   - variable:
///   - toVariable:
///   - toProperty:
/// - Returns: 
public func twoWayBind<E,C: ControlPropertyType>(property: C, relay: BehaviorRelay<E>, toVariable: @escaping (C.E) -> E?, toProperty: @escaping (E) -> C.E) -> Disposable {
    let bindToUIDisposable = relay.asObservable().map { toProperty($0) }.bind(to: property)
    let bindToVariable = property
        .map { toVariable($0) }
        .subscribe(onNext: { n in
            if let n = n {
                relay.accept(n)
            }
        }, onCompleted:  {
            bindToUIDisposable.dispose()
        })
    
    return Disposables.create([bindToUIDisposable, bindToVariable])
}

//MARK: - View Rx
extension Reactive where Base: UIView {
    var cornerRadius: Binder<CGFloat> {
        return Binder.init(self.base, binding: { (view, rad) in
            view.cornerRadius = rad
        })
    }
    
    func enableCircleSided() -> Disposable {
        return observe(CGRect.self, "frame")
            .filter { $0 != nil }
            .map { $0! }
            .distinctUntilChanged()
            .map { $0.height * 0.5 }
            .bind(to: cornerRadius)
    }
}


//MARK: - RxGesture Wrapper
import RxGesture
extension Reactive where Base: UIView {
    var klrx_tap: Driver<Void> {
        return tapGesture().skip(1).map { _ in () }.asDriver(onErrorJustReturn: ())
    }
}
