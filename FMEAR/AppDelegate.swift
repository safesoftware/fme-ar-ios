//
//  AppDelegate.swift
//  FMEAR
//
//  Created by Angus Lau on 2017-08-24.
//  Copyright © 2017 Safe Software Inc. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
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

    func application(_ app: UIApplication, open openURL: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("Launching app with url '\(openURL)'...")
        
        var fileURL : URL
        if !openURL.isFileURL {
            guard let sendingAppID = options[.sourceApplication] as? String else {
                return false;
            }
            if !sendingAppID.elementsEqual("com.safe.fmeexpress") {
                print("Application was not launched by FME Express")
                return false;
            }
            guard let components = NSURLComponents(url: openURL, resolvingAgainstBaseURL: true),
                let params = components.queryItems else {
                    print("Missing components in URL: \(openURL)")
                    return false
            }
            guard let fileURLString = params.first(where: { $0.name == "fileURL"})?.value else {
                print("Missing fileURL in openURL: \(openURL)")
                return false;
            }
            print("Obtained file url string: '\(fileURLString)")
            fileURL = URL(string: fileURLString)!
        } else {
            fileURL = openURL
        }
                
        // Reveal / import the document at the URL
        if window?.rootViewController as? DocumentBrowserViewController == nil {
            if let window = self.window {
                window.rootViewController = DocumentBrowserViewController()
                print("Creating DocumentBrowserViewController")
            }
        }
        
        guard let documentBrowserViewController = window?.rootViewController as? DocumentBrowserViewController else { return false }

        documentBrowserViewController.revealDocument(at: fileURL, importIfNeeded: true) { (revealedDocumentURL, error) in
            if let error = error {
                // Handle the error appropriately
                print("Failed to reveal the document at URL \(fileURL) with error: '\(error)'")
                return
            }
            
            if var topController = app.keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    if let arViewController = topController as? ViewController {
                        // The AR view controller is already being presented.
                        // We can open the document directly.
                        arViewController.restartExperience(arViewController)
                        arViewController.document = Document(fileURL: revealedDocumentURL!)

                        return
                    } else {
                        topController = presentedViewController
                    }
                }
            }
            
            // Present the Document View Controller for the revealed URL
            documentBrowserViewController.presentDocument(at: revealedDocumentURL!)
        }

        return true
    }


}

