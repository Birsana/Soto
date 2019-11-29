//
//  CameraViewController.swift
//  GalleryShare
//
//  Created by Andre Birsan on 2019-11-27.
//  Copyright © 2019 Andre Birsan. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    let captureSession = AVCaptureSession()
    var previewLayer: CALayer!
    var captureDevice: AVCaptureDevice!
    var takePhoto = false
    
    var counter = 1
    
    
    var photosTaken = [UIImage]()
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    func createButtons(){
        let captureButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100 , height: 100))
        captureButton.backgroundColor = UIColor.clear
        captureButton.center = self.view.center
        captureButton.layer.cornerRadius = 0.5 * captureButton.bounds.size.width
        captureButton.clipsToBounds = true
        captureButton.layer.borderWidth = 1
        captureButton.layer.borderColor = UIColor.white.cgColor
        captureButton.addTarget(self, action: #selector(capturePic(sender:)), for: .touchUpInside)
        
        let switchCam = UIButton(frame: CGRect(x: 340, y: 100, width: 75, height: 75))
        switchCam.backgroundColor = UIColor.clear
        switchCam.layer.cornerRadius = 0.5 * switchCam.bounds.size.width
        switchCam.clipsToBounds = true
        switchCam.layer.borderWidth = 1
        switchCam.layer.borderColor = UIColor.white.cgColor
        switchCam.addTarget(self, action: #selector(switchCamera(sender:)), for: .touchUpInside)
        
        let exitButton = UIButton(frame: CGRect(x: 0, y: 100, width: 75, height: 75))
        exitButton.backgroundColor = UIColor.clear
        exitButton.layer.cornerRadius = 0.5 * exitButton.bounds.size.width
        exitButton.clipsToBounds = true
        exitButton.layer.borderWidth = 1
        exitButton.layer.borderColor = UIColor.white.cgColor
        exitButton.addTarget(self, action: #selector(goBack(sender:)), for: .touchUpInside)
        
        view.addSubview(captureButton)
        view.addSubview(switchCam)
        view.addSubview(exitButton)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareCameraBack()
        
        
    }
    func prepareCameraBack(){
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        let avalailableDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back).devices
        captureDevice = avalailableDevices.first
        beginSession()
    }
    
    func prepareCameraFront(){
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        let avalailableDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .front).devices
        captureDevice = avalailableDevices.first
        beginSession()
    }
    func beginSession(){
        do{
            let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(captureDeviceInput)
        } catch {
            print(error.localizedDescription)
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer = previewLayer
        let previewView = UIView(frame: view.frame)
        self.view.addSubview(previewView)
        self.previewLayer.frame = self.view.frame
        previewView.layer.addSublayer(self.previewLayer)
        createButtons()
        captureSession.startRunning()
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.videoSettings = [((kCVPixelBufferPixelFormatTypeKey as NSString) as String): NSNumber(value: kCVPixelFormatType_32BGRA)]
        
        dataOutput.alwaysDiscardsLateVideoFrames = true
        
        if captureSession.canAddOutput(dataOutput){
            captureSession.addOutput(dataOutput)
        }
        captureSession.commitConfiguration()
        
        let queue = DispatchQueue(label: "com.andrebirsan.captured")
        dataOutput.setSampleBufferDelegate(self, queue: queue)
    }
    @objc private func capturePic(sender: UIButton!){
        takePhoto = true
        print("ZOWEE")
        
        
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        if takePhoto{
            takePhoto = false
            if let image = self.getImageFromSampleBuffer(buffer: sampleBuffer){
                photosTaken.append(image)
                print(photosTaken.count)
            }
        }
    }
    
    func getImageFromSampleBuffer(buffer: CMSampleBuffer) -> UIImage?{
        if let pixelBuffer = CMSampleBufferGetImageBuffer(buffer){
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let context = CIContext()
            
            let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
            
            if let image = context.createCGImage(ciImage, from: imageRect){
                return UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .right)
            }
        }
        return nil
    }
    
    func stopCaptureSession(){
        
        self.captureSession.stopRunning()
        if let inputs = captureSession.inputs as? [AVCaptureDeviceInput]{
            for input in inputs{
                self.captureSession.removeInput(input)
            }
        }
    }
    @objc private func switchCamera(sender: UIButton){
        stopCaptureSession()
        counter += 1
        if counter % 2 == 0{
            prepareCameraFront()
        }
        else{
            prepareCameraBack()
        }
        
    }
    
    @objc private func goBack(sender: UIButton){
        stopCaptureSession()
        let currentUser = Auth.auth().currentUser
        let StorageRef = Storage.storage().reference()
        let DatabaseRef = Database.database().reference()
        let uid = currentUser!.uid
        for image in photosTaken{
            
            let imageData = image.jpegData(compressionQuality: 1.0)
            var picURL: String?
            let imageName = NSUUID().uuidString
            let picToSendStorageRef = StorageRef.child("users").child("takenPhotos").child("\(imageName).jpg")
            
            let uploadTask = picToSendStorageRef.putData(imageData!, metadata: nil)
            {metadata, error in
                
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    return
                }
                let size = metadata.size
                
                picToSendStorageRef.downloadURL { (url, error) in
                    guard let downloadURL = url
                        
                        else {
                            // Uh-oh, an error occurred!
                            return
                    }
                    picURL = downloadURL.absoluteString
                    let values = ["imageURL": picURL]
                    
                    DatabaseRef.child("takenPhotos").child(uid).childByAutoId().updateChildValues(values as [AnyHashable: Any])
                }
            }
        }
        
    }
    
}
