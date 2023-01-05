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
let GoogleClientID = "214877071991-0g57o8e6viau3350kni9ecdo9k2othgv.apps.googleusercontent.com"
class ViewController: UIViewController {
    lazy var googleSignInButton: GIDSignInButton = {
        let button = GIDSignInButton()
        return button
    }()

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.addSubview(self.googleSignInButton)
        self.googleSignInButton.snp.makeConstraints { make in
            make.left.equalTo(40)
            make.right.equalTo(-40)
            make.top.equalTo(100)
            make.height.equalTo(50)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.googleSignInButton)
        self.googleSignInButton.addTarget(self, action: #selector(didClickGoogleSignUp), for: .touchUpInside)
    }

    @objc func didClickGoogleSignUp() {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self]res, err in
            guard let self = self else { return }
            if let tokenString = res?.user.idToken?.tokenString {
                self.handleLoggedInToGoogle(tokenString)
            }
        }
    }
    
    
    func handleLoggedInToGoogle(_ tokenString: String) {
        print("tokenString: ", tokenString )
        LitClient.handleLoggedInToGoogle(tokenString) { _ in
            
        }
    }

}

