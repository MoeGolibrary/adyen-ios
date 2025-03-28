//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import SwiftUI

@available(iOS 13.0.0, *)
internal struct ConfigurationView: View {
    
    private enum ConfigurationSection: String, CaseIterable {
        case apiVersion = "Api Version"
        case merchantAccount = "Merchant Account"
        case region = "Region"
        case payment = "Payment"
        case components = "Components"
        case dropIn = "DropIn"
    }
    
    @ObservedObject internal var viewModel: ConfigurationViewModel
    @State private var countrySearchSting: String = ""
    private var filteredCountries: [CountryDisplayInfo] {
        if countrySearchSting.isEmpty {
            return ConfigurationViewModel.countries
        } else {
            return ConfigurationViewModel.countries.filter { $0.matches(countrySearchSting) }
        }
    }
    
    @State private var currencySearchString: String = ""
    private var filteredCurrencies: [CurrencyDisplayInfo] {
        if currencySearchString.isEmpty {
            return ConfigurationViewModel.currencies
        } else {
            return ConfigurationViewModel.currencies.filter { $0.matches(currencySearchString) }
        }
    }
    
    internal init(viewModel: ConfigurationViewModel) {
        self.viewModel = viewModel
    }
    
    internal var body: some View {
        NavigationView {
            Form {
                apiVersionSection
                merchantAccountSection
                regionSection
                wrapInSection(view: paymentSection, section: .payment)
                wrapInSection(view: dropInSection, section: .dropIn)
                wrapInSection(view: componentsSection, section: .components)
            }.navigationBarTitle("Configuration", displayMode: .inline)
                .navigationBarItems(
                    leading: Button("Default", action: viewModel.defaultTapped),
                    trailing: Button("Save", action: viewModel.doneTapped)
                )
        }
        .navigationViewStyle(.stack)
        .onAppear {
            countrySearchSting = ""
            currencySearchString = ""
        }
    }
    
    private func wrapInSection(
        view: some View,
        section: ConfigurationSection
    ) -> some View {
        Section(header: Text(section.rawValue.uppercased())) { view }
    }
    
    private var apiVersionSection: some View {
        TextFieldItemView(
            title: "API Version",
            value: $viewModel.apiVersion,
            placeholder: ConfigurationSection.apiVersion.rawValue,
            keyboardType: .numberPad
        )
    }
    
    private var merchantAccountSection: some View {
        TextFieldItemView(
            title: "Merchant Account",
            value: $viewModel.merchantAccount,
            placeholder: ConfigurationSection.merchantAccount.rawValue,
            keyboardType: .default
        )
    }
    
    private var regionSection: some View {
        let selectionBinding = Binding(
            get: { viewModel.countryCode },
            set: { newValue in
                viewModel.countryCode = newValue
                countrySearchSting = ""
            }
        )
        
        return pickerWithSearchBar(
            with: selectionBinding,
            title: "Country code",
            searchString: $countrySearchSting,
            rows: filteredCountries,
            transform: { ListItemView(viewModel: $0.toListItemViewModel) }
        )
    }
    
    private var paymentSection: some View {
        let selectionBinding = Binding(
            get: { viewModel.currencyCode },
            set: { newValue in
                viewModel.currencyCode = newValue
                currencySearchString = ""
            }
        )
        
        return Group {
            Button("Set to country currency", action: setToCountryCurrency)
            pickerWithSearchBar(
                with: selectionBinding,
                title: "Currency code",
                searchString: $currencySearchString,
                rows: filteredCurrencies,
                transform: { ListItemView(viewModel: $0.toListItemViewModel) }
            )
            TextFieldItemView(
                title: "Amount ",
                value: $viewModel.value,
                placeholder: "Amount",
                keyboardType: .numberPad
            )
        }

    }

    private var dropInSection: some View {
        NavigationLink(destination: DropInSettingsView(viewModel: viewModel)) {
            HStack {
                Text("DropIn")
            }
        }
    }

    private var componentsSection: some View {
        Group {
            cardComponentSection
            applePaySection
            analyticsSection
        }
    }

