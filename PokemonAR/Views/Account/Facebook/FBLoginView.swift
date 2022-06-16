//
//  ViewController.swift
//  FBLoginTest
//
//  Created by Joseph Ouyang on 2022/6/14.
//

import UIKit
import SwiftUI

import FBSDKLoginKit

import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

struct DefaultFacebookButton: View {
    var body: some View {
        Text("Login with Facebook")
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.vertical, 10)
            .padding(.horizontal, 35)
            .background(Color.facebookBlue)
            .clipShape(Capsule())
    }
}

struct FBLoginView<ButtonContent: View>: View {
    @EnvironmentObject var userSession: UserSessionModel
    
    var manager = LoginManager()
    var isMFAEnabled = false
    var popupView = ViewAcceptPopupViewController()
    var onSuccess: (User) -> Void
    var buttonContent: () -> ButtonContent
    
    init(
        @ViewBuilder buttonContent: @escaping () -> ButtonContent,
        onSuccess: @escaping (User) -> Void = { user in
            
        }
    ) {
        self.buttonContent = buttonContent
        self.onSuccess = onSuccess
    }
    
    var body: some View {
        ZStack{
            popupView
            Button(action: {
                print("[FBLoginView] - Start logging")
                
                manager.logIn(permissions: ["public_profile", "email"], from: nil) { (result, error) in
                    if let error = error {
                        print("[FBLoginView] - \( error.localizedDescription )")
                        return
                    }
                    
                    if let result = result {
                        print("[FBLoginView] - Successfully logged into Facebook")
                        self.loginWithFirebase(token: result.token!, onSuccess: onSuccess)
                    } else {
                        print("[FBLoginView] - failed with result is null")
                    }
                }
            }, label: buttonContent)
        }
    }
    
    func loginWithFirebase(token: AccessToken, onSuccess: @escaping (User) -> Void = { user in
        
    }) {
        print("[loginWithFirebase] - Start auth with token: \( String(describing: token.tokenString) )")
        let credential = FacebookAuthProvider
            .credential(withAccessToken: token.tokenString)
        
        print("[loginWithFirebase] - Start auth with credential: \( String(describing: credential.debugDescription ) )")
        
        let request = GraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email, picture.type(large)"])
        let _ = request.start { [onSuccess] (connection, result, error) in
            guard let userInfo = result as? [String: Any] else { return } //handle the error

            //The url is nested 3 layers deep into the result so it's pretty messy
            if let imageURL = ((userInfo["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String {
                //Download image from imageURL
                
                Auth.auth().signIn(with: credential) { [self, onSuccess] authResult, error in
                    if let error = error {
                        let authError = error as NSError
                        if self.isMFAEnabled, authError.code == AuthErrorCode.secondFactorRequired.rawValue {
                            // The user is a multi-factor user. Second factor challenge is required.
                            let resolver = authError
                                .userInfo[AuthErrorUserInfoMultiFactorResolverKey] as! MultiFactorResolver
                            var displayNameString = ""
                            for tmpFactorInfo in resolver.hints {
                                displayNameString += tmpFactorInfo.displayName ?? ""
                                displayNameString += " "
                            }
                            self.popupView.view.showTextInputPrompt(
                                withMessage: "Select factor to sign in\n\(displayNameString)",
                                completionBlock: { userPressedOK, displayName in
                                    var selectedHint: PhoneMultiFactorInfo?
                                    for tmpFactorInfo in resolver.hints {
                                        if displayName == tmpFactorInfo.displayName {
                                            selectedHint = tmpFactorInfo as? PhoneMultiFactorInfo
                                        }
                                    }
                                    PhoneAuthProvider.provider()
                                        .verifyPhoneNumber(with: selectedHint!, uiDelegate: nil,
                                                           multiFactorSession: resolver
                                            .session) { verificationID, error in
                                                if error != nil {
                                                    print(
                                                        "Multi factor start sign in failed. Error: \(error.debugDescription)"
                                                    )
                                                } else {
                                                    self.popupView.view.showTextInputPrompt(
                                                        withMessage: "Verification code for \(selectedHint?.displayName ?? "")",
                                                        completionBlock: { userPressedOK, verificationCode in
                                                            let credential: PhoneAuthCredential? = PhoneAuthProvider.provider()
                                                                .credential(withVerificationID: verificationID!,
                                                                            verificationCode: verificationCode!)
                                                            let assertion: MultiFactorAssertion? = PhoneMultiFactorGenerator
                                                                .assertion(with: credential!)
                                                            resolver.resolveSignIn(with: assertion!) { authResult, error in
                                                                if error != nil {
                                                                    print(
                                                                        "Multi factor finanlize sign in failed. Error: \(error.debugDescription)"
                                                                    )
                                                                } else {
                                                                    self.popupView.view.navigationController?.popViewController(animated: true)
                                                                }
                                                            }
                                                        }
                                                    )
                                                }
                                            }
                                }
                            )
                        } else {
                            self.popupView.view.showMessagePrompt(error.localizedDescription)
                            return
                        }
                        // ...
                        return
                    }
                    // User is signed in
                    // ...
                    print("Firebase login succeeds with: \( String(describing: authResult?.user.uid) )")
                    
                    // Change default facebook photo url
                    if let photoURL = authResult?.user.photoURL {
                        print(photoURL.absoluteString)
                        if comparePhotoUrl(photoURL.absoluteString, "https://graph.facebook.com/3215762438684092/picture") {
                            let changeRequest = authResult?.user.createProfileChangeRequest()
                            changeRequest?.photoURL = URL(string: imageURL)
                            changeRequest?.commitChanges(completion: { error in
                               guard error == nil else {
                                   print(error?.localizedDescription ?? "")
                                   return
                               }
                                
                                // Seccessfully change user photo to Facebook
                                userSession.updateUser()
                                onSuccess(userSession.user!)
                            })
                        } else {
                            print("No need to update")
                        }
                    }
                    
                    if let user = authResult?.user {
                        onSuccess(user)
                    }
                }
            }
        }
        
        func logOut() {
            do {
                try Auth.auth().signOut()
                let loginManager = LoginManager()
                loginManager.logOut()
            } catch {
                self.popupView.view.showMessagePrompt(error.localizedDescription)
            }
        }
        
        func comparePhotoUrl(_ target: String, _ with: String) -> Bool {
            var target_splits = target.split(separator: "/")
            var with_splits = with.split(separator: "/")
            
            if target_splits.count == 5 && with_splits.count == 5 {
                target_splits.remove(at: 3)
                with_splits.remove(at: 3)
                
                if target_splits.joined(separator: "/") == with_splits.joined(separator: "/") {
                    return true
                }
                
                return false
            }
            
            return target == with
        }
    }
}

struct Previews_FBLoginView_Previews: PreviewProvider {
    static var previews: some View {
        FBLoginView(buttonContent: {
            Text("FB Login")
                .frame(width: 100, height: 50)
                .turnIntoButtonStyle(Color.facebookBlue)
        })
    }
}
