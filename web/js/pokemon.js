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
}

class Pokemon {
  constructor(json) {
    this.json = json
  }

  info() {
    return PokeBattle.get_pokemon(this.json.pokedexId)
  }

  update(id, enemy=false) {
    var player = $(`#${id}`)
    var info = this.info();
    player.find(".pokemon")[0].setAttribute("href", enemy ? info.frontImage() : info.backImage());
    player.find(".hp-count")[0].innerHTML = "HP: " + this.hp
    player.find(".level")[0].innerHTML = "LVL " + this.level()
    player.find(".name")[0].innerHTML = info.info.name.english
  }

  level() {
    return Math.floor(this.json.experience / 100) + 1
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

class PokeBattle {
  pokedex = []
  message = null

  constructor(json, objRef) {
    this.pokedex = json
    this.objRef = objRef
    this.process_json()
  }

  update() {
    this.updateActions()
    this.myPokemon().update('myPokemon')
    this.enemyPokemon().update('enemyPokemon', true)
    this.message.innerHTML = "What should Blastoise do?"
  }

  process_json() {
    PokeBattle.pokemons = []
    this.pokedex.forEach((pokemonJson, i) => {
      PokeBattle.pokemons[i] = new PokemonRef(pokemonJson)
    })
  }

  static get_pokemon(id) {
    return PokeBattle.pokemons.find(pokemon => pokemon.id == id)
  }

  startGame() {
    this.message = $('#message')[0]
    this.update()
  }

  battle() {
    return this.objRef.object.battle
  }

  myPokemon() {
    var p = new Pokemon(this.battle().myPokemon)
    p.hp = this.battle().availableInfos.myHealth
    return p
  }

  enemyPokemon() {
    var p = new Pokemon(this.battle().enemyPokemon)
    p.hp = this.battle().availableInfos.enemyHealth
    return p
  }

  actions() {
    let actions = ['Water Cannon', 'Water Pulse', 'Surf', 'Tackle'];
    return actions
  }

  updateActions() {
    var wrapper = $('.actions')[0]
    wrapper.innerHTML = '';
    var actions = this.actions()

    actions.forEach( (action, index) => {
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
            <foreignObject font-size="50" width="365" height="115" x="10" y="10" alignment-baseline="text-before-edge">
              <p xmlns="http://www.w3.org/1999/xhtml" style="color:black; text-align: center;">${action}</p>
            </foreignObject>
          </switch>
        </a>
      </g>
      `
      wrapper.innerHTML += svg_str;
    })
  }

  excuteAction(index) {
    var actions = this.actions();
    var action = actions[index];
    console.log(`Excute action: ${action}`);
    this.battle().availableInfos.commands.push({
      'side': true,
      'move': action,
      'comment': '',
      'damage': 0,
    });
    receiver.sendObj(this.objRef)
  }
}

class Receiver {
  isInApp = false;
  json = []
  obj = new ObservableObject('ObservableModel', (obj) => {
      this.sendObj(obj)
  })

  constructor() {
    this.detectInApp();
  }

  detectInApp() {
    if ('webkit' in window) {
      this.isInApp = true
    } else {
      this.isInApp = false
      this.loadJSON(() => {
        this.game = new PokeBattle(this.json, this.obj)
      })
    }
  }

  loadJSON(callback) {
    var ref = this;
    function readTextFile(file) {
      var rawFile = new XMLHttpRequest();
      rawFile.open("GET", file, false);
      rawFile.onreadystatechange = function () {
        if (rawFile.readyState === 4) {
          if (rawFile.status === 200 || rawFile.status == 0) {
            var allText = rawFile.responseText;
            var json = JSON.parse(allText);

            ref.json = json;

            callback()
          }
        }
      }
      rawFile.send(null);
    }

    var pokedex_json_url = resources_path + "/sorted_pokedex.json"
    readTextFile(pokedex_json_url)
  }

  sendJSON(obj) {
    this.json = obj;
    this.game = new PokeBattle(this.json, this.obj);
    receiver.game.startGame()
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

  sendObservableSync(obj) {
    console.log(obj)
    this.obj.object = obj
    this.game.update()
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
  window.onresize()
  
  if (!receiver.isInApp) {
    receiver.game.startGame()
  }
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