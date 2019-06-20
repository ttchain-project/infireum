//
//  ImageDownloader.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/16.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import AlamofireImage
import Alamofire
import RxSwift

class KLRxImageDownloader {
    static let instance: KLRxImageDownloader = KLRxImageDownloader()
    private let downloader: ImageDownloader = ImageDownloader.init()
    
    private let bag = DisposeBag.init()
    
    func download(source: URL, onComplete: @escaping (APIResult<UIImage>) -> Void) {
        let single = RxAPIResponse<UIImage>.create {
            [unowned self]
            observer in
            let req = URLRequest.init(url: source)
            self.downloader.download(req, completion: { (res) in
                switch res.result {
                case .failure:
                    observer(.success(APIResult.failed(error: .noData)))
                case .success(let img):
                    observer(.success(APIResult.success(img)))
                }
            })
            
            return Disposables.create()
        }
        
        single.subscribe(onSuccess: { (result) in
            switch result {
            case .failed(error: let err): onComplete(.failed(error: err))
            case .success(let img): onComplete(.success(img))
            }
        }).disposed(by: bag)
    }
}



class FileDownloader {
    static let instance = FileDownloader.init()
    
    private let bag = DisposeBag.init()

    func download(source: URL, onComplete: @escaping (APIResult<Data>) -> Void) {
        let single = RxAPIResponse<Data>.create {
            observer in
            let req = URLRequest.init(url: source)
            let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
            
            Alamofire.download(req, to: destination).downloadProgress { (progress) in
                
                }.response { (response) in
                    let url = response.destinationURL
                    guard let file = try? Data.init(contentsOf: url!) else {
                        observer(.success(APIResult.failed(error: .noData)))
                        return
                    }
                    observer(.success(APIResult.success(file)))

            }
            return Disposables.create()
        }

        single.subscribe(onSuccess: { (result) in
            switch result {
            case .failed(error: let err): onComplete(.failed(error: err))
            case .success(let data): onComplete(.success(data))
            }
        }).disposed(by: bag)
    }
}
