//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

@_spi(AdyenInternal)
extension UIView {
    
    /// Attaches top, bottom, left and right anchors of this view to the corresponding anchors inside the specified view.
    /// - IMPORTANT: Both views should be in the same hierarchy.
    /// - Parameter view: Container view
    /// - Parameter padding: Padding values for each edge. Default is 0 on all edges.
    @discardableResult
    public func anchor(inside view: UIView, with padding: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        anchor(inside: .view(view), edgeInsets: EdgeInsets(edgeInsets: padding))
    }

    /// Attaches top, bottom, left and right anchors of this view to the corresponding anchors inside the specified layout guide.
    /// - IMPORTANT: Both views should be in the same hierarchy.
    /// - Parameter margins: The layout guide to constraint to.
    /// - Parameter padding: Padding values for each edge. Default is 0 on all edges.
    @discardableResult
    public func anchor(inside margins: UILayoutGuide, with padding: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        anchor(inside: .layoutGuide(margins), edgeInsets: EdgeInsets(edgeInsets: padding))
    }
    
    /// Attaches the given edges of this view to corresponding anchors inside the specified anchor source.
    /// - Parameters:
    ///   - anchorSource: The anchor source to contain this view.
    ///   - edgeInsets: Edges with inset values on which the views should be anchored. Defaults to all 4 edges with 0 inset each.
    @discardableResult
    public func anchor(
        inside anchorSource: LayoutAnchorSource,
        edgeInsets: EdgeInsets = .zero
    ) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        
        var constraints: [NSLayoutConstraint] = []
        if let top = edgeInsets.top {
            constraints.append(topAnchor.constraint(
                equalTo: anchorSource.anchorSet.topAnchor,
                constant: top
            ))
        }
        if let left = edgeInsets.left {
            constraints.append(leadingAnchor.constraint(
                equalTo: anchorSource.anchorSet.leadingAnchor,
                constant: left
            ))
        }
        if let bottom = edgeInsets.bottom {
            constraints.append(bottomAnchor.constraint(
                equalTo: anchorSource.anchorSet.bottomAnchor,
                constant: bottom
            ))
        }
        if let right = edgeInsets.right {
            constraints.append(trailingAnchor.constraint(
                equalTo: anchorSource.anchorSet.trailingAnchor,
                constant: right
            ))
        }
        
        NSLayoutConstraint.activate(constraints)
        return constraints
    }

    /// Wrap the view inside a container view with certain edge insets
    ///
    /// - Parameter insets: The insets inside the container view.
    public func wrapped(with insets: UIEdgeInsets = .zero) -> UIView {
        let containerView = UIView()
        containerView.addSubview(self)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        translatesAutoresizingMaskIntoConstraints = false
        anchor(inside: containerView, with: insets)
        return containerView
    }

    /// An enum to specify an anchor source
    public enum LayoutAnchorSource {
        
        /// Regular `UIView` object
        case view(UIView)
        
        /// Specified layout guide such as Layout Margins or Safe Area.
        case layoutGuide(UILayoutGuide)
        
        fileprivate var anchorSet: AnyAnchorSet {
            switch self {
            case let .view(view as AnyAnchorSet):
                return view
            case let .layoutGuide(layoutGuide):
                return layoutGuide
            }
        }
    }
    
    /// Inset distances for views that can be nil.
    public struct EdgeInsets {
        
        public var top: CGFloat?

        public var left: CGFloat?

        public var bottom: CGFloat?

        public var right: CGFloat?
        
        /// Creates insets with 0 on all 4 values.
        public static var zero: EdgeInsets {
            .init(top: 0, left: 0, bottom: 0, right: 0)
        }
        
        internal init(edgeInsets: UIEdgeInsets) {
            top = edgeInsets.top
            left = edgeInsets.left
            bottom = edgeInsets.bottom
            right = edgeInsets.right
        }
        
        public init(top: CGFloat? = nil, left: CGFloat? = nil, bottom: CGFloat? = nil, right: CGFloat? = nil) {
            self.top = top
            self.left = left
            self.bottom = bottom
            self.right = right
        }
    }
}

private protocol AnyAnchorSet {
    var topAnchor: NSLayoutYAxisAnchor { get }
    var leadingAnchor: NSLayoutXAxisAnchor { get }
    var bottomAnchor: NSLayoutYAxisAnchor { get }
    var trailingAnchor: NSLayoutXAxisAnchor { get }
}

extension UIView: AnyAnchorSet {}
extension UILayoutGuide: AnyAnchorSet {}
