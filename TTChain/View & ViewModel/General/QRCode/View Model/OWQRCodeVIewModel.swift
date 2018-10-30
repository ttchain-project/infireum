//
//  OWQRCodeVIewModel.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/19.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OWQRCodeViewModel: KLRxViewModel {
    var bag: DisposeBag = DisposeBag.init()
    
    struct InputSource {
//        var defaultSourceTypes: [OWStringValidator.ValidationSourceType]
        var validationTypesSource: Driver<[OWStringValidator.ValidationSourceType]>
    }
    
    struct OutputSource {
        var validateResultHandler: (OWStringValidator.ValidationResultType) -> Void
    }
    
    var input: OWQRCodeViewModel.InputSource
    var output: OWQRCodeViewModel.OutputSource
    lazy var decoder: OWQRCodeDecoder = {
        return OWQRCodeDecoder.init(
            validator: OWStringValidator.init(sourceTypes: [])
        )
    }()
    
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
        
        concatInput()
        concatOutput()
        bindInternalLogic()
    }
    
    fileprivate lazy var strSource: PublishRelay<String> = {
        return PublishRelay.init()
    }()
    
    
    func concatInput() {
//        validator.sourceTypes = input.defaultSourceTypes
        input.validationTypesSource
            .drive(onNext: {
                [unowned self] in self.decoder.updateValidateTypes($0)
            })
            .disposed(by: bag)
    }
    
    private func bindInternalLogic() {
//        validationSourceTypes.asObservable().flatMap {
//            [unowned self]
//                types -> Observable<String> in
//                self.validator.sourceTypes = types
//                return self.strSource.asObservable()
//            }
        strSource
            .throttle(2, latest: false, scheduler: MainScheduler.instance)
            .flatMapLatest {
                [unowned self]
                source in
                self.decoder.decodeContent(raw: source)
            }
            .subscribe(onNext: {
                [unowned self]
                result in
                self.output.validateResultHandler(result)
            })
            .disposed(by: bag)
    }
    
    func concatOutput() {
        
    }
    
    func updateNewScannedSource(_ source: String) {
        strSource.accept(source)
    }
    
}
