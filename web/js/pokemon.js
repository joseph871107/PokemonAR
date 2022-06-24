var resources_path = "../pokemon.json-master"

class PokemonRef {
  constructor(json) {
    this.info = json
    this.id = json.id
  }
  
  image() {
    const zeroPad = (num, places) => String(num).padStart(places, '0')
    return `${resources_path}/sprites/${zeroPad(this.id, 3)}MS.png`
  }

  frontImage() {
    return `${resources_path}/Front${this.info.battle_sprite}`
  }

  backImage() {
    return `${resources_path}/${this.info.back_battle_sprite}`
  }

  name() {
    return this.info.name.english
  }
}

class Pokemon {
  remainedHp = 0
  id = 0
  wrapper = null

  constructor(json) {
    this.json = json
  }

  info() {
    return PokeBattle.get_pokemon(this.json.pokedexId)
  }

  update(id, enemy=false) {
    this.id = id;

    var info = this.info();
    var wrapper = $(`#${this.id}`);
    this.wrapper = wrapper;

    wrapper.find(".pokemon")[0].setAttribute("href", enemy ? info.frontImage() : info.backImage());
    wrapper.find(".level")[0].innerHTML = "LVL " + this.level()
    wrapper.find(".name")[0].innerHTML = info.name()
    this.updateHP()
  }

  updateHP() {
    var wrapper = this.wrapper;
    var hpDefaultWidth = wrapper.find(".hp-count").data('defaultwidth');
    var calculatedWidth = this.remainedHp / this.hp * hpDefaultWidth;
    wrapper.find(".hp-count").attr('width', calculatedWidth)
  }

  level() {
    return Math.floor(this.json.experience / 100) + 1
  }

  skills() {
    return this.json.learned_skills.map((skill) => {
      return PokeBattle.skillsManager.getSkillByID(skill.id)
    })
  }

  beenAttacked(delay = 0) {
    this.wrapper.find(".pokemon").velocity("callout.bounce", { duration: 1000, delay: delay });
  }

  hasDied(delay = 0) {
    this.wrapper.velocity("fadeOut", { duration: 1000, delay: delay });
  }
}

class ObservableObject {
  constructor(className, callback) {
    this.className = className
    this.sourceObject = {}
    this.callback = callback

    const handler = {
      get: (target, key) => {
        if(typeof target[key] === "object" && target[key] !== null) {
          return new Proxy(target[key], handler)
        }
    
        return target[key]
      },
      set: (target, prop, value) => {
        target[prop] = value

        this.callback(this.sourceObject)

        return true
      }
    }

    this.object = new Proxy(this.sourceObject, handler)
  }
}

class SkillsManager{
  constructor(skills) {
    this.skills = skills
  }

  getSkillByID(id) {
    return this.skills.find((element) => { return element.id == id });
  }
}

class PokeBattle {
  pokedex = []
  myPokemon = null
  enemyPokemon = null
  isFinished = false

  constructor(json, objRef) {
    this.pokedex = json
    this.objRef = objRef
    this.process_json()
  }

  update() {
    this.myPokemon = null
    this.enemyPokemon = null

    this.updateActions()
    this.getMyPokemon().update('myPokemon')
    this.getEnemyPokemon().update('enemyPokemon', true)
    this.updateMessage()
  }

  process_json() {
    PokeBattle.pokemons = [];
    this.pokedex.forEach((pokemonJson, i) => {
      PokeBattle.pokemons[i] = new PokemonRef(pokemonJson)
    })
  }

  static get_pokemon(id) {
    return PokeBattle.pokemons.find(pokemon => pokemon.id == id)
  }

  startGame() {
    $("#game_container").velocity("fadeIn", { duration: 500 });
    $("#loading_container").velocity("fadeOut", { duration: 500 });
    $("#game_container").removeClass("d-none");
    $("#loading_container").addClass("d-none");

    this.update()
  }

  battle() {
    return this.objRef.object.battle
  }

  getMyPokemon() {
    if (this.myPokemon == null) {
      var p = new Pokemon(this.battle().myPokemon)
      p.hp = this.battle().availableInfos.myHealth
      p.remainedHp = p.hp
      this.myPokemon = p
    }
    return this.myPokemon
  }

  getEnemyPokemon() {
    if (this.enemyPokemon == null) {
      var p = new Pokemon(this.battle().enemyPokemon)
      p.hp = this.battle().availableInfos.enemyHealth
      p.remainedHp = p.hp
      this.enemyPokemon = p
    }
    return this.enemyPokemon
  }

  message(message) {
    var wrapper = $('#message');

    var animClsName = "type";
    wrapper.removeClass(animClsName);
    wrapper.width();
    wrapper.html(message);
    wrapper.addClass(animClsName);

    return wrapper
  }

  updateMessage() {
    var defaultWelcomeMessage = this.message(`What should ${ this.getMyPokemon().info().name() } do?`);

    var commands = this.battle().availableInfos.commands;

    if (commands.length > 0) {
      this.processCommand(commands);

    } else {
      this.message(defaultWelcomeMessage);
    }
  }

