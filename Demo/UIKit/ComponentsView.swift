//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import PassKit
import UIKit

internal final class ComponentsView: UIView {
    
    internal init() {
        super.init(frame: .zero)
        
        addSubview(tableView)
        
        tableView.anchor(inside: self)
        tableView.tableHeaderView = switchContainerView
        switchContainerView.bounds.size.height = 55
        
        addSubview(activityIndicator)
        activityIndicator.anchor(inside: self)
    }
    
    @available(*, unavailable)
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal var isUsingSession: Bool {
        sessionSwitch.isOn
    }
    
    internal var showsLoadingIndicator: Bool {
        get {
            self.activityIndicator.isAnimating
        }
        set {
            if newValue {
                self.activityIndicator.startAnimating()
            } else {
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    // MARK: - Items
    
    internal var items = [[ComponentsItem]]()
    
    // MARK: - Loading
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator: UIActivityIndicatorView
        if #available(iOS 13.0, *) {
            activityIndicator = UIActivityIndicatorView(style: .large)
        } else {
            activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        }
        activityIndicator.hidesWhenStopped = true
        
        if #available(iOS 13.0, *) {
            activityIndicator.color = .label
            activityIndicator.backgroundColor = .systemGroupedBackground.withAlphaComponent(0.7)
        } else {
            activityIndicator.backgroundColor = .black.withAlphaComponent(0.3)
        }
        
        return activityIndicator
    }()
    
    // MARK: - Table View
    
    private lazy var tableView: UITableView = {
        var tableViewStyle = UITableView.Style.grouped
        if #available(iOS 13.0, *) {
            tableViewStyle = .insetGrouped
        }
        
        let tableView = UITableView(frame: .zero, style: tableViewStyle)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 56.0
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()
    
    private lazy var sessionSwitch: UISwitch = {
        let sessionSwitch = UISwitch()
        sessionSwitch.isOn = true
        return sessionSwitch
    }()
    
    private lazy var switchStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 25
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Using Session"
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(sessionSwitch)
        return stackView
    }()
    
    private lazy var switchContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(switchStackView)
        switchStackView.anchor(
            inside: view.layoutMarginsGuide,
            with: .init(top: 0, left: 20, bottom: 0, right: 20)
        )
        return view
    }()
    
    // MARK: - Apple Pay
    
    @objc fileprivate func onApplePayButtonTap() {
        items.flatMap { $0 }
            .filter(\.isApplePay)
            .first
            .map { $0.selectionHandler() }
    }
    
    private func setUpApplePayCell(_ cell: UITableViewCell) {
        let style: PKPaymentButtonStyle = {
            if #available(iOS 14.0, *) {
                return .automatic
            }
            
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return .white
            default:
                return .black
            }
        }()
        
        let contentView = cell.contentView
        
        let payButton = PKPaymentButton(paymentButtonType: .plain, paymentButtonStyle: style)
        contentView.addSubview(payButton)
        payButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            payButton.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
            payButton.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
            payButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            payButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        
        payButton.addTarget(self, action: #selector(onApplePayButtonTap), for: .touchUpInside)
    }
}

extension ComponentsView: UITableViewDataSource {
    
    internal func numberOfSections(in tableView: UITableView) -> Int {
        items.count
    }
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items[section].count
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = {
            let identifier = "Cell"
            if let cell = tableView.dequeueReusableCell(withIdentifier: identifier) { return cell }
            return UITableViewCell(style: .subtitle, reuseIdentifier: identifier)
        }()
        
        let item = items[indexPath.section][indexPath.row]
        if item.isApplePay == false {
            cell.textLabel?.font = .preferredFont(forTextStyle: .headline)
            cell.textLabel?.adjustsFontForContentSizeCategory = true
            cell.textLabel?.text = item.title
            
            cell.detailTextLabel?.font = .preferredFont(forTextStyle: .caption1)
            if #available(iOS 13.0, *) {
                cell.detailTextLabel?.textColor = .secondaryLabel
            }
            cell.detailTextLabel?.adjustsFontForContentSizeCategory = true
            cell.detailTextLabel?.text = item.subtitle
        } else {
            setUpApplePayCell(cell)
        }
        
        return cell
    }
    
}

extension ComponentsView: UITableViewDelegate {
    
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        items[indexPath.section][indexPath.item].selectionHandler()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
