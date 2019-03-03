//
//  MySessionManager.swift
//  PhotoApp
//
//  Created by Alaattin Bedir on 2.03.2019.
//  Copyright © 2019 Alaattin Bedir. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import ObjectMapper

class MyError: Error {
    
    var errorCode: String?
    var errorMessage: String?
    
    init() {
        self.errorCode
        self.errorMessage
    }
    
    init(errorCode: String?, errorMessage: String?) {
        self.errorCode = errorCode
        self.errorMessage = errorMessage
    }
}

class MySessionManager: NSObject {
    
    static let sharedInstance = MySessionManager()
    private var sessionManager: SessionManager
    let baseURL = "https://www.photogalary.com/"
    
    private override init() {
        // Create custom manager
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 280
        var headers = Alamofire.SessionManager.defaultHTTPHeaders
        headers["Authorization"] = "Token 5994570dd4865ca5fd5a7b4ecefd5d17180d3d53"
        configuration.httpAdditionalHeaders = headers
        let manager = Alamofire.SessionManager(
            configuration: URLSessionConfiguration.default,
            serverTrustPolicyManager: CustomServerTrustPoliceManager()
        )
        
        self.sessionManager = manager
    }
    
    func isValidResponse(json: JSON) -> (Bool, String)  {
        var response = (result: false, errorCode: "")
        
        if !json.isEmpty  {
            response.result = true
            response.errorCode = ""
        } else {
            response.result = false
            response.errorCode = "BAD_RESPONSE"
        }
        
        return response
    }
    
    func formatedErrorMessage(errorCode: String) -> MyError {
        var error: MyError
        
        switch errorCode {
        case "MAP_ERROR":
            error = MyError.init(errorCode: errorCode, errorMessage: NSLocalizedString("Error mapping response", comment: "comment"))
        case "BAD_RESPONSE":
            error = MyError.init(errorCode: errorCode, errorMessage: NSLocalizedString("Error bad response", comment: "comment"))
        default:
            error = MyError.init(errorCode: errorCode, errorMessage: NSLocalizedString("An unknown error has occurred", comment: "comment"))
        }
        
        return error
    }
    
    func requestGETURL(_ strURL: String, success:@escaping (JSON) -> Void, failure:@escaping (MyError) -> Void) {
        guard Utilities.sharedInstance.isNetworkConnectivityAvailable() else {
            let bookmarError = MyError.init(errorCode: "NO_CONNECTION_ERROR", errorMessage: NSLocalizedString("No Internet connection", comment: "comment"))
            failure(bookmarError)
            return
        }
        
        self.sessionManager.request(baseURL + strURL, headers: Session.sharedInstance.getHeaders()).responseJSON { (responseObject) -> Void in
            
            if responseObject.result.isSuccess {
                if let value = responseObject.result.value {
                    let json = JSON(value)
                    let (result, errorCode) = self.isValidResponse(json: json)
                    if result {
                        success(json)
                    } else {
                        let error = self.formatedErrorMessage(errorCode: errorCode)
                        failure(error)
                    }
                }
            }
            
            if responseObject.result.isFailure {
                if let error = responseObject.result.error {
                    let bookmarError = MyError.init(errorCode: "NETWORK_ERROR", errorMessage: error.localizedDescription)
                    failure(bookmarError)
                }
            }
        }
    }
    
    func requestPOSTURL(_ strURL: String, params: [String: AnyObject]?, headers: [String: String]?, success:@escaping (JSON) -> Void, failure: @escaping (MyError) -> Void) {
        
        guard Utilities.sharedInstance.isNetworkConnectivityAvailable() else {
            let bookmarError = MyError.init(errorCode: "NO_CONNECTION_ERROR", errorMessage: NSLocalizedString("No Internet connection", comment: "comment"))
            failure(bookmarError)
            return
        }
        
        self.sessionManager.request(baseURL + strURL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: Session.sharedInstance.getHeaders()).responseJSON { (responseObject) -> Void in
            if responseObject.result.isSuccess {
                if let value = responseObject.result.value {
                    let json = JSON(value)
                    let (result, errorCode) = self.isValidResponse(json: json)
                    if result {
                        success(json)
                    } else {
                        let error = self.formatedErrorMessage(errorCode: errorCode)
                        failure(error)
                    }
                }
            }
            
            if responseObject.result.isFailure {
                if let error = responseObject.result.error {
                    let bookmarError = MyError.init(errorCode: "NETWORK_ERROR", errorMessage: error.localizedDescription)
                    failure(bookmarError)
                }
            }
        }
    }
}

class CustomServerTrustPoliceManager: ServerTrustPolicyManager {
    override func serverTrustPolicy(forHost host: String) -> ServerTrustPolicy? {
        return .disableEvaluation
    }
    public init() {
        super.init(policies: [:])
    }
}



