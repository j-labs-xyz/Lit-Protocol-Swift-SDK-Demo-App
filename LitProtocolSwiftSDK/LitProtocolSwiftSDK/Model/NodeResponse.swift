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