    internal var cardComponentSection: some View {
        NavigationLink(destination: CardSettingsView(viewModel: viewModel)) {
            HStack {
                Text("Card Component")
            }
        }
    }

    private var applePaySection: some View {
        NavigationLink(destination: ApplePaySettingsView(viewModel: viewModel)) {
            HStack {
                Text("Apple Pay")
            }
        }
    }

    private var analyticsSection: some View {
        NavigationLink(destination: AnalyticsSettingsView(viewModel: viewModel)) {
            HStack {
                Text("Analytics")
            }
        }
    }

    private func pickerWithSearchBar<T: Hashable>(
        with selectionBinding: Binding<String>,
        title: String,
        searchString: Binding<String>,
        rows: [T],
        transform: @escaping (T) -> ListItemView<some Hashable>
    ) -> some View {
        Picker(title, selection: selectionBinding) {
            SearchBar(searchString: searchString, placeholder: "Search...")
            ForEach(rows, id: \.self, content: transform)
        }.navigationLinkStyle()
    }
    
    private func setToCountryCurrency() {
        let locale = Locale(
            identifier: NSLocale.localeIdentifier(
                fromComponents: [NSLocale.Key.countryCode.rawValue: viewModel.countryCode]
            )
        )
        guard let currencyCode = locale.currencyCode else { return }
        
        viewModel.currencyCode = currencyCode
    }
    
}

@available(iOS 13.0.0, *)
internal struct TextFieldItemView: View {

    internal let title: String
    internal let placeholder: String
    internal let keyboardType: UIKeyboardType
    internal let value: Binding<String>

    internal init(title: String, value: Binding<String>, placeholder: String, keyboardType: UIKeyboardType) {
        self.title = title
        self.placeholder = placeholder
        self.keyboardType = keyboardType
        self.value = value
    }

    internal var body: some View {
        HStack {
            Text(title)
            TextField(placeholder, text: value)
                .keyboardType(keyboardType)
                .multilineTextAlignment(.trailing)
                .padding(.trailing, 10)
        }
    }
}

@available(iOS 13.0.0, *)
private struct ListItemView<T: Hashable>: View {
    let viewModel: ViewModel<T>
    
    var body: some View {
        HStack {
            Text(viewModel.title).foregroundColor(Color(UIColor.label))
            Text(viewModel.subtitle).foregroundColor(Color(UIColor.secondaryLabel))
        }.tag(viewModel.tag)
    }
    
    fileprivate struct ViewModel<Tag: Hashable> {
        let title: String
        let subtitle: String
        let tag: Tag
    }
}

@available(iOS 13.0.0, *)
extension CountryDisplayInfo {
    fileprivate var toListItemViewModel: ListItemView<String>.ViewModel<String> {
        ListItemView.ViewModel(
            title: "\(code) \(emojiFlag(regionCode: code))",
            subtitle: name,
            tag: code
        )
    }
    
    internal func matches(_ predicate: String) -> Bool {
        code.range(of: predicate, options: [.anchored, .caseInsensitive]) != nil ||
            name.range(of: predicate, options: [.anchored, .caseInsensitive]) != nil
    }
    
    private func emojiFlag(regionCode: String) -> String {
        regionCode.unicodeScalars
            .compactMap { UnicodeScalar(127397 + $0.value) }
            .map(String.init)
            .joined()
    }
}

@available(iOS 13.0.0, *)
extension CurrencyDisplayInfo {
    fileprivate var toListItemViewModel: ListItemView<String>.ViewModel<String> {
        ListItemView.ViewModel(title: code, subtitle: symbol, tag: code)
    }
    
    internal func matches(_ predicate: String) -> Bool {
        code.range(of: predicate, options: [.anchored, .caseInsensitive]) != nil ||
            symbol.range(of: predicate, options: [.anchored, .caseInsensitive]) != nil
    }
}

@available(iOS 13.0.0, *)
extension Picker {
    @ViewBuilder
    fileprivate func navigationLinkStyle() -> some View {
        if #available(iOS 16.0.0, *) {
            self.pickerStyle(NavigationLinkPickerStyle())
        } else {
            self
        }
    }
}
