//
//  LitSwiftSDK.swift
//  LitProtocolSwiftSDK
//
//  Created by leven on 2023/1/4.
//

import Foundation
import PromiseKit
import TweetNacl
import web3
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
    
    func getSessionSigs(_ params: GetSessionSigsProps) throws  {
        var params = params
        let sessionKey = try getSessionKey(params.sessionKey)
        
        let sessionKeyUrl = getSessionKeyUri(sessionKey.publicKey)
        
        let capabilities = getSessionCapabilities(params.sessionCapabilities, resources: params.resource)
        
        let expiration = params.expiration ?? getExpiration(1000 * 60 * 60 * 24)
        
        getWalletSig(params).done { [weak self] authSig in
            guard let `self` = self else { return }
            let siweMessage = try SiweMessage(authSig.signedMessage)
            
            
            
        }
    }
    
    
    func getSessionKey(_ supposedSessionKey: String?) throws -> SessionKeyPair {
        let sessionKey = supposedSessionKey ?? ""
        let keyPair = try NaclBox.keyPair()
        if let publicKey = keyPair.publicKey.uint8ToString("base16"), let secretKey = keyPair.secretKey.uint8ToString("base16") {
            return SessionKeyPair(publicKey: publicKey, secretKey: secretKey)
        }
        throw LitError.INIT_KEYPAIR_ERROR
    }
    
    
    
    
    func getWalletSig(_ signProps: GetSessionSigsProps) -> Promise<JsonAuthSig> {
        if let authNeededCallback = signProps.authNeededCallback {
            return authNeededCallback(signProps.chain, signProps.resource, signProps.switchChain, signProps.expiration ?? "", signProps.sessionKey)
        } else {
            return checkAndSignAuthMessage(CheckAndSignAuthParams(chain: signProps.chain, resource: signProps.resource, sessionCapabilities: signProps.sessionCapabilities, switchChain: signProps.switchChain))
        }
    }
    
    func checkNeedToResignSessionKey(siweMessage: SiweMessage, walletSignature: String, sessionKeyUri: String, resources: [String], sessionCapabilities: [String]) -> Promise<Bool> {
        var needToResign = false
        
    
        
        
        
        return .value(needToResign)
    }
    
    func checkAndSignAuthMessage(_ signProps: CheckAndSignAuthParams) -> Promise<JsonAuthSig> {
        var signProps = signProps
        let chainInfo = ALL_LIT_CHAINS[signProps.chain]
        
        if chainInfo == nil {
            return Promise.init(error: LitError.UNSUPPORTED_CHAIN_EXCEPTION(signProps.chain.rawValue))
        }
        
        if signProps.expiration == nil {
            signProps.expiration = getExpiration(1000 * 60 * 60 * 24 * 7)
        }
        if chainInfo?.vmType == .EVM {
            return checkAndSignEVMAuthMessage()
        } else if chainInfo?.vmType == .CVM {
            return checkAndSignCosmosAuthMessage()
        } else if chainInfo?.vmType == .SVM {
            return checkAndSignSolAuthMessage()
        } else {
            return Promise.init(error: LitError.UNSUPPORTED_CHAIN_EXCEPTION(signProps.chain.rawValue))
        }
    }
    
    func checkAndSignEVMAuthMessage() -> Promise<JsonAuthSig> {
        return .value(JsonAuthSig(sig: "", derivedVia: "", signedMessage: "", address: "", capabilities: [], algo: []))
    }
    
    func checkAndSignSolAuthMessage() -> Promise<JsonAuthSig> {
        return .value(JsonAuthSig(sig: "", derivedVia: "", signedMessage: "", address: "", capabilities: [], algo: []))
    }
    
    func checkAndSignCosmosAuthMessage() -> Promise<JsonAuthSig> {
        return .value(JsonAuthSig(sig: "", derivedVia: "", signedMessage: "", address: "", capabilities: [], algo: []))
    }
    
    func handshakeWithNode(_ url: String) -> Promise<NodeCommandServerKeysResponse> {
        let urlWithPath = "\(url)/web/handshake"
        let parameters = ["clientPublicKey" : "test"]
        return fetch(urlWithPath, parameters: parameters, decodeType: NodeCommandServerKeysResponse.self)
    }

}

extension LitClient {
    func getSessionKeyUri(_ publicKey: String) -> String {
        return LIT_SESSION_KEY_URI + publicKey
    }
    
    func getSessionCapabilities(_ capabilities: [String]?, resources: [String]) -> [String]? {
        var capabilities = capabilities ?? []
        if capabilities.count == 0 {
            capabilities = resources.map({
                let (protocolType, _) = parseResource($0)
                return "\(protocolType)Capability://*"
            })
        }
        return capabilities
        
    }
    
    func parseResource(_ resource: String) -> (protocolType: String, resourceId: String) {
        return (resource.components(separatedBy: "://").first ?? "", resource.components(separatedBy: "://").last ?? "")
    }
    
    func getExpiration(_ appendSeconds: TimeInterval) -> String {
        let date = Date(timeIntervalSinceNow: appendSeconds)
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: date)
    }
}
