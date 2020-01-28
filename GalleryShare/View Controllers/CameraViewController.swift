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

extension UIImage {


    func updateImageOrientionUpSide() -> UIImage? {
        if self.imageOrientation == .up {
            return self
        }

        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        if let normalizedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return normalizedImage
        }
        UIGraphicsEndImageContext()
        return nil
    }
}

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    let captureSession = AVCaptureSession()
    var previewLayer: CALayer!
    var captureDevice: AVCaptureDevice!
    var takePhoto = false
    
    var username: String!
    
    
    @IBOutlet weak var viewPics: UIImageView!
    
    var volumeButtonHandler: JPSVolumeButtonHandler?
    
    
    var counter = 1
    
    let minimumZoom: CGFloat = 1.0
    let maximumZoom: CGFloat = 3.0
    var lastZoomFactor: CGFloat = 1.0
    
    var photosTaken = [UIImage]()
    
    
    
    override func viewDidDisappear(_ animated: Bool) {

        self.volumeButtonHandler?.stop()
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
        let user = Auth.auth().currentUser
        let uid = user?.uid
        let databaseRef = Database.database().reference()
        var friendArray = [String]()
        var counter = 1
        var parameters = [
            "uid": "\(uid!)",
            "picCount": "\(photosTaken.count)"]
        
        
        databaseRef.child("users").child(uid!).observeSingleEvent(of: .value) { (snapshot) in
            let dictionary = snapshot.value as? [String: AnyObject]
            self.username = (dictionary!["username"] as? String)!
            databaseRef.child("Friends").child(self.username).observeSingleEvent(of: .value) { (snapshot) in
                var friendCounter = 1
                for child in snapshot.children{
                    friendArray.append((child as AnyObject).key as String)
                    parameters["\(friendCounter)"] = (child as AnyObject).key as String
                    friendCounter += 1
                }
                parameters["friendCount"] = "\(friendArray.count)"
                AF.upload(multipartFormData: { (multipartFormData) in
                    for photo in self.photosTaken{
                        let imgData = photo.jpegData(compressionQuality: 1)
                        multipartFormData.append(imgData!, withName: "photo_\(String(counter))", fileName: "photo_\(String(counter)).jpg", mimeType: "image/jpg")
                        counter += 1
                    }
                    for (key, value) in parameters{
                        multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
                    }
                }, to: "http://soto.us-east-2.elasticbeanstalk.com/").responseString { (response) in
                    print(response)
                    self.photosTaken.removeAll()
                    self.viewPics.image = nil
                }
            }
            
        }
        //PUT THE FOLLOWING IN THE FIREBASE THING, SEND ONLY FIRST 20 PICTURES
        //http://httpbin.org/post
        //http://soto.us-east-2.elasticbeanstalk.com/
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        if photosTaken.count > 0{
        let vc = CameraPreviewVCViewController()
        vc.passedContentOffset = IndexPath(item: photosTaken.count-1, section: 0)
        vc.imgArray = self.photosTaken
        self.present(vc, animated: true, completion: nil)
        }
    }
    
    
    
    func createButtons(){
        let captureButton = UIButton(frame: CGRect(x: 0, y: 0, width: 90, height: 90))
        captureButton.backgroundColor = UIColor.clear
        captureButton.center.x = self.view.center.x
        captureButton.frame.origin.y = self.view.frame.height - captureButton.frame.height
        captureButton.layer.cornerRadius = 0.5 * captureButton.bounds.size.width
        captureButton.clipsToBounds = true
        captureButton.layer.borderWidth = 1
        captureButton.layer.borderColor = UIColor.black.cgColor
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
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        let tap = UITapGestureRecognizer(target:self, action: #selector(handleTap(_:)))
        tap.numberOfTapsRequired = 1
        viewPics.isUserInteractionEnabled = true
        viewPics.addGestureRecognizer(tap)
        self.volumeButtonHandler = JPSVolumeButtonHandler(up: {self.takePhoto = true}, downBlock: {self.takePhoto = true})
        self.volumeButtonHandler?.start(true)
        prepareCameraBack()
        self.view.bringSubviewToFront(viewPics)
        
        
    }
    
    @objc func willResignActive(_ notification: Notification) {
        print("yikes")
        //stopCaptureSession()
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
                if let updatedImage = image.updateImageOrientionUpSide() {
                    photosTaken.append(updatedImage)
                } else {
                    photosTaken.append(image)
                }
                print(photosTaken.count)
                DispatchQueue.main.async {
                    self.viewPics.image = image
                }
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
        //stopCaptureSession()
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
                    print("I am here")
                    DatabaseRef.child("takenPhotos").child(uid).childByAutoId().updateChildValues(values as [AnyHashable: Any])
                }
            }
        }
        //photosTaken.removeAll()
        self.viewPics.image = nil
    }
}
