//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation

internal protocol BACSDirectDebitComponentTrackerProtocol: AnyObject {
    func sendInitialAnalytics()
    func sendDidLoadEvent()
}

internal class BACSDirectDebitComponentTracker: BACSDirectDebitComponentTrackerProtocol {

    // MARK: - Properties

    private let paymentMethod: BACSDirectDebitPaymentMethod
    private let context: AdyenContext
    private let isDropIn: Bool

    // MARK: - Initializers

    internal init(
        paymentMethod: BACSDirectDebitPaymentMethod,
        context: AdyenContext,
        isDropIn: Bool
    ) {
        self.paymentMethod = paymentMethod
        self.context = context
        self.isDropIn = isDropIn
    }

    // MARK: - BACSDirectDebitComponentTrackerProtocol

    internal func sendInitialAnalytics() {
        // initial call is not needed again if inside dropIn
        guard !isDropIn else { return }
        let flavor: AnalyticsFlavor = .components(type: paymentMethod.type)
        let amount = context.payment?.amount
        let additionalFields = AdditionalAnalyticsFields(amount: amount, sessionId: AnalyticsForSession.sessionId)
        context.analyticsProvider?.sendInitialAnalytics(
            with: flavor,
            additionalFields: additionalFields
        )
    }
    
    internal func sendDidLoadEvent() {
        let infoEvent = AnalyticsEventInfo(component: paymentMethod.type.rawValue, type: .rendered)
        context.analyticsProvider?.add(info: infoEvent)
    }

}