  processCommand(commands, i=0) {
    if (i >= commands.length) {
      return
    }

    var command = commands[i];

    var currentMove = this.battle().availableInfos.currentMove;
    var enemy = this.getEnemyPokemon();
    var me = this.getMyPokemon();
    var message = "";


    var self=null;
    var target = null;
    if (command.side) {
      self = me;
      target = enemy;
    } else {
      self = enemy;
      target = me;
    }

    switch(command.type) {
      case 'requestSkill':
        break
      case 'confirmSkill':

        var action = PokeBattle.skillsManager.getSkillByID(command.skill)
        message = `${ self.info().name() } use ${ action.ename }.`;

        var willSet = target.remainedHp - command.damage;
        if (willSet > target.hp) {
          willSet = target.hp;
        }
        if (willSet < 0) {
          willSet = 0
        }
        target.remainedHp = willSet;

        if (i >= currentMove) {
          var isAttacking = true

          if (action.power != null && action.power > 0 && command.damage <= 0) {
            isAttacking = false
          }

          if (isAttacking) {
            target.beenAttacked(1000)
            setTimeout(() => {
              target.updateHP();
            }, 500);
          } else {
            message = `${ self.info().name() } have missed.`;
          }
        } else {
          target.updateHP()
        }

        break
      case 'finished':
        this.isFinished = true
        target.hasDied(1000);
        message = `${ self.info().name() } win!`;

        setTimeout(() => {
          this.onEnded();
        }, 2500);

        break
    }

    if (i < commands.length) {
      if (i >= currentMove) {

        setTimeout(() => {
          this.processCommand(commands, i + 1);
        }, 2000);
      } else {
        this.processCommand(commands, i + 1);
      }
      this.message(message);
    }
  }

  onEnded() {
    receiver.sendFinishBattle()
  }

  actions() {
    return this.getMyPokemon().skills()
  }

  updateActions() {
    var wrapper = $('.actions')[0]
    wrapper.innerHTML = '';
    var actions = this.actions()

    actions.forEach( (action, index) => {
      if (index < 4) {
        var row = Math.floor(index / 2);
        var col = index % 2;
        var x = 10 * (1 + col) + 385 * col;
        var y = 10 * (1 + row) + 135 * row;
  
        var func_name = `receiver.game.excuteAction(${index})`;
  
        let svg_str = `
        <g width="385" height="135" transform="translate(${x}, ${y})">
          <a onclick="${func_name}" type="button">
            <rect rx="20" ry="20" style="fill:rgb(255,128,16); stroke:black; stroke-width: 2;" width="385" height="135"></rect>
            <switch>
              <foreignObject font-size="30" width="365" height="115" x="10" y="10" alignment-baseline="text-before-edge">
                <p xmlns="http://www.w3.org/1999/xhtml" style="color:black; text-align: center;">${action.ename}</p>
                <div class="d-flex justify-content-between">
                <p xmlns="http://www.w3.org/1999/xhtml" style="color:black; text-align: center;">Power : ${action.power}</p>
                <p xmlns="http://www.w3.org/1999/xhtml" style="color:black; text-align: center;">Type : ${action.type}</p>
                </div>
              </foreignObject>
            </switch>
          </a>
        </g>
        `
        wrapper.innerHTML += svg_str;
      }
    })
  }

  excuteAction(index) {
    if (this.isFinished) {
      return
    }

    var battle = this.battle();
    var commands = battle.availableInfos.commands;
    var addable = true;

    console.log(`Excute action`);
    if (commands.length > 0) {
      if (commands[commands.length - 1].type == 'requestSkill') {
        addable = false
      }
    }

    if (addable) {
      var actions = this.actions();
      var action = actions[index];
      console.log(`Excute action: ${action.ename}`);
  
      this.objRef.object.battle.availableInfos.commands.push({
        'type': 'requestSkill',
        'side': true,
        'skill': action.id,
        "damage": 0,
      });
      console.log(this.objRef.object.battle.availableInfos.commands[this.objRef.object.battle.availableInfos.commands.length-1])
      this.objRef.object.battle.availableInfos.currentMove = this.objRef.object.battle.availableInfos.commands.length - 1;
      console.log(this.objRef)
      receiver.sendObj(this.objRef);
    }
  }

  registerSkills(skills) {
    PokeBattle.skillsManager = new SkillsManager(skills);
  }
}

class Receiver {
  isInApp = false;
  json = []
  obj = new ObservableObject('ObservableModel', (obj) => {
      this.sendObj(obj)
  })
  isStarter = true;

  constructor() {
    this.detectInApp();
  }

