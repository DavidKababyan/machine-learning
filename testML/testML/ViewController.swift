//
//  ViewController.swift
//  testML
//
//  Created by David Kababyan on 03/12/2017.
//  Copyright © 2017 David Kababyan. All rights reserved.
//

import UIKit
import AVKit
import Vision


class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet weak var observButtonOutlet: UIButton!
    @IBOutlet weak var resultLabe: UILabel!
    
    
    var captureSession: AVCaptureSession!
    var observing = false

    override func viewDidLoad() {
        super.viewDidLoad()

        captureSession = AVCaptureSession()
        setUpaCapture()

    
    }


    
    @IBAction func observButtonPressed(_ sender: Any) {
        
        observing = !observing
        
        if observing {
            observButtonOutlet.setTitle("Stop", for: .normal)
            startCapturing()
        } else {
            
            observButtonOutlet.setTitle("Obser", for: .normal)
            stopCapturing()
        }

    }
    
    func startCapturing() {
        captureSession.startRunning()
    }
    
    
    func stopCapturing() {
        captureSession.stopRunning()
    }
    
    
    func setUpaCapture() {
        
        captureSession.sessionPreset = .photo
        
        let captureDevice = AVCaptureDevice.default(for: .video)
        
        guard let input = try? AVCaptureDeviceInput(device: captureDevice!) else { return }
        
        captureSession.addInput(input)
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - 70)
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        
        captureSession.addOutput(dataOutput)
    }
    
    
    //MARK: AVCaptureVideoDataOutputSampleBufferDelegate
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        //        print("capured frame", Date())
        
        let cvPixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        
                guard let model = try? VNCoreMLModel(for: Resnet50().model) else { return }
        
                let request = VNCoreMLRequest(model: model) { (request, error) in
        
                    if error != nil {
                        print("error \(error!.localizedDescription)")
                        return
                    }
        
        
//                    print("request \(request.results)")
        
                    guard let result = request.results as? [VNClassificationObservation] else { return }
                    
                    
                    guard let firstObservation = result.first else { return }
                    
                    
                    DispatchQueue.main.async {
                        
                        let confidence = String(format: "%.2f", firstObservation.confidence * 100)
                        
                        self.resultLabe.text = "\(firstObservation.identifier, confidence)%"
                    }
                    
                }
        
        try? VNImageRequestHandler(cvPixelBuffer: cvPixelBuffer, options: [:]).perform([request])
    }


}

