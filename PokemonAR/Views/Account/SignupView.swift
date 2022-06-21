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
    
    @State var image: UIImage? = nil
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
                    GeometryReader { geo in
                        let width = geo.size.width
                        
                        VStack {
                            InputCredentialWithEmail(username: $username, email: $email, password: $password)
                                .padding(.bottom, 20)
                            SignupButton(width: width, image: $image, username: $username, email: $email, password: $password)
                                .zIndex(1)
                            LabelledDivider(label: "or", horizontalPadding: width * 0.5 * 0.3)
                                .padding(.vertical, -20)
                                .padding(.top, -10)
                            FBLoginView(
                                buttonContent: {
                                    Text("Signup with Facebook")
                                        .font(.subheadline)
                                        .frame(width: width, height: 60)
                                        .turnIntoButtonStyle(.facebookBlue)
                                },
                                onSuccess: { user in
                                    userSession.updateUser()
                                }
                            )
                            .padding(.top, -35)
                        }
                        .environmentObject(userSession)
                    }
                    .padding(.top, imgSize * 0.5)
                    .padding()
                    .keyboardAdaptive()
                },
                toolbarItemsContent: {
                    VStack {
                        Text("Become a Pokémon Master!")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding(.top, geometry.size.height * 0.02)
                    }
                    .frame(height: geometry.size.height * 0.15, alignment: .top)
                }
            )
        }
    }
}

struct SignupEditableImageView : View {
    @EnvironmentObject var userSession: UserSessionModel
    
    @State var size: CGFloat
    
    @Binding var selected_image: UIImage?
    
    var body: some View{
        VStack{
            EditableImageView(size: size, selected_image: $selected_image, imageContent: {
                if let image = selected_image {
                    Image(uiImage: image)
                        .circleWithBorderNShadow(width: size, height: size)
                } else {
                    Image(uiImage: UIImage.demo_pikachu)
                        .circleWithBorderNShadow(width: size, height: size)
                }
            })
            .onChange(of: selected_image, perform: { newImage in
                print(selected_image!.size)
                print(selected_image!.isNull)
                print(newImage!.size)
                print(newImage!.isNull)
            })
        }
    }
}

class ForceViewUpdate: ObservableObject {
    func reloadView() {
        objectWillChange.send()
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
//                .padding(.bottom, 20)
                .keyboardType(.alphabet)
            TextField("Email address", text: $email)
                .autocapitalization(.none)
                .turnIntoTextFieldStyle()
//                .padding(.bottom, 20)
                .keyboardType(.emailAddress)
            SecureInputView("Password", text: $password)
        }
    }
}

struct SignupButtonContent : View {
    var width: CGFloat
    
    @Binding var disable: Bool
    
    var body: some View {
        Text("Signup")
            .font(.headline)
            .frame(width: width, height: 60)
            .turnIntoButtonStyle(disable == false ? .pokemonRed : .gray)
    }
}

struct SignupButton : View {
    var width: CGFloat
    
    @EnvironmentObject var userSession: UserSessionModel
    
    @Binding var image: UIImage?
    @Binding var username: String
    @Binding var email: String
    @Binding var password: String
    
    @State private var showAlert = false
    @State var result = ""
    
    var body: some View {
        let loginDisable = Binding(get: {
            return (self.username.isEmpty || self.password.isEmpty || self.email.isEmpty)
        }, set: {_,_ in

        })
        
        return ButtonBehaviorContent(
            width: width,
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
        userSession.signup(username: username, email: email, password: password, image: image ?? .demo_pikachu, completion: { result in
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
                SignupButtonContent(width: width, disable: $disable)
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
