//
//  WalleteViewController.swift
//  Example
//
//  Created by leven on 2023/1/9.
//

import Foundation
import SnapKit
import UIKit
import GoogleSignIn
import Kingfisher
import LitProtocolSwiftSDK
import web3
class WalletViewController: UIViewController {
    
    let pkpEthAddress: String
    let pkpPublicKey: String
    let profile: [String: String]
    let auth: [String: Any]
    init(pkpEthAddress: String,
         pkpPublicKey: String,
         auth: [String: Any],
         profile: [String: String]) {
        self.pkpEthAddress = pkpEthAddress
        self.pkpPublicKey = pkpPublicKey
        self.profile = profile
        self.auth = auth
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var avatarImageView: UIImageView = {
        let imageV = UIImageView()
        imageV.contentMode = .scaleAspectFill
        imageV.backgroundColor = UIColor.black.withAlphaComponent(0.08)
        return imageV
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        return label
    }()
    
    lazy var emailLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        return label
    }()
    
    lazy var addressLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        return label
    }()
    
    lazy var publicKeyLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        return label
    }()
    
    lazy var sendButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Send", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        button.backgroundColor = UIColor.black
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 4
        return button
    }()
    
    lazy var receiveButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Receive", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 4
        button.layer.borderColor = UIColor.black.withAlphaComponent(0.7).cgColor
        button.layer.borderWidth = 1
        return button
    }()
    
    var litClient: LitClient = LitClient(config: LitNodeClientConfig(bootstrapUrls: LitNetwork.serrano.networks, litNetwork: .serrano))

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
        self.updateUI()
    }
    
    func initUI() {
        self.view.backgroundColor = .white
        self.view.addSubview(self.avatarImageView)
        self.view.addSubview(self.nameLabel)
        self.view.addSubview(self.emailLabel)
        self.avatarImageView.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(30 + UIApplication.shared.statusBarFrame.height)
            make.size.equalTo(80)
        }
        self.avatarImageView.layer.cornerRadius = 40
        self.avatarImageView.layer.masksToBounds = true
        self.avatarImageView.layer.borderWidth = 0.5
        self.avatarImageView.layer.borderColor = UIColor.black.withAlphaComponent(0.5).cgColor
            
        
        self.nameLabel.snp.makeConstraints { make in
            make.left.equalTo(self.avatarImageView.snp.right).offset(12)
            make.centerY.equalTo(self.avatarImageView).offset(-15)
        }
        self.emailLabel.snp.makeConstraints { make in
            make.left.equalTo(self.nameLabel)
            make.top.equalTo(self.nameLabel.snp.bottom).offset(6)
        }
        
        let profileLineV = UIView()
        profileLineV.backgroundColor = UIColor.black.withAlphaComponent(0.08)
        self.view.addSubview(profileLineV)
        profileLineV.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.avatarImageView.snp.bottom).offset(20)
            make.height.equalTo(0.5)
        }
        
        self.view.addSubview(self.addressLabel)
        self.view.addSubview(self.publicKeyLabel)

        self.addressLabel.snp.makeConstraints { make in
            make.left.equalTo(avatarImageView)
            make.top.equalTo(profileLineV.snp.bottom).offset(14)
            make.right.equalTo(-16)
        }
        
        self.publicKeyLabel.snp.makeConstraints { make in
            make.left.equalTo(avatarImageView)
            make.top.equalTo(addressLabel.snp.bottom).offset(8)
            make.right.equalTo(-16)
        }
         
        let bottomStackView = UIStackView()
        bottomStackView.spacing = 20
        bottomStackView.axis = .horizontal
        bottomStackView.distribution = .fillEqually
        bottomStackView.addArrangedSubview(sendButton)
        bottomStackView.addArrangedSubview(receiveButton)
        self.view.addSubview(bottomStackView)
        bottomStackView.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.bottom.equalTo(-safeBottomHeight - 20)
            make.height.equalTo(50)
        }
        
        self.sendButton.addTarget(self, action: #selector(clickSend), for: .touchUpInside)
        self.receiveButton.addTarget(self, action: #selector(clickReceive), for: .touchUpInside)
        let _ = self.litClient.connect().done {  [weak self]in
            guard let self = self else { return }
            self.litClient.updateAuth(self.auth)
        }
    }
    
    
    func updateUI() {
        self.avatarImageView.kf.setImage(with: URL(string:  self.profile["avatar"] ?? "")!)
        self.nameLabel.text = self.profile["name"]
        self.emailLabel.text = self.profile["email"]
        self.addressLabel.text = "Address: " + self.pkpEthAddress
        self.publicKeyLabel.text = "Public Key: " + self.pkpPublicKey
    }
    
    @objc
    func clickSend() {
        let address = self.litClient.computeAddress(publicKey: self.pkpPublicKey)!
        print(address)
        self.litClient.sendPKPTransaction(toAddress: "0x9fFA98D827329941295B28B626B6513B333ebe2c",
                                          fromAddress: address,
                                          value: "0x0",
                                          data: "0x00",
                                          chain: .mumbai,
                                          publicKey: self.pkpPublicKey,
                                          gasPrice: "0x2e90edd000",
                                          gasLimit: 30000.web3.hexString).done { res in
            
        }.catch { err in
            print(err)
        }
    }
    
    lazy var web3 = EthereumHttpClient(url: URL(string: LIT_CHAINS[.mumbai]?.rpcUrls.first ?? "")!)
    
    @objc
    func clickReceive() {
        Task {
            do {
                let res = try await web3.eth_getBalance(address: EthereumAddress(self.pkpEthAddress), block: EthereumBlock.Latest)
                print(res.web3.bytes)
                let value = UInt64(res.web3.hexString.web3.noHexPrefix, radix: 16) ?? 0
                print("Value: \( Double(value) / pow(Double(10), Double(18)))")
                print("Hex: \(res.web3.hexString)")
            } catch {
                print(error)
            }
        }
    }
    
}

extension WalletViewController {

    func connect() {
        let _ = litClient.connect().done { _ in
            
        }.catch { error in
            print(error)
        }
    }
}
