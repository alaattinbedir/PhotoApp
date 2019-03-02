//
//  Utilities.swift
//  EventViewer
//
//  Created by Alaattin Bedir on 9.08.2018.
//  Copyright © 2018 Magiclamp Games. All rights reserved.
//

import Foundation
import SystemConfiguration

public final class Utilities {
    
    public class var sharedInstance: Utilities {
        struct Singleton {
            static let instance: Utilities = Utilities()
        }
        return Singleton.instance
    }
    
    private init() {
    }
    
    func isNetworkConnectivityAvailable() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        
        return (isReachable && !needsConnection)
    }
    
}

