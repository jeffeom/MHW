//
//  AppDelegate.swift
//  MHW
//
//  Created by Jeff Eom on 2018-04-10.
//  Copyright © 2018 Jeff Eom. All rights reserved.
//

import UIKit
import CoreData
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?


  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    GADMobileAds.configure(withApplicationID: Key.admobID)
    return true
  }

  func applicationWillTerminate(_ application: UIApplication) {
    PersistenceService.saveContext()
  }
}
