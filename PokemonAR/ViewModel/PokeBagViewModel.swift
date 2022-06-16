//
//  PokeBagViewModel.swift
//  PokemonAR
//
//  Created by Joseph Ouyang on 2022/6/13.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import Foundation

import FirebaseFirestore
import FirebaseFirestoreSwift

class PokeBagViewModel: ObservableObject {
    private let store = Firestore.firestore()
    private var dbName: String {
        if userID.isEmpty {
            fatalError("User not exist")
        } else {
            return "pokeBag_\(userID)"
        }
    }
    private var listener: ListenerRegistration?
    
    @Published var userID = ""
    @Published var pokemons = [Pokemon]() {
        didSet {
//            print("[PokeBagViewModel] - pokemons changed \(String(describing: pokemons))")
//            print("[PokeBagViewModel] - current number of pokemons : \(pokemons.count)")
            self.objectWillChange.send()
        }
    }
    
    func updateUser(userID: String) {
        self.userID = userID
        
        // Fetch all pokemons first to avoid 'Fatal error: each layout item may only occur once'
        // Because not every item update quick enough, so load them at once, then open up the listener
        store.collection(dbName).getDocuments(completion: { snapshotRef, error in
            self.pokemons = snapshotRef?.documents.map({ document in
                try! document.data(as: Pokemon.self)
            }) ?? []
            self.pokemons = self.pokemons.sorted(by: { $0.createDate > $1.createDate })
        })
        
        listenChange()
        print("[PokeBagViewModel] - Start listening for \(userID) | \(dbName)")
    }
    
    func modifyPokemon(pokemon: Pokemon) {
        do {
            try store.collection(dbName).document(pokemon.id.uuidString).setData(from: pokemon)
        } catch  {
            print(error)
        }
    }
    
    func addPokemon(pokemon: Pokemon) {
        do {
            _ = try store.collection(dbName).addDocument(from: pokemon)
        } catch {
            print(error)
        }
    }
    
    func deletePokemon(pokemon: Pokemon) {
        let _: Void = store.collection(dbName).whereField("id", isEqualTo: pokemon.id.uuidString).getDocuments { (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                for document in querySnapshot.documents {
                    document.reference.delete()
                }
            }
        }
    }
    
    func listenChange() {
        print("[listenChange] - Start listening changes")
        self.listener = store.collection(dbName).addSnapshotListener { snapshot, error in
//            DispatchQueue.main.async {
                guard let snapshot = snapshot else { return }
                snapshot.documentChanges.forEach { documentChange in
                    switch documentChange.type {
                    case .added:
//                        print("[listenChange] - added")
                        guard let targetPokemon = try? documentChange.document.data(as: Pokemon.self) else {
                            print(error as Any)
                            break
                        }
                        let index = self.pokemons.firstIndex { pokemon in
                            pokemon.id == targetPokemon.id
                        }
                        // If not exist then add into array, since there exist load all before listen
                        // So the listener initial added could be ignored.
                        if let _ = index {
                            
                        } else {
                            self.pokemons.append(targetPokemon)
                            self.pokemons = self.pokemons.sorted(by: { $0.createDate > $1.createDate })
                        }
                    case .modified:
//                        print("[listenChange] - modified")
                        guard let targetPokemon = try? documentChange.document.data(as: Pokemon.self) else {
                            print(error as Any)
                            break
                        }
                        let index = self.pokemons.firstIndex { pokemon in
                            pokemon.id == targetPokemon.id
                        }
                        if let index = index {
                            self.pokemons[index] = targetPokemon
                        }
                    case .removed:
//                        print("[listenChange] - removed")
                        guard let targetPokemon = try? documentChange.document.data(as: Pokemon.self) else {
                            print(error as Any)
                            break
                        }
                        let index = self.pokemons.firstIndex { pokemon in
                            pokemon.id == targetPokemon.id
                        }
                        if let index = index {
                            self.pokemons.remove(at: index)
                            self.pokemons = self.pokemons.sorted(by: { $0.createDate > $1.createDate })
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
    
    func addDemoWithRandomName() {
        let _pokemons = Pokedex.pokedex.pokemons
        for i in _pokemons.indices {
            let pokemon = _pokemons[i]
            
            self.addPokemon(
                pokemon: Pokemon(
                    pokedexId: pokemon.id,
                    experience: Int.random(
                        in: 0..<5000
                    ),
                    displayName: Bool.random() ? UUID().uuidString : ""
                )
            )
        }
    }
    
    func addDemo() {
        let _pokemons = Pokedex.pokedex.pokemons
        for i in _pokemons.indices {
            let pokemon = _pokemons[i]
            
            self.addPokemon(
                pokemon: Pokemon(
                    pokedexId: pokemon.id,
                    experience: Int.random(
                        in: 0..<5000
                    )
                )
            )
        }
    }
    
    func removeAll() {
        let _pokemons = pokemons
        for i in _pokemons.indices {
            let pokemon = _pokemons[i]
            
            self.deletePokemon(pokemon: pokemon)
        }
    }
}
