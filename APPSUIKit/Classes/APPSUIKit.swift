//
//  APPSUIKit.swift
//  APPSUIKit
//
//  Created by Ken Grigsby on 1/10/17.
//  Copyright © 2017 Appstronomy, LLC. All rights reserved.
//

import Foundation

/**
 Provides some class method conveniences related to dealing with resources and queries
 about this Appstronomy UIKit framework.
 */
open class APPSUIKit: NSObject {
    
    /**
     @return A reference to the bundle for this Appstronomy UIKit framework.
     */
    @objc public static var bundle: Bundle {
        return Bundle(for: self)
    }
}
