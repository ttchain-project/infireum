//
//  OWQRCodeBaseViewController.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/19.
//  Copyright © 2018年 gib. All rights reserved.
//

import UIKit
import AVFoundation
import RxSwift

class OWQRCodeBaseViewController: KLModuleViewController, Rx {
    
    var bag: DisposeBag = DisposeBag.init()
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    var darkTransparentLayer: CAShapeLayer!
    fileprivate var validSquareLength: CGFloat {
        let screen = UIScreen.main
        return screen.bounds.width * 0.6
    }
    
    internal var validRect: CGRect {
        var rect = CGRect.init(origin: .zero, size: CGSize.init(width: validSquareLength, height: validSquareLength))
        let center = view.center
        let origin = CGPoint.init(x: center.x - (validSquareLength * 0.5), y: center.y - (validSquareLength * 0.5))
        rect.origin = origin
        
        return rect
    }
    
    //Added to support different barcodes
    let supportedBarCodes = [AVMetadataObject.ObjectType.qr]
    fileprivate var configed: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startMonitorThemeIfNeeded()
        startMonitorLangIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !configed {
            checkAVAuthorization()
            configed = true
        }
    }
    
    
    
    func checkAVAuthorization() {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        
        switch status {
        case .authorized:
            configureScannerSetting()
        default:
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted) in
                if granted {
                    self.configureScannerSetting()
                } else {
                    return
                }
            })
        }
    }
    
    func configureScannerSetting() {
        DispatchQueue.main.async {
            let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)!
            
            do {
                // Initialize the captureSession object.
                self.captureSession = AVCaptureSession()
                
                // Get an instance of the AVCaptureDeviceInput class using the previous device object.
                let input = try AVCaptureDeviceInput(device: captureDevice)
                // Initialize a AVCaptureMetadataOutput object
                let captureMetadataOutput = AVCaptureMetadataOutput()
                
                // Set the input device on the capture session.
                self.captureSession?.addInput(input)
                // Set the output metadata as the output device to the capture session.
                self.captureSession?
                    .addOutput(captureMetadataOutput)
                
                // Set delegate and use the default dispatch queue to execute the call back
                captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                
                // Detect all the supported bar code
                captureMetadataOutput.metadataObjectTypes = self.supportedBarCodes
                
                self.configureLayout()
                
            } catch {
                print("QRCode scanner error: \(error)")
                return
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if let layer = self.videoPreviewLayer {
            if layer.frame != self.view.layer.bounds {
                self.videoPreviewLayer?.frame = self.view.layer.bounds
            }
        }
    }
    
    func configureLayout() {
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession!)
        self.videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.videoPreviewLayer?.frame = self.view.layer.bounds
        self.view.layer.insertSublayer(self.videoPreviewLayer!, at: 0)
        
        self.captureSession?.startRunning()
        
        self.darkTransparentLayer = CAShapeLayer.init()
        let path = UIBezierPath.init(rect: self.view.bounds)
        let validSquare = UIBezierPath.init(roundedRect: self.validRect, cornerRadius: 5)
        path.append(validSquare)
        
        self.darkTransparentLayer.path = path.cgPath
        //To determine the filling rule.
        self.darkTransparentLayer.fillRule = kCAFillRuleEvenOdd
        self.darkTransparentLayer.opacity = 0.6
        
        self.view.layer.insertSublayer(self.darkTransparentLayer, above: self.videoPreviewLayer!)
    }
    
    func findQRCode(content: String) {
        warning("Please override findQRCode(content: String) in the subclass to implement the behavior")
    }
}

extension OWQRCodeBaseViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard !metadataObjects.isEmpty else {
            return
        }
        
        if let metadataObject = metadataObjects[0] as? AVMetadataMachineReadableCodeObject {
            if supportedBarCodes.contains(metadataObject.type) {
                guard let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObject),
                    let str = metadataObject.stringValue else {
                    return
                }
                
                let bounds = barCodeObject.bounds
                if validRect.contains(bounds) {
                    findQRCode(content: str)
                }
            }
        }
    }
}