  detectInApp() {
    if ('webkit' in window) {
      this.isInApp = true
    } else {
      this.isInApp = false
      var pokedex_json_url = resources_path + "/processed_pokedex.json"
      this.loadJSON(pokedex_json_url, (json) => {
        this.json = json;

        this.receiveJSON(this.json, 'pokedex')

        var skills_json_url = resources_path + "/moves.json";
        this.loadJSON(skills_json_url, (skills_json) => {
          this.receiveJSON(skills_json, 'skills')

          var demoBattleJsonStr = `
          {
            "startUserID": "HBQ6NZnBFlZfIlq6wlYqqUskNHo1",
            "roomID": "EE9E3838-DF42-4878-87C4-CA827D700B77",
            "battle": {
              "availableInfos": {
                "currentMove": 4,
                "enemyHealth": 100,
                "commands": [
                  {
                    "type": "requestSkill",
                    "skill": 94,
                    "damage": 0,
                    "side": true
                  },
                  {
                    "type": "confirmSkill",
                    "skill": 94,
                    "damage": 80,
                    "side": true
                  },
                  {
                    "type": "confirmSkill",
                    "skill": 94,
                    "damage": 80,
                    "side": false
                  },
                  {
                    "type": "confirmSkill",
                    "skill": 94,
                    "damage": 0,
                    "side": true
                  },
                  {
                    "type": "confirmSkill",
                    "skill": 94,
                    "damage": 80,
                    "side": false
                  },
                  {
                    "type": "finished",
                    "skill": 0,
                    "damage": 0,
                    "side": false
                  }
                ],
                "myHealth": 100
              },
              "enemyPokemon": {
                "id": "6455F29C-F659-432E-9A52-A7359FA4CE84",
                "createDate": 677578500.050489,
                "pokedexId": 151,
                "displayName": "",
                "experience": 633,
                "learned_skills": [
                  {
                    "id": 94
                  },
                  {
                    "id": 85
                  },
                  {
                    "id": 58
                  },
                  {
                    "id": 411
                  }
                ]
              },
              "myPokemon": {
                "id": "C9ADC25B-785D-40C1-987B-3D4A3CD3C7AE",
                "createDate": 677479635.315804,
                "pokedexId": 150,
                "displayName": "A8CCA31D-4265-4077-BB83-C6CA35B1DD7F",
                "experience": 2673,
                "learned_skills": [
                  {
                    "id": 94
                  },
                  {
                    "id": 85
                  },
                  {
                    "id": 58
                  },
                  {
                    "id": 411
                  }
                ]
              }
            }
          }`
          var demoBattleJson = JSON.parse(demoBattleJsonStr);
          this.receiveObservableSync(demoBattleJson, true);

          this.game.startGame()
        })
      });
    }
  }

  loadJSON(file_name, callback) {
    var ref = this;
    function readTextFile(file) {
      var rawFile = new XMLHttpRequest();
      rawFile.open("GET", file, false);
      rawFile.onreadystatechange = function () {
        if (rawFile.readyState === 4) {
          if (rawFile.status === 200 || rawFile.status == 0) {
            var allText = rawFile.responseText;
            var json = JSON.parse(allText);

            callback(json)
          }
        }
      }
      rawFile.send(null);
    }

    readTextFile(file_name)
    return true
  }

  receiveJSON(obj, identifier) {
    switch (identifier) {
      case 'pokedex':
        this.json = obj;
        this.game = new PokeBattle(this.json, this.obj);
        break
      case 'skills':
        this.skills = obj;
        this.game.registerSkills(this.skills);
        break
    }
  }

  sendObj(obj) {
    if (this.isInApp) {
      window.webkit.messageHandlers.observableObject.postMessage(
        JSON.stringify(
          {
            key: obj.key,
            className: obj.className,
            object: JSON.stringify(obj.object),
          }
        )
      )
    }
  }

  sendFinishLoading() {
    if (this.isInApp) {
      window.webkit.messageHandlers.onFinishLoading.postMessage(true);
    }
  }

  sendFinishBattle() {
    if (this.isInApp) {
      window.webkit.messageHandlers.onFinishBattle.postMessage(true);
    }
  }

  receiveObservableSync(obj, isStarter) {
    if (!(JSON.stringify(this.obj.object) === JSON.stringify(obj))) {
      this.obj.object = obj
      this.isStarter = isStarter
      this.game.update()
    }
  }
}

window.onresize = () => {
  var width = window.innerWidth;
  var height = window.innerHeight;

  var desiredAspectRatio = 1.5;
  var aspectRatio = height / width;
  if (aspectRatio > desiredAspectRatio) {
    height = width * desiredAspectRatio;
  } else {
    width = height / desiredAspectRatio;
  }

  var body = document.getElementById("container");
  body.style.width = width + 'px';
  body.style.height = height + 'px';
}

var receiver = new Receiver();
window.onload = () => {
  console.log("Finished loading page")
  receiver.sendFinishLoading()
  window.onresize()
  
  if (!receiver.isInApp) {
    receiver.game.startGame()
  }
}

function pause(milliseconds) {
	var dt = new Date();
	while ((new Date()) - dt <= milliseconds) { /* Do nothing */ }
}

var meta = document.createElement('meta');
meta.name = 'viewport';
meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
var head = document.getElementsByTagName('head')[0];
head.appendChild(meta);

window.onscroll = () => {
  window.scroll(0, 0);
};
document.body.style.overflow = "hidden";
