//
//  TransferMultiSelectDataSource.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/10.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol RxMultiSelectSourceManageable {
    associatedtype Source: Sequence where Source.Iterator.Element: Equatable
    var sources: Observable<Source> { get }
    var selectedSources: Observable<Source> { get }
    func getSources() -> Source
    func getSelectedSources() -> Source
    func refreshSource(source: Source)
    func select(source: Source)
    func deselect(source: Source)
}

extension RxMultiSelectSourceManageable {
    func isSelected(sourceElemenet: Source.Iterator.Element) -> Bool {
        return getSelectedSources().contains(sourceElemenet)
    }
}

protocol RxSingleSelectSourceManageable {
    associatedtype Source: Equatable
    var sources: Observable<[Source]> { get }
    var selectedSource: Observable<Source?> { get }
    func getSources() -> [Source]
    func getSelectedSource() -> Source?
    func refreshSource(sources: [Source])
    func select(source: Source)
    func deselect()
}

extension RxSingleSelectSourceManageable {
    func isSelected(source: Source) -> Bool {
        return getSelectedSource() == source
    }
}

class MultiSelectRxDataSourceManager<S: Equatable>: RxMultiSelectSourceManageable {
    typealias Source = [S]
    var sources: Observable<[S]> { return _sources.asObservable() }
    private lazy var _sources: BehaviorRelay<[S]> = {
        return BehaviorRelay.init(value: [])
    }()
    
    var selectedSources: Observable<[S]> { return _selectedSources.asObservable().distinctUntilChanged() }
    private lazy var _selectedSources: BehaviorRelay<[S]> = {
        return BehaviorRelay.init(value: [])
    }()
    
    init(defaultSources: [S]) {
        refreshSource(source: defaultSources)
    }
    
    func getSources() -> [S] {
        return _sources.value
    }
    
    func getSelectedSources() -> [S] {
        return _selectedSources.value
    }
    
    func refreshSource(source: [S]) {
        _selectedSources.accept(source)
    }
    
    func select(source: [S]) {
        var newSource = _selectedSources.value
        for s in source where !newSource.contains(s) {
            newSource.append(s)
        }
        
        _selectedSources.accept(newSource)
    }
    
    func select(sourceIdx: Int) {
        if sourceIdx < _sources.value.count {
            select(source: [_sources.value[sourceIdx]])
        }
    }
    
    func deselect(source: [S]) {
        var newSource = _selectedSources.value
        for s in source {
            if let idx = newSource.index(of: s) {
                newSource.remove(at: idx)
            }
        }
        _selectedSources.accept(newSource)
    }
    
    func deselect(sourceIdx: Int) {
        if sourceIdx < _sources.value.count {
            deselect(source: [_sources.value[sourceIdx]])
        }
    }
    
    func clearSelections() {
        _selectedSources.accept([])
    }
}

class SingleSelectRxDataSourceManager<S: Equatable>: RxSingleSelectSourceManageable {
    typealias Source = S
    
    var sources: Observable<[S]> {
        return _source.asObservable()
    }
    
    private lazy var _source: BehaviorRelay<[S]> = {
       return BehaviorRelay.init(value: [])
    }()
    
    var selectedSource: Observable<S?> {
        return _selectedSource.asObservable().distinctUntilChanged()
    }
    
    private lazy var _selectedSource: BehaviorRelay<S?> = {
       return BehaviorRelay.init(value: nil)
    }()
    
    init(defaultSources: [S]) {
        refreshSource(sources: defaultSources)
    }
    
    func getSources() -> [S] {
        return _source.value
    }
    
    func getSelectedSource() -> S? {
        return _selectedSource.value
    }
    
    func refreshSource(sources: [S]) {
        _source.accept(sources)
    }
    
    func select(source: S) {
        _selectedSource.accept(source)
    }
    
    func select(sourceIdx: Int) {
        if sourceIdx < _source.value.count {
            select(source: _source.value[sourceIdx])
        }
    }
    
    func deselect() {
        _selectedSource.accept(nil)
    }
}

class SingleCancellableSelectRxDataSourceManager<S: Equatable>: SingleSelectRxDataSourceManager<S> {
    override func select(source: S) {
        if source == self.getSelectedSource() {
            deselect()
        }else {
            super.select(source: source)
        }
    }
    
    override func select(sourceIdx: Int) {
        if getSources()[sourceIdx] == self.getSelectedSource() {
            deselect()
        }else {
            super.select(sourceIdx: sourceIdx)
        }
    }
}
