//
//  NSManagedObject+IdentifiablePredication.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/14.
//  Copyright © 2018年 gib. All rights reserved.
//

import Foundation
import CoreData
enum IdentifierUnit {
    case str(keyPath: String, value: String)
    case num(keyPath: String, value: Int16)
    case date(keyPath: String, value: NSDate)
}

struct ManagedObejctConstructor<E: KLIdentifiableManagedObject> {
    var idUnits: [IdentifierUnit]
    var setup: (E) -> Void
}

protocol KLIdentifiableManagedObject: Hashable {
    //Must specify
    static var idenifierKeys: [String] { get }
    static var defaultConstrutors: [ManagedObejctConstructor<Self>] { get }
    
    // Has implemented in extension
    static func createIdentifiers(from source: [Any]) -> [IdentifierUnit]
    static func createPredicate(from source: Any...) -> NSCompoundPredicate
    func isIdentical(to units: [IdentifierUnit]) -> Bool
    /// Predefined creator
    @discardableResult static func createDefaultEntities() -> [Self]?
    /// Dynamic creator
    @discardableResult static func syncEntities(constructors: [ManagedObejctConstructor<Self>], returnNewEntitiesOnly: Bool) -> [Self]?
}

extension KLIdentifiableManagedObject where Self: NSObject {
    func isIdentical(to units: [IdentifierUnit]) -> Bool {
        for unit in units {
            switch unit {
            case .num(keyPath: let key, value: let intVal):
                guard let selfValue = value(forKeyPath: key),
                    let selfInt = selfValue as? Int16,
                    selfInt == intVal else { return false }
                
            case .str(keyPath: let key, value: let strVal):
                guard let selfValue = value(forKeyPath: key),
                    let selfStr = selfValue as? String,
                    selfStr == strVal else {
                        return false
                }
            case .date(keyPath: let key, value: let dateVal):
                guard let selfValue = value(forKeyPath: key),
                    let selfDate = selfValue as? NSDate,
                    (selfDate as Date) == (dateVal as Date) else {
                        return false
                }
            }
        
        }
        
        return true
    }
    
    var hashValue: Int {
        var hash: Int = 0
        for key in Self.idenifierKeys {
            let v = value(forKeyPath: key)
            if let num = v as? Int16 {
                hash += num.hashValue
            }else if let str = v as? String {
                hash += str.hashValue
            }
        }
        
        if hash == 0 {
            #if DEBUG
            fatalError()
            #else
            return Int(arc4random())
            #endif
        }else {
            return hash
        }
    }
    
    static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
}

extension KLIdentifiableManagedObject {
    static func createIdentifiers(from source: [Any]) -> [IdentifierUnit] {
        let keys = idenifierKeys
        guard source.count == keys.count else {
            return errorDebug(response: [])
        }
        
        var units: [IdentifierUnit] = []
        for i in 0..<source.count {
            let value = source[i]
            let key = keys[i]
            if let intVal = value as? Int16 {
                units.append(.num(keyPath: key, value: intVal))
            }else if let strVal = value as? String {
                units.append(.str(keyPath: key, value: strVal))
            }else {
                warning("Found undesired type of source while createIdentifiers(from source: Any...), key: \(key), value: \(value)")
                return errorDebug(response: [])
            }
        }
        
        return units
    }
    
    static func createPredicate(from source: Any...) -> NSCompoundPredicate {
        let predicates = createIdentifiers(from: source).map {
            unit in
            return genPredicate(fromIdentifierType: unit)
        }
        
        return NSCompoundPredicate.init(andPredicateWithSubpredicates: predicates)
    }
    
    static func genPredicate(fromIdentifierType idType: IdentifierUnit) -> NSPredicate {
        switch idType {
        case .num(keyPath: let k, value: let n):
            return NSPredicate.init(format: "%K = %i", k, n)
        case .str(keyPath: let k, value: let s):
            return NSPredicate.init(format: "%K = %@", k, s)
        case .date(keyPath: let k, value: let d):
            return NSPredicate.init(format: "%K = %@", k, d)
        }
    }
    
    
}

extension KLIdentifiableManagedObject where Self: NSManagedObject {
    @discardableResult static func createDefaultEntities() -> [Self]? {
        return syncEntities(constructors: defaultConstrutors)
    }
    
    @discardableResult static func syncEntities(constructors: [ManagedObejctConstructor<Self>], returnNewEntitiesOnly: Bool = false) -> [Self]? {
        guard !constructors.isEmpty else { return [] }
        
        var newDatas: [Self] = []
        if let localDatas = DB.instance.get(type: self, predicate: nil, sorts: nil),
            !localDatas.isEmpty {
            var _localDatas = localDatas
            for constructor in constructors {
                if let sameEntityIdx = _localDatas.index(where: {
                    $0.isIdentical(to: constructor.idUnits)
                }) {
                    let sameEntity = _localDatas.remove(at: sameEntityIdx)
                    constructor.setup(sameEntity)
                    //Move the updated entity from old to new array list.
                    newDatas.append(sameEntity)
                }else {
                    if let newEntity = DB.instance.create(
                        type: self,
                        setup: constructor.setup,
                        saveImmediately: false
                    ) {
                        newDatas.append(newEntity)
                    }else {
                        warning("Failed to create new entity of \(self) while constuctors()")
                    }
                }
            }
            
            if !DB.instance.update() {
                warning("Failed to save data while constuctors() of \(self)")
                return nil
            }
            
            if returnNewEntitiesOnly { return newDatas }
            else { return _localDatas + newDatas }
        }else {
            let setups = constructors.map { $0.setup }
            return DB.instance.batchCreate(type: self, setups: setups)
        }
    }
}
