//
//  LitNodeResponse.swift
//  LitProtocolSwiftSDK
//
//  Created by leven on 2023/1/13.
//

import Foundation

struct NodeCommandServerKeysResponse: Codable {
    let serverPublicKey: String
    let subnetPublicKey: String
    let networkPublicKey: String
    let networkPublicKeySet: String
}

struct NodeShareResponse: Codable {
    var signedData: NodeShareData?
    var success: Bool = false
    
}
struct NodeShareData: Codable {
    var sessionSig: NodeShare?
}

struct NodeShare: Codable {
    var dataSigned: String
    var localX: String
    var localY: String
    var publicKey: String
    var shareIndex: Int
    var sigName: String
    var sigType: String
    var signatureShare: String
    var siweMessage: String
}
