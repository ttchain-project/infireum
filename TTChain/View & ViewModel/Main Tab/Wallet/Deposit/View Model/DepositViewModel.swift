//
//  DepositViewModel.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/24.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class DepositViewModel: KLRxViewModel {
    struct Input {
        let wallet: Wallet
        let asset: Asset
        let selectAssetInput: Driver<Asset>
    }
    
    typealias InputSource = Input
    var input: DepositViewModel.Input
    
    typealias OutputSource = Void
    var output: Void
    
    var bag: DisposeBag = DisposeBag.init()
    
    lazy var selectedAsset: BehaviorRelay<Asset> = {
        return BehaviorRelay.init(value: input.asset)
    }()
    
    lazy var qrCode: BehaviorRelay<UIImage> = {
        let img = createQRCode(of: input.asset)
        return BehaviorRelay.init(value: img)
    }()
    
    required init(input: InputSource, output: OutputSource) {
        self.input = input
        self.output = output
        self.concatInput()
        self.concatOutput()
        bindInternalLogic()
    }
    
    func concatInput() {
        input.selectAssetInput
        .drive(selectedAsset)
        .disposed(by: bag)
    }
    
    func concatOutput() {
        
    }
    
    private func bindInternalLogic() {
        selectedAsset.map {
            [unowned self] in self.createQRCode(of: $0)
        }
        .bind(to: qrCode)
        .disposed(by: bag)
    }
    
    //MARK: - Helper
    
    private func createQRCode(of asset: Asset) -> UIImage {
        let source = createQRCodeContent(of: asset, fromWallet: input.wallet)
        return UIImage(ciImage:QRCodeGenerator.generateQRCode(from: source)!)
    }
    
    private func createQRCodeContent(of asset: Asset, fromWallet wallet: Wallet) -> String {
        return OWQRCodeEncoder().encodeContent(option: .deposit(asset: asset))
    }
}
