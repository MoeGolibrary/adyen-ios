//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

extension AdyenDependencyValues {
    internal var openAppDetector: OpenExternalAppDetecting {
        get { self[OpenExternalAppDetectorKey.self] }
        set { self[OpenExternalAppDetectorKey.self] = newValue }
    }
}

internal enum OpenExternalAppDetectorKey: AdyenDependencyKey {
    internal static let liveValue: OpenExternalAppDetecting = OpenExternalAppDetector()
}
