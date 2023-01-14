//
//  SessionSigs.swift
//  LitProtocolSwiftSDK
//
//  Created by leven on 2023/1/13.
//

import Foundation
import PromiseKit

typealias AuthNeededCallback = (_ chain: Chain, _ resources: [String]?, _ switchChain: String, _ expiration: String, _ url: String) -> Promise<JsonAuthSig>

struct GetSessionSigsProps {
    let expiration: String?
    let chain: Chain
    let resource: [String]
    let sessionCapabilities: [String]
    let switchChain: String
    let authNeededCallback: AuthNeededCallback?
    let sessionKey: String
}

struct CheckAndSignAuthParams {
    var expiration: String?
    let chain: Chain
    let resource: [String]
    let sessionCapabilities: [String]?
    let switchChain: Any?
}

struct SessionKeyPair {
    let publicKey: String
    let secretKey: String
}

struct AuthMethod {
    let authMethodType: Int
    let accessToken: String
}

struct JsonAuthSig {
    let sig: String
    let derivedVia: String
    let signedMessage: String
    let address: String
    let capabilities: [Any]?
    let algo: [Any]?
}

let LIT_SESSION_KEY_URI = "lit:session:"

