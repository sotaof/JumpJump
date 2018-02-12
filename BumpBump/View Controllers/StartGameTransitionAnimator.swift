//
// Created by ocean on 2018/2/12.
// Copyright (c) 2018 ocean. All rights reserved.
//

import UIKit

class StartGameTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        guard let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
              let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else {
            return
        }
        toVC.view.alpha = 0.0
        fromVC.view.alpha = 1.0
        containerView.addSubview(toVC.view)
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            toVC.view.alpha = 1.0
            fromVC.view.alpha = 0.0
        }) { flag in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}