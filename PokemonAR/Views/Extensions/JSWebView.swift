//
//  JSWebView.swift
//  PokemonAR
//
//  Created by Joseph Ouyang on 2022/6/17.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import Foundation

import Combine
import UIKit
import SwiftUI
import WebKit
import JavaScriptCore

struct JSWebViewDemoView: View {
    @State var view = JSWebView()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack{
                Color.blue
                view
                VStack {
                    ZStack {
                        Color.pokemonRed.ignoresSafeArea()
                        Text("Classic Battle")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                    }
                    .frame(height: geometry.size.height * 0.1)
                    Spacer()
                }
            }
        }
    }
}

struct Previews_JSWebView_Previews: PreviewProvider {
    static var previews: some View {
        JSWebViewDemoView()
    }
}

struct JSWebView: UIViewControllerRepresentable {
    @State var viewController = NAHomeViewController()
    
    func makeUIViewController(context: Context) -> NAHomeViewController {
        return self.viewController
    }
    
    func updateUIViewController(_ uiViewController: NAHomeViewController, context: Context) {
        
    }
    
    typealias UIViewControllerType = NAHomeViewController
}

class NAHomeViewController : UIViewController, WKNavigationDelegate, WKScriptMessageHandler, WKUIDelegate {
     
    var webView : WKWebView?
    var content : JSContext?
    @Published var observableDecoder = ObservableDecoder()
    var subs = [AnyCancellable]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subs.append(observableDecoder.objectWillChange.sink { [self] _ in
            self.syncBack()
        })
        
        // Create target
        let configuration = WKWebViewConfiguration()
        // Preference for WKWebViewController
        let preference = WKPreferences()
        configuration.preferences = preference
         
        // Allow communications between native and js
        preference.javaScriptEnabled = true
 
        // Initialize webView
        let aspectRatio = 1.5
        let height = self.view.frame.size.width * aspectRatio
        let webView = WKWebView.init(frame: CGRect(x: 0, y: (view.frame.size.height - height) * 0.5, width: self.view.frame.size.width, height: height))
        self.webView = webView
        
        let url = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "web")!
        webView.navigationDelegate = self
        webView.uiDelegate = self
        
        // register the bridge script that listens for the output
        self.addConsolelistener()
        self.addZoomDisable()
        webView.configuration.userContentController.add(self, name: "getMessage")
        webView.configuration.userContentController.add(self, name: "observableObject")
        
        webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        self.view.addSubview(webView)
         
//        let btn = UIButton.init(frame: CGRect(x: 100, y: 390, width: 100, height: 50))
//        btn.setTitleColor(.black, for: .normal)
//        btn.setTitle("iOS call js", for: .normal)
//        btn.addTarget(self, action: #selector(btnAction), for: .touchUpInside)
//        self.view.addSubview(btn)
    }
    
    func addConsolelistener() {
        // inject JS to capture console.log output and send to iOS
        let source = """
        function captureLog(obj) {
            window.webkit.messageHandlers.logHandler.postMessage(JSON.stringify(obj));
        }
        window.console.log = captureLog;
        function captureError(obj) {
            window.webkit.messageHandlers.errorHandler.postMessage(JSON.stringify(obj));
        }
        window.console.error = captureError;
        """
        let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        self.webView!.configuration.userContentController.addUserScript(script)
        
        // register the bridge script that listens for the output
        self.webView!.configuration.userContentController.add(self, name: "logHandler")
        self.webView!.configuration.userContentController.add(self, name: "errorHandler")
    }
    
    func addZoomDisable() {
        let source: String = """
            var meta = document.createElement('meta');
            meta.name = 'viewport';
            meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
            var head = document.getElementsByTagName('head')[0];
            head.appendChild(meta);
        """
        
        let script: WKUserScript = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        self.webView!.configuration.userContentController.addUserScript(script)
    }
    
    @objc func sendJSON(jsonStr: String) {
        self.webView?.evaluateJavaScript("receiver.sendJSON(\(jsonStr))", completionHandler: { (data, err) in
            print("\(String(describing: data)),\(String(describing: err))")
        })
    }
    
    @objc func sendObservableSync(jsonStr: String) {
        self.webView?.evaluateJavaScript("receiver.sendObservableSync(\(jsonStr))", completionHandler: { (data, err) in
            print("\(String(describing: data)),\(String(describing: err))")
        })
    }
    
    @objc func syncBack() {
        let encoder = JSONEncoder()
        do {
            let encoded = try encoder.encode(observableDecoder.observableViewModel.data)
            self.sendObservableSync(jsonStr: String(data: encoded, encoding: .utf8) ?? "")
        } catch {
            fatalError(String(describing: error))
        }
    }
     
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "logHandler" || message.name == "errorHandler" {
            let msg = "\(message.name) : \(message.body)"
            print(msg)
        } else {
            if message.name == "observableObject" {
                let str = "\(message.body)"
                
                observableDecoder.update(str)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
     
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        do {
            let url = Bundle.main.url(forResource: "processed_pokedex", withExtension: "json", subdirectory: "pokemon.json-master")!
            let text = try? String(contentsOf: url, encoding: .utf8)
            if let text = text {
                self.sendJSON(jsonStr: text)
            }
            
            observableDecoder.observableViewModel.data = ObservableModel()
            self.syncBack()
        } catch {
            fatalError(String(describing: error))
        }
    }
     
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("\(error)")
    }
     
     
    //MARK:WKUIDelegate
    //此方法作为js的alert方法接口的实现，默认弹出窗口应该只有提示消息，及一个确认按钮，当然可以添加更多按钮以及其他内容，但是并不会起到什么作用
    //点击确认按钮的相应事件，需要执行completionHandler，这样js才能继续执行
    ////参数 message为  js 方法 alert(<message>) 中的<message>
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertViewController = UIAlertController(title: "Alert", message:message, preferredStyle: UIAlertController.Style.alert)
        alertViewController.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: { (action) in
            completionHandler()
        }))
        self.present(alertViewController, animated: true, completion: nil)
    }
     
    // confirm
    //作为js中confirm接口的实现，需要有提示信息以及两个相应事件， 确认及取消，并且在completionHandler中回传相应结果，确认返回YES， 取消返回NO
    //参数 message为  js 方法 confirm(<message>) 中的<message>
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alertVicwController = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertController.Style.alert)
        alertVicwController.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { (alertAction) in
            completionHandler(false)
        }))
        alertVicwController.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: { (alertAction) in
            completionHandler(true)
        }))
        self.present(alertVicwController, animated: true, completion: nil)
    }
     
    // prompt
    //作为js中prompt接口的实现，默认需要有一个输入框一个按钮，点击确认按钮回传输入值
    //当然可以添加多个按钮以及多个输入框，不过completionHandler只有一个参数，如果有多个输入框，需要将多个输入框中的值通过某种方式拼接成一个字符串回传，js接收到之后再做处理
    //参数 prompt 为 prompt(<message>, <defaultValue>);中的<message>
    //参数defaultText 为 prompt(<message>, <defaultValue>);中的 <defaultValue>
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alertViewController = UIAlertController(title: prompt, message: "", preferredStyle: UIAlertController.Style.alert)
        alertViewController.addTextField { (textField) in
            textField.text = defaultText
        }
        alertViewController.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: { (alertAction) in
            completionHandler(alertViewController.textFields![0].text)
//            completionHandler("absadfasasd")
        }))

        self.present(alertViewController, animated: true, completion: nil)
    }
}
