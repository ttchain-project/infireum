//
//  UserQRCodeViewModel.swift
//  OfflineWallet
//
//  Created by Archie on 2018/11/13.
//  Copyright © 2018 gib. All rights reserved.
//

import RxSwift
import RxCocoa

final class UserQRCodeViewModel: KLRxViewModel {
    var bag: DisposeBag = DisposeBag()
    typealias InputSource = Input
    typealias OutputSource = Output

    struct Input {
        let uid:String
    }
    struct Output {
        let image = BehaviorRelay<UIImage?>(value: nil)
    }

    lazy var uID :BehaviorRelay<String?> = {
        return BehaviorRelay.init(value: self.input.uid)
    }()

    var input: UserQRCodeViewModel.Input
    var output: UserQRCodeViewModel.Output
    

    init(input: UserQRCodeViewModel.Input, output: UserQRCodeViewModel.Output) {
        self.input = input
        self.output = output
        concatInput()
        concatOutput()
    }
    
    func concatInput() {
        self.uID.map({ text -> UIImage? in
            guard let text = text else { return nil }
            let transform = CGAffineTransform(scaleX: 2, y: 2)
            guard let image = QRCodeGenerator.generateQRCode(from: text)?.transformed(by: transform) else {
                return nil
            }
            return UIImage.init(ciImage: image)
        }).bind(to: output.image).disposed(by: bag)
    }
    
    func concatOutput() {
        
    }
}
