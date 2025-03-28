//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable @_spi(AdyenInternal) import AdyenCard
@testable import AdyenDropIn
import XCTest

class PreselectedPaymentComponentDelegateMock: PreselectedPaymentMethodComponentDelegate {
    
    var didRequestAllPaymentMethodsCalled: Bool = false
    var didProceedCalled: Bool = false
    var componentToProceed: PaymentComponent?
    
    func didRequestAllPaymentMethods() {
        didRequestAllPaymentMethodsCalled = true
    }
    
    func didProceed(with component: PaymentComponent) {
        didProceedCalled = true
        componentToProceed = component
    }
}

class PreselectedPaymentComponentTests: XCTestCase {
    
    let payment = Payment(amount: Amount(value: 4200, currencyCode: "EUR"), countryCode: "DE")
    var sut: PreselectedPaymentMethodComponent!
    var component: StoredPaymentMethodComponent!
    var delegate: PreselectedPaymentComponentDelegateMock!
    
    override func run() {
        AdyenDependencyValues.runTestWithValues {
            $0.imageLoader = ImageLoaderMock()
        } perform: {
            super.run()
        }
    }
    
    override func setUp() {
        component = StoredPaymentMethodComponent(paymentMethod: getStoredCard(), context: Dummy.context)
        sut = PreselectedPaymentMethodComponent(
            component: component,
            title: "Test title",
            style: FormComponentStyle(),
            listItemStyle: ListItemStyle()
        )
        
        delegate = PreselectedPaymentComponentDelegateMock()
        sut.delegate = delegate
    }
    
    override func tearDown() {
        sut = nil
        delegate = nil
    }

    func testRequiresKeyboardInput() {
        let viewController = sut.viewController as! FormViewController

        XCTAssertFalse(viewController.requiresKeyboardInput)
    }
    
    func testTitle() {
        XCTAssertEqual(sut.viewController.title, "Test title")
    }
    
    func testUIElements() {
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenDropIn.PreselectedPaymentMethodComponent.defaultComponent"))
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenDropIn.PreselectedPaymentMethodComponent.openAllButton"))
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenDropIn.PreselectedPaymentMethodComponent.separator"))
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenDropIn.PreselectedPaymentMethodComponent.submitButton"))
    }
    
    func testPressSubmitButton() {
        let button: SubmitButton! = sut.viewController.view.findView(with: "AdyenDropIn.PreselectedPaymentMethodComponent.submitButton.button")
        button.sendActions(for: .touchUpInside)
        
        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            XCTAssertTrue(self.delegate.didProceedCalled)
            XCTAssertFalse(self.delegate.didRequestAllPaymentMethodsCalled)
            XCTAssertTrue(self.delegate.componentToProceed === self.component)
            
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
    }

    func testSubmitButtonLoading() {
        setupRootViewController(sut.viewController)
        let button: SubmitButton! = sut.viewController.view.findView(with: "AdyenDropIn.PreselectedPaymentMethodComponent.submitButton.button")
        XCTAssertFalse(button.showsActivityIndicator)
        sut.startLoading(for: component)

        wait(for: .milliseconds(300))
        
        XCTAssertTrue(button.showsActivityIndicator)
        self.sut.stopLoadingIfNeeded()
        XCTAssertFalse(button.showsActivityIndicator)
    }
    
    func testPressOpenAllButton() {
        let button: SubmitButton! = sut.viewController.view.findView(with: "AdyenDropIn.PreselectedPaymentMethodComponent.openAllButton.button")
        button!.sendActions(for: .touchUpInside)
        
        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            XCTAssertFalse(self.delegate.didProceedCalled)
            XCTAssertTrue(self.delegate.didRequestAllPaymentMethodsCalled)
            XCTAssertNil(self.delegate.componentToProceed)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
    }
    
