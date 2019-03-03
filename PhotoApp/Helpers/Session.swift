//
//  Session.swift
//  PhotoApp
//
//  Created by Alaattin Bedir on 2.03.2019.
//  Copyright © 2019 Alaattin Bedir. All rights reserved.
//

class Session {
    
    var Authorization: String?
    
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

