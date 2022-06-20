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
        var roomID = UUID()
        var myPokemon: Pokemon = Pokemon(pokedexId: 1)
        var enemyPokemon: Pokemon = Pokemon(pokedexId: 2)
        var availableInfos: AvailableInfos = AvailableInfos()
    }
}

struct ObservableModel: Codable {
    var battle: BattleModel.CurrentBattle = BattleModel.CurrentBattle()
}

class ObservableViewModel: ObservableObject {
    private let store = Firestore.firestore()
    var dbName = "observableData"
    private var listener: ListenerRegistration?
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
        self.listenChange()
    }
    
    func update() {
        objectWillChange.send()
    }
    
    func saveUserModel(){
        do {
            if let data = self.data {
                try store.collection(dbName).document(self.id.uuidString).setData(from: data)
            }
        } catch {
            fatalError(String(describing: error))
        }
    }
    
    func fetch() {
        store.collection(dbName).document(self.id.uuidString).getDocument(completion: { snapshotRef, error in
            self.updateFromDocumentSnapshot(snapshotRef: snapshotRef)
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
        self.listener = store.collection(dbName).document(self.id.uuidString).addSnapshotListener(includeMetadataChanges: true) { [self] snapshot, error in
            
            self.didSetFromListener = true
            self.updateFromDocumentSnapshot(snapshotRef: snapshot)
        }
    }
    
    func stopListening() {
        self.listener?.remove()
        self.listener = nil
    }
}
