//
//  UserDataViewModel.swift
//  PokemonAR
//
//  Created by Joseph Ouyang on 2022/6/13.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import Foundation

import SwiftUI

import FirebaseFirestore
import FirebaseFirestoreSwift
    
class UserDataViewModel: ObservableObject {
    private let store = Firestore.firestore()
    var dbName = "userSaveData"
    private var listener: ListenerRegistration?
    
    @Published var userSession: UserSessionModel?
    
    @Published var userID = ""
    @Published var data = UserDataModel.empty {
        didSet {
            self.update()
            self.saveUserModel()
        }
    }
    
    @Published var level: Int = 1
    @Published var remainExperiencePercentage: CGFloat = 0
    
    func update() {
        objectWillChange.send()
        self.level = data.level
        self.remainExperiencePercentage = data.remainExperiencePercentage
    }
    
    func saveUserModel(){
        if self.userID.isEmpty == false {
            do {
                try store.collection(dbName).document(self.userID).setData(from: self.data)
            } catch {
                print(error)
            }
        }
    }
    
    func saveBasicInfo(
        displayName: String,
        birthday: Date,
        gender: Gender,
        completion: @escaping (CompletionResult) -> Void = { result in
        
        }
    ) {
        userSession!.userModel.data.birthday = birthday
        userSession!.userModel.data.gender = gender
        
        userSession!.saveUserBasicInfo(displayName: displayName, photoURL: .demo_pikachu, completion: { result in
            print("[UserDataViewModel] - saveBasicInfo - save displayName status : \(result.status)")
            print("[UserDataViewModel] - saveBasicInfo - save displayName message : \(result.message)")
            
            if result.status == true {
                self.userSession!.updateUser()
                completion(CompletionResult(status: true))
            } else {
                completion(result)
            }
        })
    }
    
    func fetch() {
        if userID.isEmpty == false {
            store.collection(dbName).document(self.userID).getDocument(completion: { snapshotRef, error in
                if let result = snapshotRef?.exists {
                    if result == true {
                        if let data = try! snapshotRef?.data(as: UserDataModel.self) {
                            self.data = data
                        }
                    }
                }
            })
        }
    }
    
    func updateUser(userID: String) {
        self.userID = userID
        
        if userID.isEmpty {
            stopListening()
            print("[UserDataViewModel] - Stop listening")
        } else {
            self.fetch()
            
            listenChange()
            print("[UserDataViewModel] - Start listening for \(userID) | \(dbName)")
        }
    }
    
    func retreiveUserdata(
        userID: String,
        onSuccess: @escaping (UserDataModel) -> Void = { userModel in
            
        },
        onFail: @escaping (UserDataModel) -> Void = { userModel in
            
        }
    ) -> UserDataModel{
        var userModel = UserDataModel(userID: userID)
        
        store.collection(dbName).whereField("userID", isEqualTo: userID).getDocuments { snapshot, error in
            guard let snapshot = snapshot else {
                print("Not found for user : \(userID)")
                onFail(userModel)
                return
            }
            guard let document = snapshot.documents.first else {
                print("Empty userSaveData")
                onFail(userModel)
                return
            }
            do {
                try userModel = document.data(as: UserDataModel.self)
                onSuccess(userModel)
            } catch {
                print("Serialize error \(error.localizedDescription)")
                onFail(userModel)
            }
        }
        
        return userModel
    }
    
    func listenChange() {
        print("[UserDataViewModel] - [listenChange] - Start listening changes")
        self.listener = store.collection(dbName).document(userID).addSnapshotListener { [self] snapshot, error in
            guard let _ = snapshot else { return }
            self.fetch()
        }
    }
    
    func stopListening() {
        self.listener?.remove()
        self.listener = nil
    }
}
