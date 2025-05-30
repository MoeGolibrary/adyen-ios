//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

@_spi(AdyenInternal) @testable import Adyen
import XCTest

class AddressInputFormViewControllerTests: XCTestCase {
    
    override func run() {
        AdyenDependencyValues.runTestWithValues {
            $0.imageLoader = ImageLoaderMock()
        } perform: {
            super.run()
        }
    }
    
    func testAddressNL() throws {
        // Given
        let viewController = AddressInputFormViewController(
            viewModel: self.viewModel(
                initialCountry: "NL",
                prefillAddress: nil,
                searchHandler: nil
            )
        )
        
        setupRootViewController(viewController)

        let view: UIView = viewController.view

        let houseNumberItemView: FormTextInputItemView = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.address.houseNumberOrName"))
        let countryItemView: FormPickerItemView<FormPickerElement> = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.address.country"))
        let addressItemView: FormTextInputItemView = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.address.street"))
        let apartmentSuiteItemView: FormTextInputItemView = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.address.apartment"))
        let cityItemView: FormTextInputItemView = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.address.city"))
        let provinceOrTerritoryItemView: FormTextInputItemView = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.address.stateOrProvince"))
        let postalCodeItemView: FormTextInputItemView = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.address.postalCode"))

        XCTAssertNil(view.findView(by: "AddressInputFormViewController.addressItem.title"))
        
        XCTAssertEqual(countryItemView.titleLabel.text, "Country/Region")
        XCTAssertEqual(countryItemView.item.value!.title, "Netherlands")
        XCTAssertEqual(houseNumberItemView.titleLabel.text, "House number")
        XCTAssertEqual(addressItemView.titleLabel.text, "Street")
        XCTAssertEqual(apartmentSuiteItemView.titleLabel.text, "Apartment / Suite (optional)")
        XCTAssertEqual(cityItemView.titleLabel.text, "City")
        XCTAssertEqual(provinceOrTerritoryItemView.titleLabel.text, "Province or Territory")
        XCTAssertEqual(postalCodeItemView.titleLabel.text, "Postal code")

        XCTAssertTrue(houseNumberItemView.alertLabel.isHidden)
        XCTAssertTrue(addressItemView.alertLabel.isHidden)
        XCTAssertTrue(apartmentSuiteItemView.alertLabel.isHidden)
        XCTAssertTrue(cityItemView.alertLabel.isHidden)
        XCTAssertTrue(provinceOrTerritoryItemView.alertLabel.isHidden)
        XCTAssertTrue(postalCodeItemView.alertLabel.isHidden)
        
        let doneButton = try XCTUnwrap(viewController.navigationItem.rightBarButtonItem)
        try doneButton.tap()
        
        wait { !houseNumberItemView.alertLabel.isHidden }
        XCTAssertFalse(addressItemView.alertLabel.isHidden)
        XCTAssertTrue(apartmentSuiteItemView.alertLabel.isHidden)
        XCTAssertFalse(cityItemView.alertLabel.isHidden)
        XCTAssertFalse(provinceOrTerritoryItemView.alertLabel.isHidden)
        XCTAssertFalse(postalCodeItemView.alertLabel.isHidden)
    }
    
    func testAddressUS() throws {
        
        // Given
        let viewController = AddressInputFormViewController(
            viewModel: self.viewModel(
                initialCountry: "US",
                prefillAddress: nil,
                searchHandler: nil
            )
        )
        
        setupRootViewController(viewController)
        
        // When
        let view: UIView = viewController.view

        let houseNumberItemView: FormTextInputItemView = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.address.houseNumberOrName"))
        let countryItemView: FormPickerItemView<FormPickerElement> = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.address.country"))
        let addressItemView: FormTextInputItemView = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.address.street"))
        let apartmentSuiteItemView = view.findView(with: "AddressInputFormViewController.address.apartment") as? FormTextInputItemView
        let cityItemView: FormTextInputItemView = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.address.city"))
        let provinceOrTerritoryItemView: FormPickerItemView<FormPickerElement> = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.address.stateOrProvince"))
        let postalCodeItemView: FormTextInputItemView = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.address.postalCode"))
        let searchItemView = view.findView(with: "AddressInputFormViewController.searchBar") as? FormSearchButtonItemView

        // Then
        XCTAssertNil(searchItemView)
        XCTAssertNil(apartmentSuiteItemView)

        XCTAssertEqual(countryItemView.titleLabel.text, "Country/Region")
        XCTAssertEqual(countryItemView.item.value!.title, "United States")
        XCTAssertEqual(houseNumberItemView.titleLabel.text, "Apartment / Suite (optional)")
        XCTAssertEqual(addressItemView.titleLabel.text, "Address")
        XCTAssertEqual(cityItemView.titleLabel.text, "City")
        XCTAssertEqual(provinceOrTerritoryItemView.titleLabel.text, "State")
        XCTAssertEqual(postalCodeItemView.titleLabel.text, "Zip code")

        XCTAssertTrue(houseNumberItemView.alertLabel.isHidden)
        XCTAssertTrue(addressItemView.alertLabel.isHidden)
        XCTAssertTrue(cityItemView.alertLabel.isHidden)
        XCTAssertTrue(postalCodeItemView.alertLabel.isHidden)

        let doneButton = try XCTUnwrap(viewController.navigationItem.rightBarButtonItem)
        try doneButton.tap()
        
        wait(until: houseNumberItemView.alertLabel, at: \.isHidden, is: true)
        wait(until: addressItemView.alertLabel, at: \.isHidden, is: false)
        wait(until: cityItemView.alertLabel, at: \.isHidden, is: false)
        wait(until: postalCodeItemView.alertLabel, at: \.isHidden, is: false)
    }