    func testUICustomization() {
        var formStyle = sut.style
        formStyle.backgroundColor = .green
        formStyle.separatorColor = .red
        formStyle.mainButtonItem = FormButtonItemStyle(button: ButtonStyle(title: TextStyle(font: .systemFont(ofSize: 20), color: .cyan, textAlignment: .center), cornerRadius: 0, background: .brown), background: .red)
        formStyle.secondaryButtonItem = FormButtonItemStyle(button: ButtonStyle(title: TextStyle(font: .systemFont(ofSize: 22), color: .brown, textAlignment: .center), cornerRadius: 0, background: .cyan), background: .black)
        
        var listStyle = sut.listItemStyle
        listStyle.image.backgroundColor = .red
        listStyle.title.color = .white
        listStyle.subtitle.color = .white
        
        component = StoredPaymentMethodComponent(paymentMethod: getStoredCard(), context: Dummy.context)
        sut = PreselectedPaymentMethodComponent(component: component, title: "", style: formStyle, listItemStyle: listStyle)
        
        setupRootViewController(sut.viewController)
        
        let view = sut.viewController.view!
        let listView = view.findView(with: "AdyenDropIn.PreselectedPaymentMethodComponent.defaultComponent")
        let listViewTitle: UILabel! = listView!.findView(by: "titleLabel")
        let listViewSubtitle: UILabel! = listView!.findView(by: "subtitleLabel")
        
        let submitButtonContainer = view.findView(with: "AdyenDropIn.PreselectedPaymentMethodComponent.submitButton")
        let submitButton = submitButtonContainer!.findView(by: "button")
        let submitButtonLabel: UILabel! = submitButton!.findView(by: "titleLabel")
        
        let openAllButtonContainer = view.findView(with: "AdyenDropIn.PreselectedPaymentMethodComponent.openAllButton")
        let openAllButton = openAllButtonContainer!.findView(by: "button")
        let openAllButtonLabel: UILabel! = openAllButton!.findView(by: "titleLabel")
        
        let separator = view.findView(by: "separatorLine")
        
        wait(for: .milliseconds(300))
        
        XCTAssertEqual(view.backgroundColor, .green)
        XCTAssertEqual(listViewTitle.textColor, .white)
        XCTAssertEqual(listViewSubtitle.textColor, .white)
        
        XCTAssertEqual(submitButtonContainer!.backgroundColor, .red)
        XCTAssertEqual(submitButton!.backgroundColor, .brown)
        XCTAssertEqual(submitButtonLabel.textColor, .cyan)
        
        XCTAssertEqual(openAllButtonContainer!.backgroundColor, .black)
        XCTAssertEqual(openAllButton!.backgroundColor, .cyan)
        XCTAssertEqual(openAllButtonLabel.textColor, .brown)
        
        XCTAssertEqual(separator!.backgroundColor, .red)
    }
    
    func testPayButtonTitle() {
        setupRootViewController(sut.viewController)
        sut = PreselectedPaymentMethodComponent(component: component, title: "", style: .init(), listItemStyle: .init())
        
        let submitButtonContainer = sut.viewController.view.findView(with: "AdyenDropIn.PreselectedPaymentMethodComponent.submitButton")
        let submitButton = submitButtonContainer!.findView(by: "button")
        let submitButtonLabel: UILabel! = submitButton!.findView(by: "titleLabel")
        
        wait(for: .milliseconds(300))
        
        XCTAssertEqual(submitButtonLabel.text, "Pay €1.00")
    }

    func testPayButtonTitleNoPayment() {
        setupRootViewController(sut.viewController)
        component = StoredPaymentMethodComponent(paymentMethod: getStoredCard(), context: Dummy.context(with: nil))
        sut = PreselectedPaymentMethodComponent(component: component, title: "", style: .init(), listItemStyle: .init())

        let submitButtonContainer = sut.viewController.view.findView(with: "AdyenDropIn.PreselectedPaymentMethodComponent.submitButton")
        let submitButton = submitButtonContainer!.findView(by: "button")
        let submitButtonLabel: UILabel! = submitButton!.findView(by: "titleLabel")

        wait(for: .milliseconds(300))

        XCTAssertEqual(submitButtonLabel.text, "Pay")
    }
    
    func testPaypalComponent() {
        component = StoredPaymentMethodComponent(paymentMethod: getStoredPaypal(), context: Dummy.context)
        sut = PreselectedPaymentMethodComponent(component: component, title: "", style: FormComponentStyle(), listItemStyle: ListItemStyle())
        
        setupRootViewController(sut.viewController)
        
        let listView: ListItemView? = sut.viewController.view.findView(with: "AdyenDropIn.PreselectedPaymentMethodComponent.defaultComponent")
        let listViewTitle: UILabel! = listView!.findView(by: "titleLabel")
        
        wait(for: .milliseconds(300))
        
        XCTAssertEqual(listViewTitle.text, "PayPal")
    }
    
    func testStoredCardComponent() {
        component = StoredPaymentMethodComponent(paymentMethod: getStoredCard(), context: Dummy.context)
        sut = PreselectedPaymentMethodComponent(component: component, title: "", style: FormComponentStyle(), listItemStyle: ListItemStyle())
        
        setupRootViewController(sut.viewController)
        
        let listView = sut.viewController.view.findView(with: "AdyenDropIn.PreselectedPaymentMethodComponent.defaultComponent")
        let listViewTitle: UILabel! = listView!.findView(by: "titleLabel")
        let listViewSubtitle: UILabel! = listView!.findView(by: "subtitleLabel")
        
        wait(for: .milliseconds(300))
        
        XCTAssertEqual(listViewTitle.text, "•••• 1111")
        XCTAssertEqual(listViewSubtitle.text, "Expires 08/18")
    }
    
    func getStoredCard() -> StoredCardPaymentMethod {
        try! AdyenCoder.decode(storedCreditCardDictionary) as StoredCardPaymentMethod
    }
    
    func getStoredPaypal() -> StoredPayPalPaymentMethod {
        try! AdyenCoder.decode(storedPayPalDictionary) as StoredPayPalPaymentMethod
    }
    
}
