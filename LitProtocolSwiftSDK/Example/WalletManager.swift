//
//  WalletManager.swift
//  Example
//
//  Created by leven on 2023/1/30.
//

import Foundation
import HandyJSON
import LitProtocolSwiftSDK
import web3
import PromiseKit
class WalletManager {
    static let shared: WalletManager = WalletManager()

    lazy var litClient: LitClient = LitClient(config: LitNodeClientConfig(bootstrapUrls: LitNetwork.serrano.networks, litNetwork: .serrano))

    lazy var web3 = EthereumHttpClient(url: URL(string: LIT_CHAINS[.mumbai]?.rpcUrls.first ?? "")!)

    var currentWallet: WalletModel? {
        didSet {
            if let cur = currentWallet {
                self.saveWallet(cur)
            }
            self.litClient.updateAuth(self.currentWallet?.sessionSigs ?? [:])
        }
    }
    
    init() {
        initWallet()
        let _ = self.litClient.connect().done { [weak self] in
            guard let self = self else { return }
            print("Lit connected!")
            self.litClient.updateAuth(self.currentWallet?.sessionSigs ?? [:])
        }
    }
    
    func initWallet() {
        self.currentWallet = self.loadLocalWallet()
    }

}

extension WalletManager {
    func getBalance() -> Promise<Double> {
        return Promise<Double> { resolver in
            if let currentWallet = currentWallet {
                WalletManager.shared.web3.eth_getBalance(address: EthereumAddress(currentWallet.address), block: EthereumBlock.Latest) { result in
                    switch result {
                    case .failure(let error):
                        print(error)
                        DispatchQueue.main.async {
                            resolver.reject(error)
                        }
                    case .success(let res):
                        let value = UInt64(res.web3.hexString.web3.noHexPrefix, radix: 16) ?? 0
                        let left = Double(value) / pow(Double(10), Double(18))
                        print("Value: \(value)")
                        print("Hex: \(res.web3.hexString)")
                        currentWallet.balance = left
                        self.saveWallet(currentWallet)
                        DispatchQueue.main.async {
                            resolver.fulfill(left)
                        }
                    }
                }
            } else {
                resolver.reject(LitError.COMMON)
            }
        }
    }
    func send(toAddress: String, value: String) -> Promise<String> {
        return self.litClient.sendPKPTransaction(toAddress: toAddress, fromAddress: currentWallet!.address, value: value, data: "0x", chain: .mumbai, publicKey: currentWallet!.publicKey, gasPrice: "0x2e90edd000", gasLimit: "0x7530")
    }
}

private let walletLocalKey = "cur_wallet"
extension WalletManager {
    
    func removeWallet() {
        UserDefaults.standard.removeObject(forKey: walletLocalKey)
    }
    
    func saveWallet(_ wallet: WalletModel) {
        UserDefaults.standard.set(wallet.toJSONString() ?? "", forKey: walletLocalKey)
    }
    
    func loadLocalWallet() -> WalletModel? {
        if let jsonString = UserDefaults.standard.value(forKey: walletLocalKey) as? String {
            return WalletModel.deserialize(from: jsonString)
        }
        return nil
    }
}


class WalletModel: HandyJSON {
    var userInfo: UserInfo?
    var balance: Double = 0
    var address: String = ""
    var publicKey: String = ""
    var sessionSigs: [String: Any]?
    required init() {}
}


class UserInfo: HandyJSON {
    var avatar: String?
    var name: String = ""
    var email: String = ""
    required init() {}
}