    func testAddressUK() throws {
        
        // Given
        let viewController = AddressInputFormViewController(
            viewModel: self.viewModel(
                initialCountry: "GB",
                prefillAddress: nil,
                searchHandler: nil
            )
        )
        
        setupRootViewController(UINavigationController(rootViewController: viewController))
        
        let view: UIView = viewController.view

        let houseNumberItemView: FormTextInputItemView = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.address.houseNumberOrName"))
        let countryItemView: FormPickerItemView<FormPickerElement> = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.address.country"))
        let addressItemView: FormTextInputItemView = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.address.street"))
        let apartmentSuiteItemView = view.findView(with: "AddressInputFormViewController.address.apartment") as? FormTextInputItemView
        let cityItemView: FormTextInputItemView = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.address.city"))
        let provinceOrTerritoryItemView = view.findView(with: "AddressInputFormViewController.address.stateOrProvince") as? FormPickerItemView<FormPickerElement>
        let postalCodeItemView: FormTextInputItemView = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.address.postalCode"))

        XCTAssertNil(apartmentSuiteItemView)
        XCTAssertEqual(countryItemView.titleLabel.text, "Country/Region")
        XCTAssertEqual(countryItemView.item.value!.title, "United Kingdom")
        XCTAssertEqual(houseNumberItemView.titleLabel.text, "House number")
        XCTAssertEqual(addressItemView.titleLabel.text, "Street")
        XCTAssertEqual(cityItemView.titleLabel.text, "City / Town")
        XCTAssertNil(provinceOrTerritoryItemView)
        XCTAssertEqual(postalCodeItemView.titleLabel.text, "Postal code")
    }

    func testAddressSelectCountry() throws {

        // Given
        let viewController = AddressInputFormViewController(
            viewModel: self.viewModel(
                initialCountry: "CA",
                prefillAddress: nil,
                searchHandler: nil
            )
        )
        
        setupRootViewController(UINavigationController(rootViewController: viewController))

        let view: UIView = viewController.view

        var houseNumberItemView: FormTextInputItemView = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.address.houseNumberOrName"))
        var countryItemView: FormPickerItemView<FormPickerElement> = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.address.country"))
        var addressItemView: FormTextInputItemView = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.address.street"))
        var apartmentSuiteItemView: FormTextInputItemView! = view.findView(with: "AddressInputFormViewController.address.apartment")
        var cityItemView: FormTextInputItemView = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.address.city"))
        var provinceOrTerritoryItemView: FormPickerItemView<FormPickerElement> = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.address.stateOrProvince"))
        var postalCodeItemView: FormTextInputItemView = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.address.postalCode"))

        XCTAssertNil(apartmentSuiteItemView)

        XCTAssertEqual(countryItemView.titleLabel.text, "Country/Region")
        XCTAssertEqual(countryItemView.item.value!.title, "Canada")
        XCTAssertEqual(houseNumberItemView.titleLabel.text, "Apartment / Suite (optional)")
        XCTAssertEqual(addressItemView.titleLabel.text, "Address")
        XCTAssertEqual(cityItemView.titleLabel.text, "City")
        XCTAssertEqual(provinceOrTerritoryItemView.titleLabel.text, "Province or Territory")
        XCTAssertEqual(postalCodeItemView.titleLabel.text, "Postal code")
        XCTAssertNil(apartmentSuiteItemView)

        countryItemView.item.value = countryItemView.item.selectableValues.first { $0.identifier == "BR" }!

        houseNumberItemView = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.address.houseNumberOrName"))
        countryItemView = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.address.country"))
        addressItemView = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.address.street"))
        apartmentSuiteItemView = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.address.apartment"))
        cityItemView = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.address.city"))
        provinceOrTerritoryItemView = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.address.stateOrProvince"))
        postalCodeItemView = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.address.postalCode"))

        XCTAssertEqual(countryItemView.titleLabel.text, "Country/Region")
        XCTAssertEqual(countryItemView.item.value!.title, "Brazil")
        XCTAssertEqual(houseNumberItemView.titleLabel.text, "House number")
        XCTAssertEqual(addressItemView.titleLabel.text, "Street")
        XCTAssertEqual(cityItemView.titleLabel.text, "City")
        XCTAssertEqual(provinceOrTerritoryItemView.titleLabel.text, "State")
        XCTAssertEqual(postalCodeItemView.titleLabel.text, "Postal code")
        XCTAssertEqual(apartmentSuiteItemView.titleLabel.text, "Apartment / Suite (optional)")
    }
    
