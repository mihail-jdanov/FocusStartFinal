//
//  AppDelegate.swift
//  FocusStartFinal
//
//  Created by Михаил Жданов on 13.12.20.
//  Copyright © 2020 Михаил Жданов. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow()
        window?.rootViewController = ModuleBuilder.createRecipesModule()
        window?.makeKeyAndVisible()
        return true
    }

}
