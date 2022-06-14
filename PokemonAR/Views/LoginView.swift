//
//  LoginView.swift
//  ObjectDetection
//
//  Created by Joseph Ouyang on 2022/6/4.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var userSession: UserSessionModel
    
    @State var user_image: String = "demo_cat"
    @State var username: String = ""
    @State var password: String = ""
    
    var body: some View {
        VStack {
            WelcomeText()
            UserImage(user_image: $user_image)
            InputCredential(username: $username, password: $password)
            LoginButton(username: $username, password: $password)
            DemoLoginView()
        }
        .padding()
        .environmentObject(userSession)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(user_image: "demo_cat", username: LoginCredential.Demo.username, password: LoginCredential.Demo.password)
            .environmentObject(UserSessionModel())
    }
}

struct WelcomeText : View {
    var body: some View {
        return Text("Welcome!")
            .font(.largeTitle)
            .fontWeight(.semibold)
            .padding(.bottom, 20)
    }
}

struct UserImage : View {
    @Binding var user_image: String
    
    var body: some View {
        return Image(user_image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 150, height: 150)
            .clipped()
            .cornerRadius(150)
            .padding(.bottom, 75)
    }
}

struct InputCredential : View {
    @Binding var username: String
    @Binding var password: String
    
    var body: some View {
        return VStack{
            TextField("Username", text: $username)
                .padding()
                .background(Color.lightGray)
                .cornerRadius(5.0)
                .padding(.bottom, 20)
                .autocapitalization(.none)
            SecureField("Password", text: $password)
                .padding()
                .background(Color.lightGray)
                .cornerRadius(5.0)
                .padding(.bottom, 20)
                .autocapitalization(.none)
        }
    }
}

struct LoginButtonContent : View {
    @Binding var disable: Bool
    
    var body: some View {
        return Text("LOGIN")
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(width: 220, height: 60)
            .background(disable ? Color.gray : Color.green)
            .animation(.easeInOut, value: disable)
            .cornerRadius(15.0)
    }
}

struct LoginButton : View {
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
            action: {
                self.login(completion: { result in
                    self.result = "\(String(result.status)) : \(result.message) \(userSession.user?.email ?? "") \(userSession.user?.uid ?? "")"
                })
            },
            disable: loginDisable
        )
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("result"),
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
        @State var action: () -> Void
        @Binding var disable: Bool
        
        var body: some View {
            return Button(action: { action() }) {
                LoginButtonContent(disable: $disable)
            }
            .disabled(disable)
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