    func testSearchBarVisibility() throws {
        // Given
        
        let searchExpectation = expectation(description: "Search handler triggered")
        let viewController = AddressInputFormViewController(
            viewModel: self.viewModel(
                initialCountry: "CA",
                searchHandler: { currentInput in
                    XCTAssertEqual(currentInput, .init(country: "CA"))
                    searchExpectation.fulfill()
                }
            )
        )
        
        setupRootViewController(UINavigationController(rootViewController: viewController))
        
        let view: UIView = viewController.view
        let searchItemView: FormSearchButtonItemView = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.searchBar"))
        
        _ = searchItemView.becomeFirstResponder()
        
        wait(for: [searchExpectation], timeout: 10)
    }
    
    func testDoneButtonStateNoPrefill() {
        
        let viewController = AddressInputFormViewController(
            viewModel: self.viewModel(
                initialCountry: "NL"
            )
        )
        
        setupRootViewController(UINavigationController(rootViewController: viewController))
        
        XCTAssertEqual(
            viewController.navigationItem.rightBarButtonItem?.isEnabled,
            false
        )
    }
    
    func testDoneButtonStatePrefillCountryAddingStreet() throws {
        
        let viewController = AddressInputFormViewController(
            viewModel: self.viewModel(
                initialCountry: "NL",
                prefillAddress: .init(country: "US")
            )
        )

        setupRootViewController(UINavigationController(rootViewController: viewController))
        
        XCTAssertEqual(
            viewController.navigationItem.rightBarButtonItem?.isEnabled,
            false
        )
        
        // Adding street name value
        
        let countryItemView: FormPickerItemView<FormPickerElement> = try XCTUnwrap(viewController.view.findView(with: "AddressInputFormViewController.address.country"))
        countryItemView.item.value = .init(identifier: "DE", title: "DE", subtitle: nil)
        
        XCTAssertEqual(
            viewController.navigationItem.rightBarButtonItem?.isEnabled,
            true
        )
    }
    
    func testDoneButtonStatePrefillCountryAndStreet() {
        
        let viewController = AddressInputFormViewController(
            viewModel: self.viewModel(
                initialCountry: "NL",
                prefillAddress: .init(country: "NL", street: "Singel")
            )
        )
        
        setupRootViewController(UINavigationController(rootViewController: viewController))
        
        XCTAssertEqual(
            viewController.navigationItem.rightBarButtonItem?.isEnabled,
            true
        )
    }
    
    func testClearShouldAssignEmptyStreet() throws {
        // Given
        let viewController = AddressInputFormViewController(
            viewModel: self.viewModel(
                initialCountry: "NL",
                prefillAddress: .init(country: "NL", street: "Singel")
            )
        )
        
        setupRootViewController(viewController)
        setupRootViewController(UIViewController())

        XCTAssertEqual(
            viewController.addressItem.value.street,
            ""
        )
    }
    
    func test_itemSetup() throws {
        
        let viewController = AddressInputFormViewController(
            viewModel: self.viewModel()
        )
        
        let pickerSearchViewController = try presentCountryPicker(for: viewController)
        let firstListItem = try firstListItem(from: pickerSearchViewController)
        XCTAssertNil(firstListItem.icon)
        XCTAssertEqual(firstListItem.title, "Afghanistan")
        XCTAssertEqual(firstListItem.subtitle, "AF")
    }
}

private extension AddressInputFormViewControllerTests {
    
    func presentCountryPicker(
        for viewController: AddressInputFormViewController
    ) throws -> FormPickerSearchViewController<FormPickerElement> {
        setupRootViewController(viewController)
        let view: UIView = viewController.view
        let countryItemView: FormPickerItemView<FormPickerElement> = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.address.country"))
        countryItemView.item.selectionHandler()
        return try waitUntilTopPresenter(isOfType: FormPickerSearchViewController.self)
    }
    
    func firstListItem(from pickerSearchViewController: FormPickerSearchViewController<FormPickerElement>) throws -> ListItem {
        let searchViewController = try XCTUnwrap(pickerSearchViewController.viewControllers.first as? SearchViewController)
        let resultsList = searchViewController.resultsListViewController
        wait { resultsList.viewIfLoaded?.window != nil }
        let firstCell = try XCTUnwrap(resultsList.tableView.visibleCells.first as? ListCell)
        return try XCTUnwrap(firstCell.item)
    }
    
    func viewModel(
        initialCountry: String = "NL",
        prefillAddress: PostalAddress? = nil,
        style: FormComponentStyle = .init(),
        searchHandler: AddressInputFormViewController.ShowSearchHandler? = nil
    ) -> AddressInputFormViewController.ViewModel {
        
        .init(
            for: .billing,
            style: style,
            localizationParameters: nil,
            initialCountry: initialCountry,
            prefillAddress: prefillAddress,
            supportedCountryCodes: nil,
            handleShowSearch: searchHandler,
            completionHandler: { _ in }
        )
    }
}
