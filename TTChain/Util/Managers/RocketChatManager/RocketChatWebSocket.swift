////
////  RocketChatsssss.swift
////  OfflineWallet
////
////  Created by Song-Hua on 2018/10/29.
////  Copyright © 2018 gib. All rights reserved.
////
//
//import UIKit
//import Starscream
//
////extension String {
////
////    func sha256() -> String{
////        if let stringData = self.data(using: String.Encoding.utf8) {
////            return hexStringFromData(input: digest(input: stringData as NSData))
////        }
////        return ""
////    }
////
////    private func digest(input : NSData) -> NSData {
////        let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
////        var hash = [UInt8](repeating: 0, count: digestLength)
////        CC_SHA256(input.bytes, UInt32(input.length), &hash)
////        return NSData(bytes: hash, length: digestLength)
////    }
////
////    private  func hexStringFromData(input: NSData) -> String {
////        var bytes = [UInt8](repeating: 0, count: input.length)
////        input.getBytes(&bytes, length: input.length)
////
////        var hexString = ""
////        for byte in bytes {
////            hexString += String(format:"%02x", UInt8(byte))
////        }
////
////        return hexString
////    }
////
////}
//
//@objc protocol RocketChatWebSocketDelegate: NSObjectProtocol {
//    @objc optional func rocketChatWebSocketDidConnect(socket: RocketChatWebSocket)
//    @objc optional func rocketChatWebSocketDidDisconnect(socket: RocketChatWebSocket, error: NSError?)
//    @objc optional func rocketChatWebSocketDidReceiveMessage(socket: RocketChatWebSocket, text: String)
//    @objc optional func rocketChatWebSocketDidReceiveData(socket: RocketChatWebSocket, data: NSData)
////    @objc optional func rocketChatWebSocketDidReceive(socket: RocketChatWebSocket, response: RocketChatResponse)
//}
//
//class RocketChatWebSocket: NSObject, WebSocketDelegate {
//
//
//    var socket: WebSocket!
//    var isFirstMessage: Bool = false
//    weak var delegate: RocketChatWebSocketDelegate? = nil
//    var tokenId: String = ""
//    var session: String = ""
//    var server_id: String = ""
//
//
//    class func shared() -> RocketChatWebSocket {
//        return manger
//    }
//
//    static let manger: RocketChatWebSocket = {
//        return RocketChatWebSocket()
//    }()
//
//    //MARK:- 链接服务器
//    func connectServer() {
//        let URLString = "ws://192.168.51.21:3000/websocket"
//        //        let URLString = "wss://open.rocket.chat/websocket"
//        //        let URLString = "ws://192.168.0.205:3000/websocket"
//
//        guard let url = URL.init(string: URLString) else {
//            print("無效的 URL: \(URLString)")
//            return
//        }
//
//        print("[WebSocket] Try to connect: \(url)")
//
//        socket = WebSocket(url: url)
//        socket.delegate = self
////        socket.ss
//        socket.connect()
//    }
//
//    func disconnect() {
//        socket.disconnect()
//    }
//
//    func jsonToData(jsonDic: Dictionary<String, Any>) -> Data? {
//        if (!JSONSerialization.isValidJSONObject(jsonDic)) {
//            print("Is not a valid json object")
//            return nil
//        }
//
//        return try? JSONSerialization.data(withJSONObject: jsonDic, options: [])
//    }
//
//
//
//    public func send(string: String) {
//        var dictionary = RocketChatDictionary()
//        dictionary.method = "sendMessage"
//        dictionary.msg = string
//        dictionary.id = "42"
//        dictionary.session = session
//        dictionary.params = [RocketChatDictionaryParams()]
//        dictionary.params?[0].rid = "4"
//        dictionary.params?[0].msg = string
//        dictionary.params?[0]._id = ""
//
//        socket.write(string: string)
//    }
//
//    public func registerNewUser(email: String, name: String, password: String) {
//        var dictionary = RocketChatDictionary()
//        dictionary.msg = "method"
//        dictionary.method = "registerUser"
//        dictionary.session = session
//        dictionary.id = server_id
//        dictionary.params = [RocketChatDictionaryParams()]
//        dictionary.params?[0].email = email
//        dictionary.params?[0].name = name
//        dictionary.params?[0].username = name
//        dictionary.params?[0].pass = password
//
//        if let data = dictionary.toData() {
//            socket.write(data: data)
//        }
//    }
//
//    public func login(email: String, password: String) {
//        var dictionary = RocketChatDictionary()
//        dictionary.msg = "method"
//        dictionary.method = "login"
////        dictionary.session = session
//        dictionary.id = "42"
//        dictionary.params = [RocketChatDictionaryParams()]
////        dictionary.params?[0].email = "songla003@mail.com"
////        dictionary.params?[0].name = "SongHua"
////        dictionary.params?[0].pass = "aaaa1324"
//        dictionary.params?[0].user?.username = "SongHua5"
//        dictionary.params?[0].password?.digest = "aaaa1324".sha256()
//        dictionary.params?[0].password?.algorithm = "sha-256"
//
//
//        print("aaaa1324".sha256())
//
//        if let data = dictionary.toData() {
//            socket.write(data: data)
//        }
//    }
//
//    public func login2(email: String, password: String) {
//
//        let pp: String = "{            \"msg\": \"method\",            \"method\": \"login\",            \"id\":\"42\",            \"params\":[            {            \"user\": { \"username\": \"SongHua5\" },            \"password\": {            \"digest\": \"\("aaaa1324".sha256())\",            \"algorithm\":\"sha-256\"            }            }            ]        }"
//
//        socket.write(string: pp)
//    }
//
//    public func ooioi() {
//        let pp: String = "{\"msg\": \"method\",        \"method\": \"loadHistory\",        \"id\": \"42\",        \"params\": [ \"room-id\", null, 50  ]    }"
//
//        socket.write(string: pp)
//    }
//
//
//    func sendDictionary(_ dictionary: RocketChatDictionary) {
//        if let data = dictionary.toData() {
//            socket.write(data: data)
//        }
//    }
//
//    // Delegate
//    func websocketDidConnect(socket: WebSocketClient) {
//        print("[WebSocket] Did Cconnect")
//
//        if isFirstMessage != true {
//            isFirstMessage = true
//
//            var dict = RocketChatDictionary()
//            dict.msg = "connect"
//            dict.version = "1"
////            dict.session = session
//            dict.support = ["1"]
//
//            if let data = dict.toData() {
//                socket.write(data: data)
//            }
//        }
//    }
//
//    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
//        print("[WebSocket] Did Disconnect, error: \(String(describing: error))")
//
//        isFirstMessage = false
//
////        delegate?.rocketChatWebSocketDidConnect!(socket: socket as! RocketChatWebSocket)
//    }
//
//    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
//        print("[WebSocket] Rece Message: \(text)")
//
////        let json = JSON(value)
////        let responseDictionary = json.dictionaryValue as? [String: AnyObject]
////        let addOnRes = RocketChatDictionary.init()
//
//
//
//        if let jsonData = text.data(using: String.Encoding.utf8) {
//            let jsonDecoder = JSONDecoder()
//            jsonDecoder.dateDecodingStrategy = .iso8601
//
//            do {
//                let response = try jsonDecoder.decode(RocketChatDictionary.self, from: jsonData)
////                let response = try jsonDecoder.decode(RocketChatDictionary.self, from: jsonData)
//
//                if false {
//                } else if response.msg == "connected" {
//                    if let session = response.session {
//                        self.session = session
//                    }
//                } else if response.msg == "ping" {
//                    var dictionary = RocketChatDictionary(msg: "pong")
//                    dictionary.session = session
//
//                    if let data = dictionary.toData() {
//                        socket.write(data: data)
//                    }
//                } else {
//                    if response.msg == "error" || response.error != nil {
////                        if let data = response.error?.toData() {
////                            let string = data.string(encoding: String.Encoding.utf8)
////                            print("[WebSocket] Get Error: \(string)")
////                        } else {
////                            print("[WebSocket] Get Error: \(response.error)")
////                        }
//                    }
//                }
//            } catch {
//                print("轉換失敗: \(text)")
//            }
//        }
//    }
//
//    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
//        print("[WebSocket] Rece Data: \(data)")
//    }
//}
//
//
//struct RocketChatDictionary: Codable {
//    var msg: String?
//    var method: String?
//    var id: String?
//    var params: [RocketChatDictionaryParams]?
//    var version: String?
//    var support: [String]?
//    var reason: String?
//    var session: String?
//    var error: RocketChatDictionaryError?
//
//    init() {
//        self.support = []
//        self.params = [RocketChatDictionaryParams()]
//    }
//
//    init(msg: String) {
//        self.init()
//        self.msg = msg
//    }
//
//    func toData() -> Data? {
//        return try? JSONEncoder().encode(self)
//    }
//}
//
//struct RocketChatDictionaryParams: Codable {
//    var _id: String
//    var rid: String
//    var msg: String
//    var name: String
//    var username: String
//    var email: String
//    var pass: String
//    var user: RocketChatDictionaryUser?
//    var password: RocketChatDictionaryPassword?
//
//    init() {
//        self._id = ""
//        self.rid = ""
//        self.msg = ""
//        self.name = ""
//        self.email = ""
//        self.pass = ""
//        self.username = ""
//    }
//
//    init(id: String, rid: String, msg: String) {
//        self.init()
//        self._id = id
//        self.rid = rid
//        self.msg = msg
//    }
//}
//
//struct RocketChatDictionaryUser: Codable {
//    var username: String
//
//    init() {
//        self.username = ""
//    }
//}
//
//struct RocketChatDictionaryPassword: Codable {
//    var digest: String
//    var algorithm: String
//
//    init() {
//        self.digest = ""
//        self.algorithm = ""
//    }
//}
//
//struct RocketChatDictionaryError: Codable {
//    var errorType: String
//    var message: String
//    var reason: String
//    var error: Int
//    var isClientSafe: Bool
//
//    init() {
//        self.errorType = ""
//        self.message = ""
//        self.reason = ""
//        self.error = 0
//        self.isClientSafe = false
//    }
//
//    func toData() -> Data? {
//        return try? JSONEncoder().encode(self)
//    }
//}
//
//
//
