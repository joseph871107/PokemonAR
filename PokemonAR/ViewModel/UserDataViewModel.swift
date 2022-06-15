//
//  UserDataViewModel.swift
//  PokemonAR
//
//  Created by Joseph Ouyang on 2022/6/13.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import Foundation

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
            self.save()
        }
    }
    
    func save(){
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
        gender: Gender
    ) {
        userSession!.userModel.data.birthday = birthday
        userSession!.userModel.data.gender = gender
        
        userSession!.saveUserBasicInfo(displayName: displayName, photoURL: .demo_pikachu, completion: { result in
            print("[UserDataViewModel] - saveBasicInfo - save displayName status : \(result.status)")
            print("[UserDataViewModel] - saveBasicInfo - save displayName message : \(result.message)")
            
            if result.status == true {
                self.userSession!.updateUser()
            }
        })
    }
    
    func updateUser(userID: String) {
        self.userID = userID
        
        if userID.isEmpty {
            stopListening()
            print("[UserDataViewModel] - Stop listening")
        } else {
            store.collection(dbName).document(self.userID).getDocument(completion: { snapshotRef, error in
                if let data = try! snapshotRef?.data(as: UserDataModel.self) {
                    self.data = data
                }
            })
            
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
        self.listener = store.collection(dbName).addSnapshotListener { [self] snapshot, error in
//            DispatchQueue.main.async {
                guard let snapshot = snapshot else { return }
                snapshot.documentChanges.forEach { documentChange in
                    switch documentChange.type {
                    case .added:
//                        print("[listenChange] - added")
                        guard let targetChange = try? documentChange.document.data(as: UserDataModel.self) else {
                            print(error as Any)
                            break
                        }
                        if self.userID == targetChange.userID {
                            self.data = targetChange
                        }
                    case .modified:
//                        print("[listenChange] - modified")
                        guard let targetChange = try? documentChange.document.data(as: UserDataModel.self) else {
                            print(error as Any)
                            break
                        }
                        if self.userID == targetChange.userID {
                            self.data = targetChange
                        }
                    case .removed:
//                        print("[listenChange] - removed")
                        guard let targetChange = try? documentChange.document.data(as: UserDataModel.self) else {
                            print(error as Any)
                            break
                        }
                        if self.userID == targetChange.userID {
                            self.data = .empty
                            self.userID = ""
                        }
                    }
                }
//            }
        }
    }
    
    func stopListening() {
        self.listener?.remove()
        self.listener = nil
    }
}
