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
    @Published var observableViewModel = BattleViewModel()
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
        print("[ObservableDecoder] - updating for data : \( str )")
        let dObj = self.decodeAsDecodeObject(str)
        switch dObj.className {
        case .ObservableModel:
            let decoder = JSONDecoder()
            do {
                var obj = try decoder.decode(BattleMainModel.self, from: dObj.json)
                
                obj = self.processCommands(obj)
                if let receiveUserID = self.observableViewModel.data?.receiveUserID {
                    print("[ObservableDecoder] - receiveUserID : \( receiveUserID )")
                    if receiveUserID == "computer" {
                        obj = self.computerProcessCommands(obj)
                    }
                }
                
                observableViewModel.data = obj
                observableViewModel.saveUserModel()
            } catch {
                fatalError(String(describing: error))
            }
        }
    }
    
    func processCommands(_ obj: BattleMainModel) -> BattleMainModel {
        var obj = obj
        print(obj.battle.availableInfos.commands)
        
        print("[ObservableDecoder] - processCommands - Start processing commands")
        let side = (obj.startUserID == self.observableViewModel.userID)
        
        let commands = obj.battle.availableInfos.commands
        print(commands)
        
        if commands.count > 0 {
            let latestCommand = commands.last!
            print(latestCommand)
            
            var myPokemon = obj.battle.myPokemon
            var enemyPokemon = obj.battle.enemyPokemon
            
            if latestCommand.side {
                myPokemon = obj.battle.myPokemon
                enemyPokemon = obj.battle.enemyPokemon
            } else {
                myPokemon = obj.battle.enemyPokemon
                enemyPokemon = obj.battle.myPokemon
            }
            
            switch(latestCommand.type) {
            case .requestSkill:
                if latestCommand.side == side {
                    let skillID = latestCommand.skill
                    let skill = PokemonSkillSingleton.findSkill(skillID)
                    
                    obj.battle.availableInfos.commands.append(BattleInfoModel.Command(
                        type: .confirmSkill,
                        side: side,
                        skill: skillID,
                        damage: myPokemon.damage(skill: skill, on: enemyPokemon)
                    ))
                }
                break
            case .confirmSkill:
                break
            case .finished:
                break
            }
        }
        
        obj = self.checkForFinish(obj)
        
        print(obj.battle.availableInfos.commands)
        return obj
    }
    
    func computerProcessCommands(_ obj: BattleMainModel) -> BattleMainModel {
        var obj = obj
        print(obj.battle.availableInfos.commands)
        
        print("[ObservableDecoder] - computerProcessCommands - Start processing commands")
        
        let commands = obj.battle.availableInfos.commands
        print(commands)
        
        let myPokemon = obj.battle.myPokemon
        let enemyPokemon = obj.battle.enemyPokemon
        
        if commands.count > 0 {
            let latestCommand = commands.last!
            print(latestCommand)
            
            switch(latestCommand.type) {
            case .requestSkill:
                break
            case .confirmSkill:
                if latestCommand.side == true {
                    let skill = (enemyPokemon.learned_skills[randomPick: 1].first!).info
                    let skillID = skill.id
                    
                    obj.battle.availableInfos.commands.append(BattleInfoModel.Command(
                        type: .confirmSkill,
                        side: false,
                        skill: skillID,
                        damage: enemyPokemon.damage(skill: skill, on: myPokemon)
                    ))
                }
                break
            case .finished:
                break
            }
        }
        
        obj = self.checkForFinish(obj)
        
        print(obj.battle.availableInfos.commands)
        return obj
    }
    
    func checkForFinish(_ obj: BattleMainModel) -> BattleMainModel {
        var obj = obj
        print(obj.battle.availableInfos.commands)
        
        print("[ObservableDecoder - checkForFinish - Start processing commands")
        
        var isFinished = false
        var myHP = obj.battle.availableInfos.myHealth
        var enemyHP = obj.battle.availableInfos.enemyHealth
        var winSide = true
        
        let commands = obj.battle.availableInfos.commands
            
        for command in commands {
            switch(command.type) {
            case .requestSkill:
                break
            case .confirmSkill:
                let damage = command.damage
                if command.side {
                    enemyHP = enemyHP - damage
                } else {
                    myHP = myHP - damage
                }
                
                break
            case .finished:
                return obj
            }
        }
        
        print("[ObservableDecoder - checkForFinish myHP : \( myHP )")
        print("[ObservableDecoder - checkForFinish enemyHP : \( enemyHP )")
        
        if myHP <= 0 {
            isFinished = true
            winSide = false
            print("[ObservableDecoder - enemy win")
        }
        
        if enemyHP <= 0 {
            isFinished = true
            winSide = true
            print("[ObservableDecoder - I win")
        }
        
        if isFinished {
            obj.battle.availableInfos.commands.append(BattleInfoModel.Command(
                type: .finished,
                side: winSide,
                skill: 0,
                damage: 0
            ))
        }
        
        print(obj.battle.availableInfos.commands)
        return obj
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

class BattleInfoModel {
    enum CommandType: String, Codable {
        case requestSkill
        case confirmSkill
        case finished
    }
    
    struct Command: Codable, Hashable {
        var type: CommandType
        var side: Bool
        var skill: Int
        var damage: Int
    }

    struct AvailableInfos: Codable, Hashable {
        var myHealth: Int = 100
        var enemyHealth: Int = 100
        var currentMove: Int = 0
        var commands: [Command] = []
    }

    struct CurrentBattle: Codable, Hashable {
        var myPokemon: Pokemon = Pokemon(pokedexId: 1)
        var enemyPokemon: Pokemon = Pokemon(pokedexId: 1)
        var availableInfos: AvailableInfos = AvailableInfos()
        
        func summary(win: Bool, pokeBag: PokeBagViewModel) -> String {
            var output = [String]()
            
            if let session = UserSessionModel.session {
                let enemyLevel = self.enemyPokemon.level
                var userReceiveExperience: Int = Int(ceil(Double(enemyLevel) * Double(0.75)))
                var pokemonReceiveExperience: Int = Int(ceil(Double(enemyLevel) * Double(0.5)))
                
                session.userModel.data.experience += userReceiveExperience
                if var pokemon = pokeBag.pokemons.first(where: { $0.id == self.myPokemon.id }) {
                    pokemon.experience += pokemonReceiveExperience
                    pokeBag.modifyPokemon(pokemon: pokemon)
                }
                
                if !win {
                    pokemonReceiveExperience = Int(Double(pokemonReceiveExperience) * Double(0.1))
                    userReceiveExperience = Int(Double(userReceiveExperience) * Double(0.1))
                }
                
                output.append("User experiences : +\( userReceiveExperience )")
                output.append("Pokemon experiences : +\( pokemonReceiveExperience )")
            }
            
            return output.joined(separator: "\n")
        }
    }
}

struct BattleMainModel: Codable {
    var battle: BattleInfoModel.CurrentBattle = BattleInfoModel.CurrentBattle()
    var roomID = UUID()
    var startUserID: String?
    var receiveUserID: String?
}

class BattleViewModel: ObservableObject {
    private let store = Firestore.firestore()
    var dbName = "observableData"
    private var listener: ListenerRegistration?
    @Published var userID = ""
    @Published var didSetFromListener = false
    
    @Published var data: BattleMainModel? {
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
        self.initialization()
    }
    
    func initialization() {
        print("[ObservableViewModel] - initialization")
        if let session = UserSessionModel.session {
            if let user = session.currentUser {
                self.updateUser(userID: user.uid)
            }
        }
    }
    
    func updateUser(userID: String) {
        self.stopListening()
        
        self.userID = userID
        self.getBattleQuery(onStarter: { querySnapshot in
            for document in querySnapshot.documents {
                document.reference.delete()
            }
        })
        didSetFromListener = true
        self.data = BattleMainModel()
        didSetFromListener = false
        
        self.data?.startUserID = userID
        print("[ObservableViewModel] - reset data")
        
        listenChange()
        print("[ObservableViewModel] - Start listening for \(userID) | \(dbName)")
    }
    
    func updatePokemon(pokemon: Pokemon) {
        self.data?.battle.myPokemon = pokemon
        self.data?.battle.availableInfos.myHealth = pokemon.info.base.HP
        self.saveUserModel()
    }
    
    func updateEnemyPokemon(userID: String? = nil, pokemon: Pokemon, computer: Bool = false) {
        self.data?.battle.enemyPokemon = pokemon
        self.data?.battle.availableInfos.enemyHealth = pokemon.info.base.HP
        self.data?.receiveUserID = userID
        
        print(computer, pokemon)
        if computer {
            self.data?.receiveUserID = "computer"
        }
        
        self.saveUserModel()
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
            
        },
        onNone: @escaping () -> Void = {
            
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
                return
            }
        }
        
        store.collection(dbName).whereField("receiveUserID", isEqualTo: userID).getDocuments { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                return
            }
            
            if !querySnapshot.isEmpty {
                onReceiver(querySnapshot)
                onBoth(querySnapshot)
                return
            }
        }
        
        onNone()
    }
    
    func forceSaveUserModel() {
        print("[ObservableViewModel] - forceSaveUserModel")
        print(userID)
        
        guard !userID.isEmpty else {
            return
        }
        
        do {
            try store.collection(dbName).document(userID).setData(from: self.data)
            print("[ObservableViewModel] - forceSaveUserModel saved")
        } catch {
            print(error)
        }
    }
    
    func saveUserModel() {
        print("[ObservableViewModel] - saveUserModel")
        
        if let myData = self.data {
            self.getBattleQuery(
                onBoth: { querySnapshot in
                    let snapshotRef = querySnapshot.documents.first
                    
                    if let snapshotRef = snapshotRef {
                        do {
                            try snapshotRef.reference.setData(from: myData)
                            print("[ObservableViewModel] - saveUserModel saved")
                        } catch  {
                            print(error)
                        }
                    }
                },
                onNone: {
                    self.forceSaveUserModel()
                }
            )
        }
    }
    
    func deleteUserModel() {
        print("[ObservableViewModel] - deleteUserModel")
        
        self.stopListening()
        self.getBattleQuery(onBoth: { querySnapshot in
            for snapshotRef in querySnapshot.documents {
                snapshotRef.reference.delete()
                self.didSetFromListener = true
                self.data = BattleMainModel()
                self.data?.startUserID = self.userID
                self.didSetFromListener = false
                print("[ObservableViewModel] - deleteUserModel deleted")
            }
        })
    }
    
    func updateFromDocumentSnapshot(snapshotRef: DocumentSnapshot?) {
        guard let snapshotRef = snapshotRef else { return }
        
        if snapshotRef.exists {
            if let data = try? snapshotRef.data(as: BattleMainModel.self) {
                self.didSetFromListener = true
                self.data = data
                self.update()
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
