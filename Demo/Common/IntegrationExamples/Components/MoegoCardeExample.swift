//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
@_spi(AdyenInternal) import AdyenCard
import AdyenComponents
import AdyenSession

internal final class MoegoCardeExample: UIViewController {

//    private var cardComponent: UIView!
    
//    internal lazy var apiClient = ApiClientHelper.generateApiClient()
//    
//    internal lazy var context: AdyenContext = generateContext()

    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(stackView)
        view.backgroundColor = .gray
        
        stackView.addArrangedSubview(cardViewController.view)
        addChild(cardViewController)
        cardViewController.didMove(toParent: self)
        
        cardViewController.view.backgroundColor = .green
        
        stackView.addArrangedSubview(submitButton)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 150),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -50)
        ])
        
        // 父视图根据子视图自适应高度
        // 1. 父视图不要设置heightAnchor，只设置widthAnchor;
        // 2. 子视图设置widthAnchor和heightAnchor都与父视图相等
        NSLayoutConstraint.activate([
            cardViewController.view.widthAnchor.constraint(equalTo: stackView.widthAnchor),
        ])
        
        NSLayoutConstraint.activate([
            submitButton.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 48),
            submitButton.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -48),
            submitButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        cardViewController.assignInitialFirstResponder()
    }
    
    lazy var cardViewController: CardViewController = {
        let configuration = generateConfig()
        let apiContext = try! APIContext(environment: Environment.test, clientKey: "local_DUMMYKEYFORTESTING")
        
        let formViewController = CardViewController(
            configuration: configuration,
            shopperInformation: configuration.shopperInformation,
            formStyle: configuration.style,
            payment: nil,
            logoProvider: LogoURLProvider(environment: apiContext.environment),
            supportedCardTypes: [.masterCard, .visa, .maestro],
            initialCountryCode: "US",
            scope: String(describing: self),
            localizationParameters: configuration.localizationParameters
        )
            
        return formViewController
    }()
    
    private func generateConfig() -> CardComponent.Configuration {
        let style = FormComponentStyle()
        var configuration = CardComponent.Configuration(style: style)
        configuration.showsSubmitButton = false
        
        return configuration
    }
    
    private lazy var stackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .orange
        return stackView
    }()
    
    private lazy var submitButton: UIButton = {
        let submitButton = UIButton(type: .system)
        submitButton.setTitle("提交", for: .normal)
        submitButton.backgroundColor = .systemBlue
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.layer.cornerRadius = 10
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.addTarget(self, action: #selector(submitClicked), for: .touchUpInside)
        
        return submitButton
    }()
    
    @objc private func submitClicked() {
        if cardViewController.validate() {
            let card = cardViewController.card;
        
            print("number: \(card.number ?? ""), securityCode: \(card.securityCode ?? ""), expiryMonth: \(card.expiryMonth ?? ""), expiryYear: \(card.expiryYear ?? "")");
        }
    }
}


