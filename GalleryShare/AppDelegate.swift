//
//  AppDelegate.swift
//  GalleryShare
//
//  Created by Andre Birsan on 2019-09-06.
//  Copyright © 2019 Andre Birsan. All rights reserved.
//

import UIKit
import Firebase
import Photos


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        let photos = PHPhotoLibrary.authorizationStatus()
        if photos == .notDetermined {
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized{
                    
                    if UserDefaults.standard.bool(forKey: "firstTime"){
                        let tempViewController = self.storyboard.instantiateViewController(withIdentifier: "firstLog") as? ProfilePicViewController
                        tempViewController?.modalPresentationStyle = .fullScreen
                        self.window?.rootViewController = tempViewController
                        self.window?.makeKeyAndVisible()
                    }
                    else if UserDefaults.standard.bool(forKey: "isLoggedIn"){
                        let homeViewController = self.storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.homeViewController) as? MainPage
                        homeViewController?.modalPresentationStyle = .fullScreen
                        self.window?.rootViewController = homeViewController
                        self.window?.makeKeyAndVisible()
                        
                        
                    }
                }
                else {
                    
                    /**      let tempViewController = self.storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.firstLogIn) as? IntroPageViewController
                     tempViewController?.modalPresentationStyle = .fullScreen
                     self.window?.rootViewController = tempViewController
                     self.window?.makeKeyAndVisible()
                     let alert = UIAlertController(title: "Photos Access Denied", message: "App needs access to photos library.", preferredStyle: .alert)
                     alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                     self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                     
                     **/
                }
            })
            
        }
        else if photos == .authorized{
            
            
            if UserDefaults.standard.bool(forKey: "firstTime"){
                
                let tempViewController = self.storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.firstLogIn) as? ProfilePicViewController
                tempViewController?.modalPresentationStyle = .fullScreen
                self.window?.rootViewController = tempViewController
                self.window?.makeKeyAndVisible()
                
            }
            else if UserDefaults.standard.bool(forKey: "isLoggedIn"){
                let homeViewController = self.storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.homeViewController) as? MainPage
                homeViewController?.modalPresentationStyle = .fullScreen
                self.window?.rootViewController = homeViewController
                self.window?.makeKeyAndVisible()
                
            }
        }
        // Override point for customization after application launch.
        
        
        return true
    }
    
    override init() {
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}


