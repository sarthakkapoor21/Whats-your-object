//
//  CameraViewController.swift
//  Vision Dev
//
//  Created by Sarthak Kapoor on 06/10/17.
//  Copyright © 2017 SK21. All rights reserved.
//

import UIKit
import AVFoundation
import CoreML
import Vision

enum FlashState {
    case off
    case on
}
class CameraViewController: UIViewController {
    
    var captureSession: AVCaptureSession!
    var cameraOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var flashStatus: FlashState = .off
    
    var photoData: Data?
    
    var speechSynthesizer = AVSpeechSynthesizer()
    
    @IBOutlet weak var predictionLabel: UILabel!
    @IBOutlet weak var confidenceLabel: UILabel!
    @IBOutlet weak var imageClickedImageView: RoundShadowImage!
    @IBOutlet weak var flashButton: RoundShadowButton!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        previewLayer.frame = view.layer.bounds
        speechSynthesizer.delegate = self
        spinner.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSession.Preset.hd1920x1080
        
        let cameraTap = UITapGestureRecognizer(target: self, action: #selector(didTapCameraView))
        cameraTap.numberOfTapsRequired = 1
        
        let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            let input = try AVCaptureDeviceInput.init(device: backCamera!)
            
            if captureSession.canAddInput(input){
                captureSession.addInput(input)
            }
            
            cameraOutput = AVCapturePhotoOutput()
            
            if captureSession.canAddOutput(cameraOutput) {
                captureSession.addOutput(cameraOutput)
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer.videoGravity = AVLayerVideoGravity.resizeAspect
                previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                
                cameraView.layer.addSublayer(previewLayer)
                cameraView.addGestureRecognizer(cameraTap)
                captureSession.startRunning()
            }
        } catch {
            print(error.localizedDescription)
        }
    }

//    @objc func didTapCameraView() {
//
//        let cameraSettings = AVCapturePhotoSettings()
//        let previewPixelType = cameraSettings.availablePreviewPhotoPixelFormatTypes.first!
//        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType, kCVPixelBufferWidthKey as String: 160, kCVPixelBufferHeightKey: 160] as [AnyHashable : OSType]
//        cameraSettings.previewPhotoFormat = previewFormat as? [String : Any]
//
//        cameraOutput.capturePhoto(with: cameraSettings, delegate: self)
//    }
    
    @objc func didTapCameraView() {
        
        cameraView.isUserInteractionEnabled = false
        spinner.isHidden = false
        spinner.startAnimating()
        
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.__availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType, kCVPixelBufferWidthKey as String: 160, kCVPixelBufferHeightKey: 160] as [AnyHashable : NSNumber]
        
        settings.previewPhotoFormat = previewFormat as? [String : Any]
        
        if flashStatus == .off {
            settings.flashMode = .off
        } else {
            settings.flashMode = .on
        }
        
        cameraOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func results(request: VNRequest, error: Error?) {
        guard let results = request.results as? [VNClassificationObservation] else { return }
        
        var identification = ""
        var confidence = 0
        var speech = ""
        
        for classification in results {
            if classification.confidence < 0.0 {
                predictionLabel.text = "I'm not sure what this object is!"
                confidenceLabel.text = ""
            } else {
                if(Int(classification.confidence * 100) > confidence) {
                    
                    confidence = Int(classification.confidence * 100)
                    confidenceLabel.text = "Confidence: \(confidence)%"
                    
                    identification = "\(classification.identifier)"
                    predictionLabel.text = identification
                    
                    if (confidence < 30) {
                        speech = "I am not very sure about it. but. This looks like a \(identification)."
                    } else {
                        speech = "This looks like a \(identification). I am \(confidence) percent sure about it."
                    }
//                    synthesizeSpeech(fromString: speech)
                }
                
//                let speech = "This looks like a \(identification). I am \(confidence) percent sure about it."
//                synthesizeSpeech(fromString: speech)
//                break
            }
        }
        
        synthesizeSpeech(fromString: speech)
        
    }
    
    func synthesizeSpeech(fromString stringToSpeak: String) {
        
        let speechUtterance = AVSpeechUtterance(string: stringToSpeak)
        speechSynthesizer.speak(speechUtterance)
        
    }
    
    @IBAction func flashButtonTapped(_ sender: Any) {
        
        //        print("\n\n\n222\n\n\n")
        
        if flashStatus == .off {
            flashStatus = .on
            flashButton.setTitle("Flash On", for: .normal)
        } else {
            flashStatus = .off
            flashButton.setTitle("Flash Off", for: .normal)
        }
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        } else {
            photoData = photo.fileDataRepresentation()
            
            do {
                let model = try VNCoreMLModel(for: Inceptionv3().model)
                let request = VNCoreMLRequest(model: model, completionHandler: results)
                let handler = VNImageRequestHandler(data: photoData!)
                try handler.perform([request])
            } catch {
                print(error.localizedDescription)
            }
            
//            do {
//                let model = try VNCoreMLModel(for: SqueezeNet().model)
//                let request = VNCoreMLRequest(model: model, completionHandler: results)
//                let handler = VNImageRequestHandler(data: photoData!)
//                try handler.perform([request])
//            } catch {
//                print(error.localizedDescription)
//            }
            
            let image = UIImage(data: photoData!)
            self.imageClickedImageView.image = image
        }
    }
}

extension CameraViewController: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        
        spinner.stopAnimating()
        spinner.isHidden = true
        cameraView.isUserInteractionEnabled = true
        
    }
}

