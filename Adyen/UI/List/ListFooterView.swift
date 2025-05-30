//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

internal final class ListFooterView: UIView {

    /// The list section header style.
    internal let style: ListSectionFooterStyle

    internal init(title: String, style: ListSectionFooterStyle) {
        self.title = title
        self.style = style

        super.init(frame: .zero)

        backgroundColor = style.backgroundColor
        addSubview(stackView)

        stackView.adyen.anchor(inside: self)
        
        isAccessibilityElement = true
        accessibilityLabel = title
        accessibilityTraits = .header
    }

    @available(*, unavailable)
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Title Label

    private let title: String

    // MARK: - UI

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleContainerView])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 0
        stackView.isUserInteractionEnabled = false
        stackView.preservesSuperviewLayoutMargins = true

        return stackView
    }()

    private lazy var titleContainerView: UIView = {
        titleBackgroundView.adyen.wrapped(with: .init(top: 6, left: 16, bottom: 12, right: 16))
    }()

    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel(style: style.title)
        titleLabel.numberOfLines = 0
        titleLabel.isAccessibilityElement = false
        titleLabel.accessibilityIdentifier = ViewIdentifierBuilder.build(
            scopeInstance: "Adyen.ListFooterView.\(title)",
            postfix: "titleLabel"
        )
        titleLabel.text = title

        return titleLabel
    }()

    private lazy var titleBackgroundView: UIView = {
        let view = titleLabel.adyen.wrapped(with: .init(top: 8, left: 16, bottom: 8, right: 16))
        view.backgroundColor = style.title.backgroundColor
        view.adyen.round(using: style.title.cornerRounding)
        return view
    }()

}
