//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation

/// Validates a card's security code.
public final class CardSecurityCodeValidator: NumericStringValidator, AdyenObserver {
    
    /// Initiate new instance of CardSecurityCodeValidator
    public init() {
        super.init(minimumLength: 3, maximumLength: 4)
    }
    
    /// Initiate new instance of CardSecurityCodeValidator
    /// - Parameter publisher: Observable of a card type
    public init(publisher: AdyenObservable<CardType?>) {
        super.init(minimumLength: 3, maximumLength: 4)
        
        updateExpectedLength(from: publisher.wrappedValue)
        
        observe(publisher) { [weak self] cardType in
            self?.updateExpectedLength(from: cardType)
        }
    }
    
    /// Initiate new instance of CardSecurityCodeValidator with a fixed ``CardType``
    /// - Parameter cardType: The card type to validate the security code for
    public init(cardType: CardType) {
        super.init(minimumLength: 3, maximumLength: 4)
        
        updateExpectedLength(from: cardType)
    }
    
    private func updateExpectedLength(from cardType: CardType?) {
        let length = cardType == .americanExpress ? 4 : 3
        maximumLength = length
        minimumLength = length
    }
    
    override public func isValid(_ value: String) -> Bool {
        validate(value).isValid
    }
    
}

@_spi(AdyenInternal)
extension CardSecurityCodeValidator: StatusValidator {
    
    public func validate(_ value: String) -> ValidationStatus {
        if super.isValid(value) {
            return .valid
        }
        
        if value.isEmpty {
            return .invalid(CardValidationError.securityCodeEmpty)
        }
        
        return .invalid(CardValidationError.securityCodePartial)
    }
}
