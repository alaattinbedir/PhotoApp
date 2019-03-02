//
//  Session.swift
//  EventViewer
//
//  Created by Alaattin Bedir on 9.08.2018.
//  Copyright © 2018 Magiclamp Games. All rights reserved.
//

class Session {
    
    var Authorization: String? = ""
    
    func getHeaders() -> [String: String] {
        let headers = [
            "Content-Type": "application/json",
            "Authorization" : "Token 5994570dd4865ca5fd5a7b4ecefd5d17180d3d53"
        ]
        
        return headers
    }
    
    init() {
        
    }
    
    public class var sharedInstance: Session {
        struct Singleton {
            static let instance: Session = Session()
        }
        return Singleton.instance
    }
    
}

