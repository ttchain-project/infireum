//
//  KLSideBarAnimator.swift
//  KLCustomTransitions
//
//  Created by Keith Lee on 2018/1/17.
//  Copyright © 2018年 Keith Lee. All rights reserved.
//

import UIKit

@objc
protocol KLSideBarDelegate {
    func dismiss()
}

class KLTransferConfirmAnimator: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
    
    var isPresenting : Bool = true
    
    
    var topReveal: CGFloat = 0
    
    
    var delegate: KLSideBarDelegate?
    var dimmingView: UIView?
    var snapshot: UIView? {
        didSet{
            guard let d = delegate else { return }
            let ges = UITapGestureRecognizer.init(target: d, action: #selector(KLSideBarDelegate.dismiss))
            snapshot?.addGestureRecognizer(ges)
        }
    }
    
    init(topRevealPercentage: CGFloat) {
        super.init()
        topReveal = UIScreen.main.bounds.height * topRevealPercentage
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
//            let toVC = transitionContext.viewController(forKey: .to),
//            let fromView = transitionContext.view(forKey: .from),
            let toView = transitionContext.view(forKey: .to),
            let snapshot = fromVC.view.snapshotView(afterScreenUpdates: true)
            else {
                return
        }
        
        self.snapshot = snapshot
        
        let containerView = transitionContext.containerView
//        var originFrame_From: CGRect
//        var originFrame_To: CGRect
//        var finalFrame_From: CGRect
//        var finalFrame_To: CGRect
//
//        if isPresenting {
//            originFrame_From = fromVC.view.frame
//            let height_to = originFrame_From.height - topReveal
//            originFrame_To = CGRect.init(x: 0, y: 0, width: originFrame_From.width, height: height_to)
//
//            finalFrame_From = originFrame_From.offsetBy(dx: width_to, dy: 0)
//            finalFrame_To = originFrame_To.offsetBy(dx: width_to, dy: 0)
////            snapshot.frame = fromVC.view.frame
////            toView.frame = fromVC.view.frame.offsetBy(dx: -fromVC.view.frame.width, dy: 0)
//        }else {
//            originFrame_From = fromVC.view.frame
//            let width_from = originFrame_From.width
//            originFrame_To = toView.frame.offsetBy(dx: width_from, dy: 0)
//
//            finalFrame_From = originFrame_From.offsetBy(dx: -width_from, dy: 0)
//            finalFrame_To = originFrame_To.offsetBy(dx: -width_from, dy: 0)
//        }
//
//        snapshot.frame = originFrame_From
        var tFrame = snapshot.frame
        if isPresenting {
            tFrame.origin.y += topReveal
            tFrame.size.height -= topReveal
            toView.frame = tFrame
        }else {
            tFrame.size.height += topReveal
            toView.frame = tFrame
        }
        
        if isPresenting {
            if dimmingView == nil {
                dimmingView = UIView.init(frame: snapshot.bounds)
                dimmingView?.backgroundColor = UIColor.black.withAlphaComponent(0.3)
                snapshot.addSubview(dimmingView!)
            }
        }else {
            dimmingView?.removeFromSuperview()
            dimmingView = nil
        }
        
        containerView.addSubview(snapshot)
        containerView.addSubview(toView)
        
        
//        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.9, options: UIViewAnimationOptions.curveLinear, animations: {
//            snapshot.frame = finalFrame_From
//            toView.frame = finalFrame_To
//        }) { (_) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
//        }
        
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = false
        return self
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = true
        return self
    }
    
    
}
