//
//  UserModel.swift
//  PokemonAR
//
//  Created by Joseph Ouyang on 2022/6/13.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import Foundation

import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

struct UserSaveModel: Codable, Identifiable {
    @DocumentID var id: String?
    var userID: String?
}
    
class UserModel: ObservableObject {
    private static let db = Firestore.firestore()
    static var dbName = "userSaveData"
    @Published var data: UserSaveModel?
    
    static func save(userSaveModel: UserSaveModel){
        guard let userID = UserSessionModel.session?.user?.uid else { return }
        do {
            try db.collection(dbName).document(userID).setData(from: userSaveModel)
        } catch {
            print(error)
        }
    }
    
    static func retreiveUserdata(
        userID: String,
        onSuccess: @escaping (UserSaveModel) -> Void = { userModel in
            
        },
        onFail: @escaping (UserSaveModel) -> Void = { userModel in
            
        }
    ) -> UserSaveModel{
        var userModel = UserSaveModel(userID: userID)
        
        db.collection(dbName).whereField("userID", isEqualTo: userID).getDocuments { snapshot, error in
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
                try userModel = document.data(as: UserSaveModel.self)
                onSuccess(userModel)
            } catch {
                print("Serialize error \(error.localizedDescription)")
                onFail(userModel)
            }
        }
        
        return userModel
    }
}
