//
//  LitSwiftSDK.swift
//  LitProtocolSwiftSDK
//
//  Created by leven on 2023/1/4.
//

import Foundation
import PromiseKit
public class LitClient {
    
    let config: LitNodeClientConfig
    
    let connectedNodes: Set<String> = Set<String>()
    
    let serverKeys: [String: NodeCommandServerKeysResponse] = [:]
    
    var ready: Bool = false
    
    public var isReady: Bool {
        return ready
    }
    
    var subnetPubKey: String?
    
    var networkPubKey: String?
    
    var networkPubKeySet: String?
    
    public init(config: LitNodeClientConfig? = nil) {
        self.config = config ?? LitNodeClientConfig(alertWhenUnauthorized: true, minNodeCount: 6, debug: true, bootstrapUrls: LitNetwork.jalapeno.networks, litNetwork: .jalapeno)
        
    }
    /// Connect to the LIT nodes.
    /// - Returns: A promise that resolves when the nodes are connected.
    public func connect() -> Promise<Void>  {
        // -- handshake with each node
        var urlGenerator = self.config.bootstrapUrls.makeIterator()
        let allPromises = AnyIterator<Promise<NodeCommandServerKeysResponse>> {
            guard let url = urlGenerator.next() else {
                return nil
            }
            return self.handshakeWithNode(url)
        }
        
        return when(fulfilled: allPromises, concurrently: 4).done { [weak self] nodeResponses in
            guard let `self` = self else { return }
            self.subnetPubKey = nodeResponses.map { $0.subnetPublicKey }.mostCommonString
            self.networkPubKey = nodeResponses.map { $0.networkPublicKey }.mostCommonString
            self.networkPubKeySet = nodeResponses.map { $0.networkPublicKeySet }.mostCommonString
            self.ready = true
        }
    }

    func handshakeWithNode(_ url: String) -> Promise<NodeCommandServerKeysResponse> {
        let urlWithPath = "\(url)/web/handshake"
        let parameters = ["clientPublicKey" : "test"]
        return fetch(urlWithPath, parameters: parameters, decodeType: NodeCommandServerKeysResponse.self)
    }


}
