//
//  AccountSettingView.swift
//  ObjectDetection
//
//  Created by Joseph Ouyang on 2022/6/9.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import SwiftUI

struct AccountSettingView: View {
    @State var displayName = "Pikachu123"
    @State var date = Date()
    @State var gender = "Male"
    
    var body: some View {
        VStack{
            VStack{
                EditableImageView(size: 250)
                    .padding()
                DisplayNameView(displayName: $displayName)
                    .padding()
                BirthdayPickerView(date: $date)
                    .padding()
                GenderPickerView(gender: $gender)
                    .padding()
            }
            Spacer()
            GeometryReader() { geometry in
                VStack{
                    SaveChangesView()
                        .frame(width: geometry.size.width)
                    ResetPasswordTriggerView()
                        .frame(width: geometry.size.width)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
        .padding()
    }
}

struct AccountSettingView_Previews: PreviewProvider {
    static var previews: some View {
        AccountSettingView()
    }
}

struct EditableImageView : View {
    @State var size: CGFloat
    
    @State private var image = UIImage(named: "demo_cat")!
    @State private var showSheet = false
    
    var width: CGFloat {
        self.size
    }
    var height: CGFloat {
        self.size
    }
    
    var body: some View{
        
        ZStack{
            ZStack{
                Image(uiImage: image)
                    .resizable()
            }
            .circle(width: width, height: height)
            ZStack{
                VStack{
                    Spacer()
                    Text("Edit")
                        .font(.system(size: size * 0.1))
                        .frame(width: width, height: height * 0.2)
                        .background(Color.gray)
                        .foregroundColor(.white)
                }
                .frame(width: width, height: height)
            }
            .circle(width: width, height: height)
        }
        .onTapGesture(perform: {
            self.clicked()
        })
        .padding()
        .sheet(isPresented: $showSheet) {
            ImagePicker(selectedImage: $image)
        }
    }
    
    func clicked(callback: () -> Void = {}) {
        print("A")
        showSheet = true
    }
}

struct DisplayNameView : View {
    @Binding var displayName: String
    
    var body: some View {
        TextField("Username", text: $displayName)
    }
}

struct BirthdayPickerView : View {
    @Binding var date: Date
    
    var body: some View {
        DatePicker("Birthday", selection: $date, displayedComponents: .date)
    }
}

struct GenderPickerView : View {
    @Binding var gender: String
    
    var body: some View {
        Picker("Gender", selection: $gender, content: {
            Text("Male").tag("Male")
            Text("Female").tag("Female")
            Text("Neither").tag("Neither")
        })
        .pickerStyle(SegmentedPickerStyle())
    }
}

struct SaveChangesView : View {
    var body: some View {
        Button("Save Changes", action: {
            print("Save Changes")
        })
            .foregroundColor(.green)
            .padding()
    }
}

struct ResetPasswordTriggerView : View {
    var body: some View {
        Button("Reset Password", action: {
            print("Reset Password")
        })
            .foregroundColor(.red)
            .padding()
    }
}

extension ZStack {
    func circle(width: CGFloat, height: CGFloat) -> some View {
        let mn = min(width, height)
        return self.aspectRatio(contentMode: .fill)
            .frame(width: width, height: height)
            .clipped()
            .cornerRadius(mn)
    }
}
