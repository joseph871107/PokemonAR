//
//  AccountSettingView.swift
//  ObjectDetection
//
//  Created by Joseph Ouyang on 2022/6/9.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import SwiftUI

struct AccountSettingView: View {
    @EnvironmentObject var userSession: UserSessionModel
    
    @State var image = UIImage()
    @State var displayName = ""
    @State var birthday = Date()
    @State var gender = Gender.NotRevealed
    
    var body: some View {
        GeometryReader { geometry in
            let imgSize = geometry.size.width * 0.5
            
            ThemeAccountView(
                imgSize: imgSize,
                imageHolder: {
                    SettingEditableImageView(size: imgSize, selected_image: $image)
                        .onChange(of: image, perform: { newImage in
                            if newImage != UIImage() && newImage != UIImage.demo_cat {
                                userSession.replaceUserPhoto(user: userSession.user!, image: newImage, completion: { result in
                                    print(result.status)
                                    print(result.message)
                                    
                                    if result.status == true {
                                        userSession.updateUser()
                                    }
                                })
                            }
                        })
                },
                content: {
                    VStack{
                        VStack{
                            DisplayNameView(displayName: $displayName)
                                .padding()
                            BirthdayPickerView(date: $birthday)
                                .padding()
                            GenderPickerView(gender: $gender)
                                .padding()
                        }
                        Spacer()
                        VStack{
                            SaveChangesView(displayName: $displayName, birthday: $birthday, gender: $gender)
                            ResetPasswordTriggerView()
                        }
                    }
                    .padding()
                },
                toolbarItemsContent: MyToolBarContent()
            )
            .environmentObject(userSession)
            .onAppear(perform: {
                if let name = userSession.user?.displayName {
                    self.displayName = name
                } else {
                    self.displayName = ""
                }
                
                self.birthday = userSession.userModel.data.birthday
                self.gender = userSession.userModel.data.gender
            })
        }
    }
    
    @ToolbarContentBuilder
    func MyToolBarContent() -> some ToolbarContent {
        ToolbarItem(placement: .principal, content: {
            Text("Account Settings")
                .font(.title)
                .foregroundColor(.white)
                .padding(.top, 50)
        })
    }
}

struct AccountSettingView_Previews: PreviewProvider {
    static var previews: some View {
        getAccountSettingView()
    }
}

func getAccountSettingView() -> some View {
    let userSession = UserSessionModel()
    let accountSettingView = AccountSettingView()
        .environmentObject(userSession)
    userSession.loginDemo(completion: { result in
        
    })
    return accountSettingView
}

struct SettingEditableImageView : View {
    @EnvironmentObject var userSession: UserSessionModel
    
    @State var size: CGFloat
    
    @Binding var selected_image: UIImage
    
    var body: some View{
        EditableImageView(size: size, selected_image: $selected_image, imageContent: {
            if let _ = userSession.user?.photoURL {
                AsyncImage(
                    url: $userSession.photoURL,
                    placeholder: {
                        ZStack{
                            Circle().fill(Color.white)
                            LoadingCircle()
                        }
                    },
                    image: {
                        Image(uiImage: $0)
                            .resizable()
                    }
                )
                    .scaledToFit()
                    .aspectRatio(contentMode: .fit)
                    .circleWithBorderNShadow(width: size, height: size)
            } else {
                Image(uiImage: UIImage.demo_pikachu)
                    .resizable()
                    .scaledToFit()
                    .circleWithBorderNShadow(width: size, height: size)
            }
        })
    }
}

struct DisplayNameView : View {
    @Binding var displayName: String
    
    var body: some View {
        TextField("Username", text: $displayName)
            .turnIntoTextFieldStyle()
    }
}

struct BirthdayPickerView : View {
    @EnvironmentObject var userSession: UserSessionModel
    
    @Binding var date: Date
    
    var body: some View {
        DatePicker("Birthday", selection: $date, displayedComponents: .date)
    }
}

struct GenderPickerView : View {
    @EnvironmentObject var userSession: UserSessionModel
    
    @Binding var gender: Gender
    
    var body: some View {
        Picker("Gender", selection: $gender, content: {
            ForEach(Gender.allCases, id: \.self) { gender in
                Text(gender.rawValue).tag("\( gender.rawValue )")
            }
        })
        .pickerStyle(SegmentedPickerStyle())
    }
}

struct SaveChangesView : View {
    @EnvironmentObject var userSession: UserSessionModel
    
    @Binding var displayName: String
    @Binding var birthday: Date
    @Binding var gender: Gender
    
    var body: some View {
        GeometryReader { geometry in
            Button(action: {
                userSession.userModel.saveBasicInfo(displayName: displayName, birthday: birthday, gender: gender)
            }, label: {
                Text("Save Changes")
                    .frame(width: geometry.size.width, height: 50)
                    .turnIntoButtonStyle(.green)
            })
        }
    }
}

struct ResetPasswordTriggerView : View {
    @EnvironmentObject var userSession: UserSessionModel
    
    @State private var isPresentingConfirm: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            Button(action: {
                isPresentingConfirm = true
            }, label: {
                Text("Reset Password")
                    .frame(width: geometry.size.width, height: 50)
                    .turnIntoButtonStyle(.red)
            })
        }
        .alert(isPresented: $isPresentingConfirm) {
            Alert(
                title: Text("Do you really want to reset the password?"),
                message: Text("This will send you an email to reset the password."),
                primaryButton: .cancel(Text("Cancel"), action: {
                    isPresentingConfirm = false
                }),
                secondaryButton: .destructive(Text("Reset"), action: {
                    userSession.resetPassword(completion: { result in
                        if result.status == true {
                            isPresentingConfirm = false
                        }
                    })
                })
            )
        }
    }
}

