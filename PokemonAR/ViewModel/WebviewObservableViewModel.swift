//
//  WebviewObservableViewModel.swift
//  PokemonAR
//
//  Created by Joseph Ouyang on 2022/6/17.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import Foundation

import Combine

import FirebaseFirestore
import FirebaseFirestoreSwift

class ObservableDecoder: ObservableObject {
    @Published var models = Dictionary<String, Any>()
    @Published var observableViewModel = ObservableViewModel()
    var sub: AnyCancellable?
    
    init() {
        sub = observableViewModel.objectWillChange.sink { [self] _ in
            self.objectWillChange.send()
        }
    }
    
    enum AvailableClass: String, Codable {
        case ObservableModel
    }
    
    struct DecodeObject: Decodable {
        let className: AvailableClass
        let object: String
        
        enum CodingKeys: String, CodingKey {
            case className = "className"
            case object = "object"
        }
        
        var json: Data {
            return object.data(using: .utf8)!
        }
        
        func decode<T: Decodable>() -> T {
            let decoder = JSONDecoder()
            do {
                let obj = try decoder.decode(T.self, from: self.json)
                return obj
            } catch {
                fatalError(String(describing: error))
            }
        }
    }
    
    func update(_ str: String) {
        let dObj = self.decodeAsDecodeObject(str)
        switch dObj.className {
        case .ObservableModel:
            let decoder = JSONDecoder()
            do {
                let obj = try decoder.decode(ObservableModel.self, from: dObj.json)
                observableViewModel.data = obj
            } catch {
                fatalError(String(describing: error))
            }
        }
        
        objectWillChange.send()
    }
    
    func decodeAsDecodeObject(_ str: String) -> DecodeObject {
        let json = str.data(using: .utf8)!

        let decoder = JSONDecoder()
        do {
            let decoded = try decoder.decode(DecodeObject.self, from: json)
            return decoded
        } catch {
            fatalError(String(describing: error))
        }
    }
}

class BattleModel {
    struct Command: Codable {
        var side: Bool
        var move: String
        var comment: String
        var damage: Int
    }

    struct AvailableInfos: Codable {
        var myHealth: Int = 100
        var enemyHealth: Int = 100
        var commands: [Command] = []
    }

    struct CurrentBattle: Codable {
        var myPokemon: Pokemon = Pokemon(pokedexId: 1)
        var enemyPokemon: Pokemon = Pokemon(pokedexId: 1)
        var availableInfos: AvailableInfos = AvailableInfos()
    }
}

struct ObservableModel: Codable {
    var battle: BattleModel.CurrentBattle = BattleModel.CurrentBattle()
    var roomID = UUID()
    var startUserID: String?
    var receiveUserID: String?
}

class ObservableViewModel: ObservableObject {
    private let store = Firestore.firestore()
    var dbName = "observableData"
    private var listener: ListenerRegistration?
    private var userID = ""
    @Published var didSetFromListener = false
    
    @Published var id = UUID()
    @Published var data: ObservableModel? {
        didSet {
            if !didSetFromListener {
                self.saveUserModel()
                self.update()
            } else {
                didSetFromListener = false
            }
        }
    }
    
    init() {
        if let session = UserSessionModel.session {
            if let _ = session.user {
                self.updateUser(userID: session.user?.uid ?? "")
            }
        }
    }
    
    func updateUser(userID: String) {
        self.userID = userID
        self.data = ObservableModel()
        
        self.deleteUserModel()
        self.fetch()
        self.data?.startUserID = userID
        self.forceSaveUserModel()
        
        listenChange()
        print("[ObservableViewModel] - Start listening for \(userID) | \(dbName)")
    }
    
    func updatePokemon(pokemon: Pokemon) {
        self.data?.battle.myPokemon = pokemon
        self.forceSaveUserModel()
        self.update()
    }
    
    func updateEnemyPokemon(userID: String? = nil, pokemon: Pokemon) {
        self.data?.battle.enemyPokemon = pokemon
        self.data?.receiveUserID = userID
        self.forceSaveUserModel()
        self.update()
    }
    
    func update() {
        objectWillChange.send()
    }
    
    func getBattleQuery(
        onStarter: @escaping (QuerySnapshot) -> Void = { querySnapshot in
        
        },
        onReceiver: @escaping (QuerySnapshot) -> Void = { querySnapshot in
            
        },
        onBoth: @escaping (QuerySnapshot) -> Void = { querySnapshot in
            
        }
    ) {
        guard !userID.isEmpty else {
            return
        }
        
        store.collection(dbName).whereField("startUserID", isEqualTo: userID).getDocuments { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                return
            }
            
            if !querySnapshot.isEmpty {
                onStarter(querySnapshot)
                onBoth(querySnapshot)
            }
        }
        
        store.collection(dbName).whereField("receiveUserID", isEqualTo: userID).getDocuments { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                return
            }
            
            if !querySnapshot.isEmpty {
                onReceiver(querySnapshot)
                onBoth(querySnapshot)
            }
        }
    }
    
    func forceSaveUserModel() {
        print("[ObservableViewModel] - forceSaveUserModel")
        print(userID)
        
        guard !userID.isEmpty else {
            return
        }
        
        do {
            try store.collection(dbName).document(id.uuidString).setData(from: self.data)
            print("[ObservableViewModel] - forceSaveUserModel saved")
        } catch {
            print(error)
        }
    }
    
    func saveUserModel() {
        print("[ObservableViewModel] - saveUserModel")
        
        if let data = self.data {
            self.getBattleQuery(onBoth: { querySnapshot in
                let snapshotRef = querySnapshot.documents.first
                
                if let snapshotRef = snapshotRef {
                    do {
                        try snapshotRef.reference.setData(from: data)
                        print("[ObservableViewModel] - saveUserModel saved")
                    } catch  {
                        print(error)
                    }
                }
            })
        }
    }
    
    func deleteUserModel() {
        print("[ObservableViewModel] - deleteUserModel")
        
        self.getBattleQuery(onBoth: { querySnapshot in
            for snapshotRef in querySnapshot.documents {
                snapshotRef.reference.delete()
                print("[ObservableViewModel] - deleteUserModel deleted")
            }
        })
    }
    
    func fetch() {
        print("[ObservableViewModel] - fetch")
        
        self.getBattleQuery(onBoth: { querySnapshot in
            let snapshotRef = querySnapshot.documents.first
            
            self.updateFromDocumentSnapshot(snapshotRef: snapshotRef)
            print("[ObservableViewModel] - fetched")
        })
    }
    
    func updateFromDocumentSnapshot(snapshotRef: DocumentSnapshot?) {
        guard let snapshotRef = snapshotRef else { return }
        
        if snapshotRef.exists {
            if let data = try? snapshotRef.data(as: ObservableModel.self) {
                self.data = data
                self.update()
                print(data)
            }
        }
    }
    
    func listenChange() {
        print("[ObservableViewModel] - [listenChange] - Start listening changes")
        
        if !userID.isEmpty{
            self.listener = store.collection(dbName).document(userID).addSnapshotListener(includeMetadataChanges: true) { [self] snapshot, error in
                self.didSetFromListener = true
                self.updateFromDocumentSnapshot(snapshotRef: snapshot)
            }
        }
    }
    
    func stopListening() {
        self.listener?.remove()
        self.listener = nil
    }
}
