//
//  WalletPKeyQRCodeViewModel.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/7/4.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class WalletPKeyQRCodeViewModel: KLRxViewModel {
    struct Input {
        let privateKey: String
    }
    
    typealias InputSource = Input
    typealias OutputSource = Void
    var input: WalletPKeyQRCodeViewModel.Input
    var output: Void
    var bag: DisposeBag = DisposeBag.init()
    
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
        concatInput()
        concatOutput()
    }
    
    func concatInput() {
        
    }
    
    func concatOutput() {
        
    }
    
    //MARK: - Public
    public var pKeyQRCode: Driver<UIImage?> {
        return Driver.just(input.privateKey).map {
            UIImage(ciImage:QRCodeGenerator.generateQRCode(from: $0)!)
        }
    }
    
}
