////
////  CreateGroupViewModel.swift
////  OfflineWallet
////
////  Created by Song-Hua on 2018/10/24.
////  Copyright © 2018 gib. All rights reserved.
////
//
//import UIKit
//import RxSwift
//import RxCocoa
//
//class CreateGroupViewModel: KLRxViewModel {
//
//    struct Input {
//        var persons: Persons
//    }
//
//    struct Output {
//        var didSelectedAnyPerson: ([Person]) -> Void
//    }
//
//    var input: Input
//    var output: Output
//    var _filteredPersons: [Person] = []
//    var _selectedPersons: [Person] = []
//
//
//    required init(input: Input, output: Output) {
//        self.input = input
//        self._filteredPersons = input.persons.items
//        self.output = output
//    }
//
//    func concatInput() {
//
//    }
//
//
//    func concatOutput() {
//
//    }
//
//    lazy var filteredBehavior: BehaviorRelay<[Person]> = {
//        return BehaviorRelay.init(value: _filteredPersons)
//    }()
//
//    lazy var selectedBehavior: BehaviorRelay<[Person]> = {
//        return BehaviorRelay.init(value: _selectedPersons)
//    }()
//
//    var bag: DisposeBag = DisposeBag()
//
//
//    var persons: Observable<[Persons]> {
//        return Observable.just([input.persons])
//    }
//
//    func selected(index: Int) {
//
//        for person in _selectedPersons {
//            if person.name == input.persons.items[index].name {
//                return
//            }
//        }
//
//        _selectedPersons.append(input.persons.items[index])
//
//
//        var newSource = self.selectedBehavior.value
//        newSource.append(input.persons.items[index])
//        self.selectedBehavior.accept(newSource)
//
//        output.didSelectedAnyPerson(_selectedPersons)
//    }
//
//    func unselected(index: Int) {
//        let targetPerson = input.persons.items[index]
//        for (loopIndex, loopPerson) in _selectedPersons.enumerated() {
//            if targetPerson.name == loopPerson.name {
//
//                _selectedPersons.remove(at: loopIndex)
//
//                var newSource = self.selectedBehavior.value
//                newSource.remove(at: loopIndex)
//                self.selectedBehavior.accept(newSource)
//
//
//                output.didSelectedAnyPerson(_selectedPersons)
//
//                return
//            }
//        }
//    }
//
//    func isSelected(person: Person) -> Bool {
//        print("found \(String(describing: person.name))")
//        for selectedPerson in _selectedPersons {
//            if selectedPerson.name == person.name {
//                return true
//            }
//        }
//
//        return false
//    }
//
//    func removeSelect(at index: NSInteger) {
//        _selectedPersons.remove(at: index)
//
//        var selectedBehavior2 = self.selectedBehavior.value
//        selectedBehavior2.remove(at: index)
//        self.selectedBehavior.accept(selectedBehavior2)
//
////        self.filteredBehavior.accept(self.filteredBehavior.value)
//    }
//}
