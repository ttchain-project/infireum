//
//  LocalIMUser.swift
//  OfflineWallet
//
//  Created by Ajinkya Sharma on 2018/10/24.
//  Copyright © 2018 gib. All rights reserved.
//

import Foundation
import UIKit

struct LocalIMUser: Codable {
    
    static let localKey: String = "localMember"

    var uID: String?
    var nickName:String
    var introduction: String
    var headImg: Data?
    
    
    static func createLocalIMUser(from imUser: IMUser) -> LocalIMUser {
        
        let imageData : Data? = (imUser.headImg != nil) ? UIImagePNGRepresentation(imUser.headImg!)! : nil
        return LocalIMUser(uID:imUser.uID, nickName:imUser.nickName ?? "", introduction: imUser.introduction ?? "", headImg:imageData)
    }
    
    func store()  throws {
        let encoder = JSONEncoder()
        //        encoder.dateEncodingStrategy = .iso8601
        do {
            let encoded = try encoder.encode(self)
            UserDefaults.standard.set(encoded, forKey: LocalIMUser.localKey)
        }catch let err {
            #if DEBUG
            fatalError(err.localizedDescription)
            #else
            throw err
            #endif
        }
    }
    
    static func clear() {
        if try! getFromLocal() != nil {
            UserDefaults.standard.set(nil, forKey: LocalIMUser.localKey)
        }
        else {
            UserDefaults.standard.set(nil, forKey: LocalIMUser.localKey)
        }
        
    }
    
    static func getFromLocal() throws -> IMUser? {
        let def = UserDefaults.standard
        let decoder = JSONDecoder.init()
        //        decoder.dateDecodingStrategy = .iso8601
        
        if let localData = def.data(forKey: localKey) {
            do {
                //                print(String.init(data: localData, encoding: .utf8))
                let member = try decoder.decode(LocalIMUser.self, from: localData)
                guard let uid = member.uID else {
                    return nil
                }
                return IMUser.init(uID: uid, nickName: member.nickName, introduction: member.introduction, headImg: nil)
            }catch let err {
                #if DEBUG
                fatalError(err.localizedDescription)
                #else
                throw err
                #endif
            }
        }else {
            return nil
        }
        
    }
}
