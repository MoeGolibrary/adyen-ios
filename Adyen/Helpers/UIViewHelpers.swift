//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import UIKit

/// Adds helper functionality to any `UIView` instance through the `adyen` property.
@_spi(AdyenInternal)
extension AdyenScope where Base: UIView {
    
    @discardableResult
    public func snapshot(forceRedraw: Bool = false) -> UIImage? {
        if forceRedraw {
            snapshot(forceRedraw: false)
        }
        
        UIGraphicsBeginImageContextWithOptions(base.bounds.size, false, 0.0)
        base.drawHierarchy(in: base.bounds, afterScreenUpdates: true)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }
    
    public func hide(
        animationKey: String,
        hidden: Bool,
        animated: Bool
    ) {
        if animated {
            hideWithAnimation(
                animationKey: animationKey,
                hidden
            )
        } else {
            hideWithoutAnimation(hidden)
        }
    }

    private func hideWithAnimation(
        animationKey: String,
        _ hidden: Bool
    ) {
        let context = KeyFrameAnimationContext(
            animationKey: animationKey,
            duration: 0.35,
            delay: 0,
            options: [.calculationModeCubicPaced, .beginFromCurrentState],
            animations: { [weak base] in
                UIView.addKeyframe(withRelativeStartTime: hidden ? 0.5 : 0, relativeDuration: 0.5) {
                    base?.isHidden = hidden
                }
                UIView.addKeyframe(withRelativeStartTime: hidden ? 0 : 0.5, relativeDuration: 0.5) {
                    base?.alpha = hidden ? 0 : 1
                }
            },
            completion: { [weak base] _ in
                base?.isHidden = hidden
                base?.alpha = hidden ? 0 : 1
                base?.adyen.updatePreferredContentSize()
            }
        )
        animate(context: context)
    }
    
    private func hideWithoutAnimation(_ hidden: Bool) {
        guard base.isHidden != hidden else { return }
        
        base.isHidden = hidden
        base.alpha = hidden ? 0 : 1
        base.adyen.updatePreferredContentSize()
    }

    public var minimalSize: CGSize {
        let targetSize = CGSize(
            width: Dimensions.expectedWidth(for: base.window),
            height: UIView.layoutFittingCompressedSize.height
        )
        return base.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
    }
}
