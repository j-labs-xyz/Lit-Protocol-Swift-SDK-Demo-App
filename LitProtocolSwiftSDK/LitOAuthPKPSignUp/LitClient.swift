//
//  LitClient.swift
//  LitOAuthPKPSignUp
//
//  Created by leven on 2023/1/4.
//

import Foundation
import LitProtocolSwiftSDK
import Alamofire
public class LitClient {
    
    let relayApi: String
    
    let session: Session
    
    public init(relay: String) {
        self.relayApi = relay
        var hostString = ""
        if let url = URL(string: relay), let host = url.host {
            hostString = host
        }
        let manager = ServerTrustManager(evaluators: [hostString: DisabledTrustEvaluator()])
        let configuration = URLSessionConfiguration.af.default
        configuration.headers = HTTPHeaders(["Content-Type" : "application/json"])
        self.session = Session(configuration: configuration, serverTrustManager: manager)
    }
    
    public func handleLoggedInToGoogle(_ credential: String,
                                              completionHandler: @escaping (_ requestId: String?, _ error: String?) -> Void) {
    
        session.request(relayApi + "auth/google",
                        method: .post,
                        parameters: ["idToken": credential]).response { response in
            if let data = response.data, let dataDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                let code = response.response?.statusCode ?? 400
                if code < 200 || code >= 400 {
                    let error = dataDict["error"] as? String ?? "Something wrong with the API call"
                    completionHandler(nil, error)
                } else if let requestId = dataDict["requestId"] as? String {
                    completionHandler(requestId, nil)
                } else {
                    let error = "Empty requestId"
                    completionHandler(nil,error)
                }
            }
        }
    }
    
    public func pollRequestUntilTerminalState(with requestId: String,
                                              completionHandler: @escaping (_ result: [String: Any]?, _ error: String?) -> Void) {
        
        session.request(relayApi + "auth/status/" + requestId).response { response in
            if let data = response.data, let dataDict = try? JSONSerialization.jsonObject(with: data) {
                print(dataDict)
            }
        }
    }
}
