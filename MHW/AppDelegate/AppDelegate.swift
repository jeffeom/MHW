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
import SwiftyStoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    GADMobileAds.configure(withApplicationID: Key.admobID)
    SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
      for purchase in purchases {
        switch purchase.transaction.transactionState {
        case .purchased, .restored:
          if purchase.needsFinishTransaction {
            // Deliver content from server, then:
            SwiftyStoreKit.finishTransaction(purchase.transaction)
          }
        // Unlock content
        case .failed, .purchasing, .deferred:
          break // do nothing
        }
      }
    }
    return true
  }

  func applicationWillTerminate(_ application: UIApplication) {
    PersistenceService.saveContext()
  }
}
