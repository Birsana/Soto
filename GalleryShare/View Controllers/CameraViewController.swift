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
import JPSVolumeButtonHandler
import Alamofire

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    let captureSession = AVCaptureSession()
    var previewLayer: CALayer!
    var captureDevice: AVCaptureDevice!
    var takePhoto = false
    
    
    var volumeButtonHandler: JPSVolumeButtonHandler?
    
    var counter = 1
    
    let minimumZoom: CGFloat = 1.0
    let maximumZoom: CGFloat = 3.0
    var lastZoomFactor: CGFloat = 1.0
    
    var photosTaken = [UIImage]()
    
    override func viewWillAppear(_ animated: Bool) {
        //listenVolumeButton()
       
       //VIEW DID DISSAPEAR
    }
    
    @objc func pinch(_ pinch: UIPinchGestureRecognizer) {
        guard let device = captureDevice else { return }
        
        // Return zoom value between the minimum and maximum zoom values
        func minMaxZoom(_ factor: CGFloat) -> CGFloat {
            return min(min(max(factor, minimumZoom), maximumZoom), device.activeFormat.videoMaxZoomFactor)
        }
        
        func update(scale factor: CGFloat) {
            do {
                try device.lockForConfiguration()
                defer { device.unlockForConfiguration() }
                device.videoZoomFactor = factor
            } catch {
                print("\(error.localizedDescription)")
            }
        }
        
        let newScaleFactor = minMaxZoom(pinch.scale * lastZoomFactor)
        
        switch pinch.state {
        case .began: fallthrough
        case .changed: update(scale: newScaleFactor)
        case .ended:
            lastZoomFactor = minMaxZoom(newScaleFactor)
            update(scale: lastZoomFactor)
        default: break
        }
    }
    
  /**  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let screenSize = self.view.bounds.size
        if let touchPoint = touches.first {
            let x = touchPoint.location(in: self.view).y / screenSize.height
            let y = 1.0 - touchPoint.location(in: self.view).x / screenSize.width
            let focusPoint = CGPoint(x: x, y: y)

            if let device = captureDevice {
                do {
                    try device.lockForConfiguration()

                    device.focusPointOfInterest = focusPoint
                    //device.focusMode = .continuousAutoFocus
                    device.focusMode = .autoFocus
                    //device.focusMode = .locked
                    device.exposurePointOfInterest = focusPoint
                    device.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
                    device.unlockForConfiguration()
                }
                catch {
                    // just ignore
                }
            }
        }
    } **/

    
    func sendToServer(){
        
        //PUT THE FOLLOWING IN THE FIREBASE THING
        var counter = 1
        let parameters = [
            "uid": "\(Auth.auth().currentUser!.uid)",
            "picCount": "\(photosTaken.count)"]
        
        AF.upload(multipartFormData: { (multipartFormData) in
            for photo in self.photosTaken{
                let imgData = photo.jpegData(compressionQuality: 1)
                multipartFormData.append(imgData!, withName: "photo_\(String(counter))", fileName: "photo_\(String(counter)).jpg", mimeType: "image/jpg")
                counter += 1
            }
            for (key, value) in parameters{
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
        }, to: "http://soto.us-east-2.elasticbeanstalk.com/").responseJSON { (response) in
            print(response)
        }
        
    
        
  
        
    
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
        self.volumeButtonHandler = JPSVolumeButtonHandler(up: {self.takePhoto = true}, downBlock: {self.takePhoto = true})
        self.volumeButtonHandler?.start(true)
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
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action:#selector(pinch(_:)))
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer = previewLayer
        let previewView = UIView(frame: view.frame)
        previewView.addGestureRecognizer(pinchRecognizer)
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
        sendToServer()
        let currentUser = Auth.auth().currentUser
        let StorageRef = Storage.storage().reference()
        let DatabaseRef = Database.database().reference()
        let uid = currentUser!.uid
        for image in photosTaken{
            let imageData = image.jpegData(compressionQuality: 1.0)
            let imgToSave = UIImage(data: imageData!)
            UIImageWriteToSavedPhotosAlbum(imgToSave!, nil, nil, nil)
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
