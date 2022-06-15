//
//  UserSessionModel.swift
//  ObjectDetection
//
//  Created by Joseph Ouyang on 2022/6/4.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

import FirebaseAuth
import FirebaseStorage

import FBSDKLoginKit

class UserSessionModel: ObservableObject {
    static var session: UserSessionModel?
    @Published var user = Auth.auth().currentUser
    @Published var userModel = UserDataViewModel()
    
    @Published var isLogged = false
    @Published var photoURL = URL.demo_pikachu
    
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
        userModel.userSession = self
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
    
    func signup(username: String, email: String, password: String, image: UIImage, completion: @escaping (CompletionResult) -> Void = { result in
        
    }) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
             guard let user = result?.user,
                   error == nil else {
                 completion(CompletionResult.Error(error: error!))
                 return
             }
            
            self.replaceUserPhoto(user: user, image: image, completion: { result in
                if result.status == true {
                    self.saveUserBasicInfo(displayName: username, photoURL: URL.demo_pikachu, completion: completion)
                } else {
                    completion(result)
                }
            })
        }
    }
    
    func uploadPhoto(image: UIImage, child_path: String = "", completion: @escaping (CompletionResult) -> Void = { result in
        
    }) {
        let fileReference = Storage.storage().reference().child(child_path == "" ? "images/" + UUID().uuidString + ".jpg" : child_path)
        
        if let data = image.jpegData(compressionQuality: 0.5) {
            
            fileReference.putData(data, metadata: nil) { (metadata, error) in
                guard let _ = metadata else {
                    completion(CompletionResult.Error(error: error!))
                    return
                }
                
                fileReference.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        completion(CompletionResult.Error(error: error!))
                        return
                    }
                    
                    completion(CompletionResult(status: true, message: "\( downloadURL.absoluteString )"))
                }
            }
        }
    }
    
    func replacePhoto(image: UIImage, url: URL, completion: @escaping (CompletionResult) -> Void = { result in
        
    }) {
        let starsRef = Storage.storage().reference(forURL: url.absoluteString)

        // Fetch the download URL
        starsRef.downloadURL { _, error in
          if let _ = error {
              self.uploadPhoto(image: image, completion: completion)
          } else {
              let fileReference = Storage.storage().reference(forURL: url.absoluteString)
              fileReference.delete { error in
                  if let error = error {
                      print("[UserSessionModel] - replacePhoto - delete image failed with error : \( error )")
                      completion(CompletionResult.Error(error: error))
                  } else {
                      self.uploadPhoto(image: image, child_path: fileReference.fullPath, completion: completion)
                  }
              }
          }
        }
    }
    
    func saveUserBasicInfo(displayName: String?, photoURL: URL, completion: @escaping (CompletionResult) -> Void = { result in
        
    }) {
        if let user = user {
            let changeRequest = user.createProfileChangeRequest()
            if photoURL != URL.demo_pikachu {
                changeRequest.photoURL = photoURL
            }
            if let displayName = displayName {
                if displayName.isEmpty == false {
                    changeRequest.displayName = displayName
                }
            }
            changeRequest.commitChanges(completion: { error in
                guard error == nil else {
                   completion(CompletionResult.Error(error: error!))
                   return
                }
                
                completion(CompletionResult(status: true, message: "Save successfully"))
            })
        } else {
            completion(CompletionResult(status: false, message: "Not login"))
        }
    }
    
    func replaceUserPhoto(user: User, image: UIImage, completion: @escaping (CompletionResult) -> Void = { result in
        
    }) {
        if image == .demo_pikachu {
            completion(CompletionResult(status: true))
       } else {
           let targetSize = CGSize(width: 256, height: 256)
           var image = image
           if let newImage = image.centerCropImage(targetSize: targetSize) {
               image = newImage
           }
           
           if let photoURL = user.photoURL {
               self.replacePhoto(image: image, url: photoURL, completion: { result in
                   if result.status == true {
                       self.saveUserBasicInfo(displayName: user.displayName, photoURL: URL(string: result.message)!, completion: completion)
                   } else {
                       completion(result)
                   }
               })
           } else {
               self.uploadPhoto(image: image, completion: { result in
                   if result.status == true {
                       self.saveUserBasicInfo(displayName: user.displayName, photoURL: URL(string: result.message)!, completion: completion)
                   } else {
                       completion(result)
                   }
               })
           }
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
    
    func resetPassword(completion: @escaping (CompletionResult) -> Void = { result in
        
    }) {
        if let email = user?.email {
            if email.isEmpty == false{
                Auth.auth().sendPasswordReset(withEmail: email) { error in
                   DispatchQueue.main.async {
                       if error == nil && email.isEmpty==false{
                           completion(CompletionResult(status: true))
                           return
                       }
                   }
               }
            }
        }
        completion(CompletionResult(status: false, message: "Something's wrong"))
    }
    
    func resetPasswordWithEmail(
        email: String,
        completion: @escaping (CompletionResult) -> Void = { result in
            
        }
    ) {
        if email.isEmpty == true {
            completion(CompletionResult(status: false, message: "Email address can not be empty."))
        } else {
            Auth.auth().sendPasswordReset(withEmail: email) { error in
               DispatchQueue.main.async {
                   if let error = error {
                       completion(CompletionResult.Error(error: error))
                   } else {
                       completion(CompletionResult(status: true, message: "Reset password Email was sent."))
                   }
               }
           }
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
        self.photoURL = self.user?.photoURL ?? URL.demo_pikachu
        self.userModel.updateUser(userID: self.user?.uid ?? "")
        
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
