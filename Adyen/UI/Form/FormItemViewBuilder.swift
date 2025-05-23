//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Builds different types of `FormItemView's`  from the corresponding concrete `FormItem`.
@_spi(AdyenInternal)
public struct FormItemViewBuilder {
    
    /// Builds `FormToggleItemView` from `FormToggleItem`.
    @_spi(AdyenInternal)
    public func build(with item: FormToggleItem) -> FormItemView<FormToggleItem> {
        FormToggleItemView(item: item)
    }
    
    /// Builds `FormSplitItemView` from `FormSplitItem`.
    @_spi(AdyenInternal)
    public func build(with item: FormSplitItem) -> FormItemView<FormSplitItem> {
        FormSplitItemView(item: item)
    }
    
    /// Builds `PhoneNumberItemView` from `PhoneNumberItem`.
    @_spi(AdyenInternal)
    public func build(with item: FormPhoneNumberItem) -> FormItemView<FormPhoneNumberItem> {
        FormPhoneNumberItemView(item: item)
    }

    /// Builds `FormIssuerPickerItemView` from `FormIssuerPickerItem`.
    @_spi(AdyenInternal)
    public func build<Value: CustomStringConvertible>(with item: BaseFormPickerItem<Value>) -> BaseFormPickerItemView<Value> {
        BaseFormPickerItemView(item: item)
    }

    /// Builds `FormTextInputItemView` from `FormTextInputItem`.
    @_spi(AdyenInternal)
    public func build(with item: FormTextInputItem) -> FormItemView<FormTextInputItem> {
        FormTextInputItemView(item: item)
    }
    
    /// Builds `ListItemView` from `ListItem`.
    @_spi(AdyenInternal)
    public func build(with item: ListItem) -> ListItemView {
        let listView = ListItemView()
        listView.item = item
        return listView
    }

    /// Builds `SelectableFormItemView` from `SelectableFormItem`.
    @_spi(AdyenInternal)
    public func build(with item: SelectableFormItem) -> FormItemView<SelectableFormItem> {
        SelectableFormItemView(item: item)
    }

    /// Builds `FormButtonItemView` from `FormButtonItem`.
    @_spi(AdyenInternal)
    public func build(with item: FormButtonItem) -> FormItemView<FormButtonItem> {
        FormButtonItemView(item: item)
    }
    
    /// Builds `FormImageView` from `FormImageItem`.
    @_spi(AdyenInternal)
    public func build(with item: FormImageItem) -> FormItemView<FormImageItem> {
        FormImageView(item: item)
    }

    /// Builds `FormSeparatorItemView` from `FormSeparatorItem`.
    @_spi(AdyenInternal)
    public func build(with item: FormSeparatorItem) -> FormItemView<FormSeparatorItem> {
        FormSeparatorItemView(item: item)
    }

    /// Builds `FormErrorItemView` from `FormErrorItem`.
    @_spi(AdyenInternal)
    public func build(with item: FormErrorItem) -> FormItemView<FormErrorItem> {
        FormErrorItemView(item: item)
    }
    
    /// Builds `FormVerticalStackItemView` from `FormAddressItem`.
    @_spi(AdyenInternal)
    public func build(with item: FormAddressItem) -> FormItemView<FormAddressItem> {
        FormVerticalStackItemView(item: item)
    }

    /// Builds `FormSpacerItemView` from `FormSpacerItem`.
    @_spi(AdyenInternal)
    public func build(with item: FormSpacerItem) -> FormItemView<FormSpacerItem> {
        FormSpacerItemView(item: item)
    }
    
    /// Builds `FormTextItemView` from `FormPostalCodeItem`.
    @_spi(AdyenInternal)
    public func build(with item: FormPostalCodeItem) -> FormItemView<FormPostalCodeItem> {
        FormTextItemView(item: item)
    }
    
    /// Builds `FormSearchButtonItemView` from `FormSearchButtonItem`.
    @_spi(AdyenInternal)
    public func build(with item: FormSearchButtonItem) -> FormItemView<FormSearchButtonItem> {
        FormSearchButtonItemView(item: item)
    }
    
    /// Builds `FormAddressPickerItemView` from `FormAddressPickerItem`.
    @_spi(AdyenInternal)
    public func build(with item: FormAddressPickerItem) -> FormItemView<FormAddressPickerItem> {
        FormAddressPickerItemView(item: item)
    }
    
    /// Builds `FormPickerItemView` from `FormPickerItem`.
    @_spi(AdyenInternal)
    public func build<Value>(with item: FormPickerItem<Value>) -> FormItemView<FormPickerItem<Value>> {
        FormPickerItemView(item: item)
    }
    
    /// Builds `FormPhoneExtensionPickerItemView` from `FormPhoneExtensionPickerItem`.
    @_spi(AdyenInternal)
    public func build(with item: FormPhoneExtensionPickerItem) -> FormPhoneExtensionPickerItemView {
        FormPhoneExtensionPickerItemView(item: item)
    }

    @_spi(AdyenInternal)
    public static func build(_ item: FormItem) -> AnyFormItemView {
        let itemView = item.build(with: FormItemViewBuilder())
        itemView.accessibilityIdentifier = item.identifier
        return itemView
    }
}
