//
//  SignupView.swift
//  PokemonAR
//
//  Created by Joseph Ouyang on 2022/6/15.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import SwiftUI

struct SignupView: View {
    @EnvironmentObject var userSession: UserSessionModel
    
    @State var image = UIImage()
    @State var username: String = ""
    @State var email: String = ""
    @State var password: String = ""
    
    var body: some View {
        GeometryReader { geometry in
            let imgSize = geometry.size.width * 0.5
            ThemeAccountView(
                imgSize: imgSize,
                imageHolder: {
                    SignupEditableImageView(size: imgSize, selected_image: $image)
                },
                content: {
                    VStack {
                        InputCredentialWithEmail(username: $username, email: $email, password: $password)
                        SignupButton(image: $image, username: $username, email: $email, password: $password)
                        Spacer()
                    }
                    .padding()
                    .environmentObject(userSession)
                },
                toolbarItemsContent: MyToolBarContent()
            )
        }
    }
    
    struct MyToolBarContent: ToolbarContent {
        var body: some ToolbarContent {
            ToolbarItem(placement: .principal, content: {
                Text("Become a Pokémon Master!")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding(.top, 50)
            })
        }
    }
}

struct SignupEditableImageView : View {
    @EnvironmentObject var userSession: UserSessionModel
    
    @State var size: CGFloat
    
    @Binding var selected_image: UIImage
    
    var body: some View{
        EditableImageView(size: size, selected_image: $selected_image, imageContent: {
            if let image = selected_image {
                Image(uiImage: image)
                    .circleWithBorderNShadow(width: size, height: size)
            } else {
                Image(uiImage: UIImage.demo_pikachu)
                    .circleWithBorderNShadow(width: size, height: size)
            }
        })
    }
}

struct InputCredentialWithEmail : View {
    @Binding var username: String
    @Binding var email: String
    @Binding var password: String
    
    var body: some View {
        return VStack{
            TextField("Username", text: $username)
                .autocapitalization(.none)
                .turnIntoTextFieldStyle()
                .padding(.bottom, 20)
            TextField("Email address", text: $email)
                .autocapitalization(.none)
                .turnIntoTextFieldStyle()
                .padding(.bottom, 20)
            SecureInputView("Password", text: $password)
        }
    }
}

struct SignupButtonContent : View {
    @Binding var disable: Bool
    
    var body: some View {
        GeometryReader { geometry in
            Text("Signup")
                .font(.title)
                .frame(width: geometry.size.width, height: 60)
                .turnIntoButtonStyle(disable == false ? .pokemonRed : .gray)
        }
    }
}

struct SignupButton : View {
    @EnvironmentObject var userSession: UserSessionModel
    
    @Binding var image: UIImage
    @Binding var username: String
    @Binding var email: String
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
                self.signup(completion: { result in
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
    
    func signup(completion: @escaping (CompletionResult) -> Void) {
        userSession.signup(username: username, email: email, password: password, image: image, completion: { result in
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
            Button(action: { action() }) {
                SignupButtonContent(disable: $disable)
            }
            .disabled(disable)
        }
    }
}

struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView()
            .environmentObject(UserSessionModel())
    }
}
