//无参数函数
function testA() {
    alert("I'm from JS" + pokedex);
}

//有参数函数
function testB(value) {
    alert(value);
    console.log(value)
    return pokedex
}

function testC(value) {
    return value + "value";
}

//接受iOS端传过来的参数，
function testObject(name) {
    var object = {name:name};
    return object;
}

function testInput(value) {
    var result = prompt('abc', value)
    console.error(result)
    return result
}

function testConfirm() {
    confirm("R U sure?")
}

function buttonAction(){
    try {
        //  js 向iOS 传递数据
        window.webkit.messageHandlers.getMessage.postMessage("Send message to Swift")
    }catch (e) {
        console.error(e)
    }
}