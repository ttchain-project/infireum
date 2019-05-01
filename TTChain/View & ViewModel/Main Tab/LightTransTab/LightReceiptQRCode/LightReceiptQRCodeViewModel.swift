//
//  LightReceiptQRCodeViewModel.swift
//  TTChain
//
//  Created by Ajinkya Sharma on 2019/4/25.
//  Copyright © 2019 gib. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
class LightReceiptQRCodeViewModel:ViewModel {
    
    var input: LightReceiptQRCodeViewModel.Input
    
    var output: LightReceiptQRCodeViewModel.Output
    
    var bag:DisposeBag = DisposeBag.init()
    
    struct Input {
        let asset:Asset
    }
    
    struct Output {
        
    }
    
    required init(asset:Asset) {
        self.input = Input(asset: asset)
        self.output = Output()
        
    }
    
    lazy var selectedAsset: BehaviorRelay<Asset> = {
        return BehaviorRelay.init(value: input.asset)
    }()
    
    lazy var qrCode: BehaviorRelay<UIImage> = {
        let img = createQRCode(of: input.asset)
        return BehaviorRelay.init(value: img)
    }()
    
    private func createQRCode(of asset: Asset) -> UIImage {
        let source = createQRCodeContent(of: asset)
        return UIImage(ciImage:QRCodeGenerator.generateQRCode(from: source)!)
    }
    
    private func createQRCodeContent(of asset: Asset) -> String {
        return OWQRCodeEncoder().encodeContent(option: .deposit(asset: asset))
    }
}
