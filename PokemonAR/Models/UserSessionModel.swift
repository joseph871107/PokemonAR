//
//  UserSessionModel.swift
//  ObjectDetection
//
//  Created by Joseph Ouyang on 2022/6/4.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import Foundation
import SwiftUI

import FirebaseAuth

import FBSDKLoginKit

class UserSessionModel: ObservableObject {
    static var session: UserSessionModel?
    @Published var user = Auth.auth().currentUser
    @Published var userModel = UserModel()
    
    @Published var isLogged = false
    
    var userName: String {
        if let user = user {
            if let name = user.displayName {
                return name
            }
            
            return "user_\(user.uid)"
        }
        
        return "Not login"
    }
    
    init() {
        self.updateUser()
    }
    
    func create(username: String, password: String, completion: @escaping (CompletionResult) -> Void = { result in
        
    }) {
        Auth.auth().createUser(withEmail: username, password: password) { result, error in
             guard let _ = result?.user,
                   error == nil else {
                 completion(CompletionResult.Error(error: error!))
                 return
             }
            completion(CompletionResult(status: true))
        }
    }
    
    func login(username: String, password: String, completion: @escaping (CompletionResult) -> Void = { result in
        
    }) {
        if (
            username == LoginCredential.Demo.username &&
            password == LoginCredential.Demo.password
        ){
            Auth.auth().signIn(withEmail: username, password: password) { result, error in
                guard error == nil else {
                    let errResult = CompletionResult.Error(error: error!)
                    if errResult.message == "There is no user record corresponding to this identifier. The user may have been deleted." {
                        self.create(username: username, password: password, completion: { finalResult in
                            completion(finalResult)
                        })
                    } else {
                        completion(errResult)
                    }
                    
                    return
                }
                self.updateUser()
                completion(CompletionResult(status: true))
            }
        } else {
            Auth.auth().signIn(withEmail: username, password: password) { result, error in
                guard error == nil else {
                    completion(CompletionResult.Error(error: error!))
                    return
                }
                self.updateUser()
                completion(CompletionResult(status: true))
            }
        }
    }
    
    func logout(completion: @escaping (CompletionResult) -> Void = { result in
        
    }) {
        do {
            print("[UserSessionModel] - Logging out")
            
            if self.isFB{
                print("[UserSessionModel] - Also Logging out Facebook")
                let loginManager = LoginManager()
                loginManager.logOut()
                
                print("[UserSessionModel] - Facebook Logged out")
            }
            
            try Auth.auth().signOut()
            print("[UserSessionModel] - Logged out")
            
            self.updateUser()
            completion(CompletionResult(status: true))
        } catch {
            completion(CompletionResult.Error(error: error))
        }
    }
    
    enum AuthProviders: String {
        case password = "password"
        case phone = "phone"
        case facebook = "facebook.com"
        case google = "google.com"
        case apple = "apple.com"
    }
    
    var provider: AuthProviders {
        if let providerId = Auth.auth().currentUser?.providerData.first?.providerID {
            if let provider = AuthProviders(rawValue: providerId){
                return provider
            }
        }
        return .password
    }
    
    var isFB: Bool {
        return self.provider == .facebook
    }
    
    private func debugProviderInfo() {
        if let user = user {
            print("   [provider Info] - \( String(describing: user.providerID ) )")
            print("   [provider Info] - \( String(describing: user.providerData ) )")
            print("   [provider Info] - \( String(describing: user.providerData.count ) )")
            print("   [provider Info] - \( String(describing: user.providerData.description ) )")
                
            for i in user.providerData.indices {
                let data = user.providerData[i]
                print("   [provider Info] - \( String(describing: data ) )")
                
                print("       [provider Data] - \( String(describing: data.uid ) )")
                print("       [provider Data] - \( String(describing: data.providerID ) )")
                print("       [provider Data] - \( String(describing: data.hash ) )")
                print("       [provider Data] - \( String(describing: AuthProviders(rawValue: data.providerID) ) )")
            }
        }
    }
    
    func updateUser(isFB: Bool = false) {
        self.user = Auth.auth().currentUser
        
        if self.user != nil {
            self.isLogged = true
            print("[UserSessionModel.swift] - Successfully logged in")
        } else {
            self.isLogged = false
            print("[UserSessionModel.swift] - Unsuccessfully logged in")
        }
    }
    
    func loginDemo(completion: @escaping (CompletionResult) -> Void = { result in
        
    }) {
        self.login(username: LoginCredential.Demo.username, password: LoginCredential.Demo.password, completion: { result in
            completion(result)
        })
    }
}

struct LoginCredential {
    var username: String
    var password: String
    
    static var Demo: LoginCredential {
        return LoginCredential(username: "test@test.com", password: "000000")
    }
}

struct CompletionResult {
    var status: Bool
    var message = ""
    
    mutating func setError(error: Error) {
        let message = error.localizedDescription
        self.message = message
        self.status = false
    }
    
    static func Error(error: Error) -> CompletionResult {
        var result = CompletionResult(status: false)
        result.setError(error: error)
        return result
    }
}
