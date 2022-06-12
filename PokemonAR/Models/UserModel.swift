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
    var userID = UserSessionModel().user!.uid
    var pokeBag: PokeBag
}
    
class UserModel: ObservableObject {
    private static let db = Firestore.firestore()
    static var dbName = "userSaveData"
    @Published var data: UserSaveModel?
    
//    static func save(pokeBag: PokeBag){
//        let _ = retreiveUserdata(
//            onSuccess: { userModel in
//                var userSaveModel = userModel
//                userSaveModel.pokeBag = pokeBag
//
//                do {
//                    try db.collection(dbName).document(userSaveModel.id!).setData(from: userSaveModel)
//                } catch {
//                    print(error)
//                }
//            }, onFail: { userModel in
//                var userSaveModel = userModel
//                userSaveModel.pokeBag = pokeBag
//
//                do {
//                    let documentReference = try db.collection(dbName).addDocument(from: userSaveModel)
//                    print(documentReference.documentID)
//                } catch {
//                    print(error)
//                }
//            }
//        )
//
//    }
    
    static func retreiveUserdata(
        user: User,
        onSuccess: @escaping (UserSaveModel) -> Void = { userModel in
            
        },
        onFail: @escaping (UserSaveModel) -> Void = { userModel in
            
        }
    ) -> UserSaveModel{
        var userModel = UserSaveModel(userID: user.uid, pokeBag: PokeBag())
        
        db.collection(dbName).whereField("userID", isEqualTo: user.uid).getDocuments { snapshot, error in
            guard let snapshot = snapshot else {
                onFail(userModel)
                return
            }
            guard let document = snapshot.documents.first else {
                onFail(userModel)
                return
            }
            do {
                try userModel = document.data(as: UserSaveModel.self)
                onSuccess(userModel)
            } catch {
                onFail(userModel)
            }
        }
        
        return userModel
    }
}
