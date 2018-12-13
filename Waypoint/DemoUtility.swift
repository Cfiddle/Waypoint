//
//  DemoUtility.swift
//  Waypoint
//
//  Created by Charles Fiedler on 12/11/18.
//  Copyright © 2018 Charles Fiedler. All rights reserved.
//

import DJISDK

public class DemoUtility: NSObject {

    class func fetchFlightController() -> DJIFlightController? {
        guard let baseProduct = DJISDKManager.product() else {
            return nil
        }
        if baseProduct.isKind(of: DJIAircraft.self) {
            let product = baseProduct as? DJIAircraft
            return product!.flightController
        }
        return nil
    }
}
