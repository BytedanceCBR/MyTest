//
//  AppDelegate.swift
//  Bubble
//
//  Created by linlin on 2018/6/7.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import BDStartUp
import TTNetworkManager
import RxSwift
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let disposeBag = DisposeBag()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        BDStartUpManager.sharedInstance().appID = "1161"
        BDStartUpManager.sharedInstance().channel = "Enterprise"
        BDStartUpManager.sharedInstance().appName = "Lark"
        BDStartUpManager.sharedInstance().start(with: application, options: launchOptions)
//        TTNetworkManager.shareInstance().rx
//            .requestForBinary(
//                url: "http://localhost:3000/auth/test",
//                params: ["username": "leo",
//                         "password": "123"],
//                method: "POST",
//                needCommonParams: false)
//            .map({ (data) -> NSString? in
//                NSString(data: data, encoding: String.Encoding.utf8.rawValue)
//            })
//            .subscribe(onNext: { (content) in
//                print(content ?? "error")
//            })
//            .disposed(by: disposeBag)
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.white
        let tabVC = TabViewController(nibName: nil, bundle: nil)
        let rootNavController = UINavigationController(rootViewController: tabVC)
        rootNavController.setNavigationBarHidden(true, animated: false)
        window?.rootViewController = rootNavController
        window?.makeKeyAndVisible()
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


}

