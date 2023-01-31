//
//  ViewController.swift
//  Example
//
//  Created by leven on 2023/1/4.
//

import UIKit
import LitOAuthPKPSignUp
import GoogleSignIn
import SnapKit

//let relayApi = "https://localhost:3001/"
let RELAY_SERVER = "https://lit-relay-server.api.3wlabs.xyz:3001/"

class ViewController: UIViewController {
    lazy var googleSignInButton: GIDSignInButton = {
        let button = GIDSignInButton()
        return button
    }()

    lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    lazy var OAuthClient = LitClient(relay: relayApi)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.googleSignInButton)
        self.view.addSubview(self.infoLabel)

        self.googleSignInButton.snp.makeConstraints { make in
            make.left.equalTo(40)
            make.right.equalTo(-40)
            make.top.equalTo(100)
        }
        
        self.infoLabel.snp.makeConstraints { make in
            make.left.equalTo(googleSignInButton)
            make.right.equalTo(googleSignInButton)
            make.top.equalTo(googleSignInButton.snp.bottom).offset(30)
        }
        self.googleSignInButton.addTarget(self, action: #selector(didClickGoogleSignUp), for: .touchUpInside)
       
    }

    @objc func didClickGoogleSignUp() {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] res, err in
            guard let `self` = self else { return }
            if let tokenString = res?.user.idToken?.tokenString {
                self.infoLabel.text = "Try to mint PKP \n tokenString: \(tokenString)"
                self.handleLoggedInToGoogle(tokenString)
            }
        }
    }
    
    
    func handleLoggedInToGoogle(_ tokenString: String) {
        OAuthClient.handleLoggedInToGoogle(tokenString) { [weak self] requestId, error in
            guard let `self` = self else { return }
            if let requestId = requestId {
                self.infoLabel.text = "Successfully initiated minting PKP with requestId: \(requestId) \n\n Waiting for auth completion... "
                self.requestPKP(with: requestId)
            } else if let error = error {
                self.infoLabel.text = error
            }
        }
    }
    
    func requestPKP(with requestId: String) {
        OAuthClient.pollRequestUntilTerminalState(with: requestId) { [weak self]result, error in
            guard let `self` = self else { return }
            if let result = result {
                let pkpEthAddress = result["pkpEthAddress"] as? String ?? ""
                let pkpPublicKey = result["pkpPublicKey"] as? String ?? ""
                self.infoLabel.text = "pkpEthAddress: \(pkpEthAddress) \npkpPublicKey: \(pkpPublicKey)"
            } else if let error = error {
                self.infoLabel.text = error
            }
        }
    }

}

