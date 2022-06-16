//
//  LoginView.swift
//  ObjectDetection
//
//  Created by Joseph Ouyang on 2022/6/4.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import SwiftUI
import FBSDKLoginKit

struct LoginView: View {
    @EnvironmentObject var userSession: UserSessionModel
    
    @State var username: String = ""
    @State var password: String = ""
    
    @State var showSignup = false
    
    @State private var keyboardHeight: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            let imgSize = geometry.size.width * 0.5
            ThemeAccountView(
                imgSize: imgSize,
                imageHolder: {
                    UserImage(imgSize: imgSize)
                },
                content: {
                    GeometryReader { geo in
                        let width = geo.size.width
                        
                        VStack {
                            InputCredential(username: $username, password: $password)
                            VStack{
                                LoginButton(width: width, username: $username, password: $password)
                                ZStack{
                                    ForgotPasswordView()
#if DEBUG
                                    DemoLoginView()
                                        .frame(width: width, alignment: .trailing)
                                        .zIndex(1)
#endif
                                }
                                .padding(.bottom, -20)
                            }
                            LabelledDivider(label: "or", horizontalPadding: width * 0.5 * 0.2)
                                .padding(.vertical, -20)
                            VStack{
                                FBLoginView(
                                    buttonContent: {
                                        Text("Login with Facebook")
                                            .font(.subheadline)
                                            .frame(width: width, height: 60)
                                            .turnIntoButtonStyle(.facebookBlue)
                                    },
                                    onSuccess: { user in
                                        userSession.updateUser()
                                    }
                                )
                                SignupTriggerView(showSignup: $showSignup)
                            }
                        }
                    }
                    .padding(.top, imgSize * 0.5)
                    .padding()
                    .keyboardAdaptive()
                },
                toolbarItemsContent: MyToolBarContent()
            )
        }
        .sheet(isPresented: $showSignup, content: {
            SignupView()
        })
        .environmentObject(userSession)
    }
    
    struct MyToolBarContent: ToolbarContent {
        var body: some ToolbarContent {
            ToolbarItem(placement: .principal, content: {
                WelcomeText()
            })
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(username: LoginCredential.Demo.username, password: LoginCredential.Demo.password)
            .environmentObject(UserSessionModel())
    }
}

struct WelcomeText : View {
    var body: some View {
        return Text("Welcome!")
            .font(.largeTitle)
            .fontWeight(.semibold)
            .foregroundColor(.white)
    }
}

struct UserImage : View {
    @State var imgSize: CGFloat
    
    var body: some View {
        return Image(uiImage: .demo_pikachu)
            .circleWithBorderNShadow(width: imgSize, height: imgSize)
    }
}

struct InputCredential : View {
    @Binding var username: String
    @Binding var password: String
    
    var body: some View {
        return VStack{
            TextField("Email address", text: $username)
                .autocapitalization(.none)
                .turnIntoTextFieldStyle()
                .padding(.bottom, 20)
                .keyboardType(.emailAddress)
            SecureInputView("Password", text: $password)
        }
        .padding(.bottom, 20)
    }
}

struct SecureInputView: View {
    @Binding private var text: String
    @State private var isSecured: Bool = true
    private var title: String
    
    init(_ title: String, text: Binding<String>) {
        self.title = title
        self._text = text
    }
    
    var body: some View {
        ZStack(alignment: .trailing) {
            Group {
                if isSecured {
                    SecureField(title, text: $text)
                } else {
                    TextField(title, text: $text)
                }
            }
            .autocapitalization(.none)
            .turnIntoTextFieldStyle()

            Button(action: {
                isSecured.toggle()
            }) {
                Image(systemName: self.isSecured ? "eye.slash" : "eye")
                    .accentColor(isSecured ? .gray : .red)
                    .padding()
            }
        }
    }
}

struct LoginButtonContent : View {
    var width: CGFloat
    
    @Binding var disable: Bool
    
    var body: some View {
        Text("Login")
            .font(.headline)
            .frame(width: width, height: 60)
            .turnIntoButtonStyle(disable == false ? .pokemonRed : .gray)
    }
}

struct LoginButton : View {
    var width: CGFloat
    
    @EnvironmentObject var userSession: UserSessionModel
    
    @Binding var username: String
    @Binding var password: String
    
    @State private var showAlert = false
    @State var result = ""
    
    var body: some View {
        let loginDisable = Binding(get: {
            return (self.username.isEmpty || self.password.isEmpty)
        }, set: {_,_ in

        })
        
        return ButtonBehaviorContent(
            width: width,
            action: {
                self.login(completion: { result in
                    self.result = "\(String(result.status)) : \(result.message) \(userSession.user?.email ?? "") \(userSession.user?.uid ?? "")"
                })
            },
            disable: loginDisable
        )
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Login Result"),
                message: Text("\(self.result)"),
                dismissButton: .default(Text("Okay"), action: {

                })
            )
        }
    }
    
    func login(completion: @escaping (CompletionResult) -> Void) {
        userSession.login(username: username, password: password, completion: { result in
            switch(result.status){
            case true:
                completion(result)
                showAlert = true
            case false:
                completion(result)
                showAlert = true
            }
        })
    }
    
    struct ButtonBehaviorContent : View {
        var width: CGFloat
        
        @State var action: () -> Void
        @Binding var disable: Bool
        
        var body: some View {
            Button(action: { action() }) {
                LoginButtonContent(width: width, disable: $disable)
            }
            .disabled(disable)
        }
    }
}

struct ForgotPasswordView: View {
    @EnvironmentObject var userSession: UserSessionModel
    
    @State private var showDialog = false
    @State private var showAlert = false
    
    @State private var showAlertText = ""
    
    var body: some View {
        Button(action: {
            showDialog = true
        }, label: {
            Text("Forget your password?")
                .foregroundColor(.red)
                .fontWeight(.heavy)
        })
        .alert(
            isPresented: $showDialog,
            TextAlert(title: "Reset password", message: "Please enter your Email address", action: { email in
                if email?.isEmpty == false {
                    userSession.resetPasswordWithEmail(
                        email: email ?? "",
                        completion: { result in
                            if result.status == true {
                                showAlertText = "Reset password email sent."
                            } else {
                                showAlertText = result.message
                            }
                            showAlert = true
                        }
                    )
                }
            })
        )
        .alert(isPresented: $showAlert, content: {
            Alert(title: Text("Reset password"), message: Text("\( showAlertText )"), dismissButton: .cancel(Text("Okay")))
        })
    }
}

struct SignupTriggerView: View {
    @Binding var showSignup: Bool
    
    var body: some View {
        VStack {
            Text("Don't have an account yet?")
            Button(action: {
                showSignup = true
            }, label: {
                Text("Be a Pokémon master NOW!")
                    .foregroundColor(.pokemonRed)
                    .fontWeight(.heavy)
            })
        }
    }
}

struct DemoLoginView : View {
    @EnvironmentObject var userSession: UserSessionModel
    
    var body: some View {
        Button(action: {
            userSession.loginDemo()
        }, label: {
            Text("demo login")
                .font(.caption)
        })
    }
}
