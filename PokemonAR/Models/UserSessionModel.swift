//
//  UserSessionModel.swift
//  ObjectDetection
//
//  Created by Joseph Ouyang on 2022/6/4.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import Foundation
import UIKit

import FirebaseAuth


class UserSessionModel: ObservableObject {
    static var session: UserSessionModel?
    @Published var user = Auth.auth().currentUser
    @Published var userModel = UserModel()
    
    @Published
    var isLogged = false
    
    var userImg: UIImage {
        if let user = user {
            return UIImage.demo_cat
        } else {
            return UIImage.demo_cat
        }
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
            try Auth.auth().signOut()
            self.updateUser()
            completion(CompletionResult(status: true))
        } catch {
            completion(CompletionResult.Error(error: error))
        }
    }
    
    func updateUser() {
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
