//
//  SettingsViewController.swift
//  MHW
//
//  Created by Jeff Eom on 2018-04-15.
//  Copyright © 2018 Jeff Eom. All rights reserved.
//

import UIKit
import CoreData
import SafariServices
import GoogleMobileAds

protocol ResetDelegate: class {
  func resetPressed()
}

class SettingsViewController: UIViewController {
  static let identifier = "settingsVC"
  @IBOutlet weak var settingTableView: UITableView!
  @IBOutlet weak var bannerView: GADBannerView!
  @IBOutlet weak var viewBottomConstraintForBanner: NSLayoutConstraint!
  
  var settingsArray = [["Remove Ads & Buy developer a coffee".localized()], ["Reset Table".localized()], ["Help".localized(), "Contact Us".localized()], [""]]
  var settingsTitleArray = ["Remove Ads".localized(), "Reset Table".localized(), "Contact".localized(), "Version".localized()]
  
  var productIDs: [String] = ["adRemoval"]
  var productsArray: [SKProduct] = []
  
  weak var delegate: ResetDelegate?
  
  var transactionInProgress = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Settings".localized()
    let purchased = UserDefaults.standard.value(forKey: "purchasedAdsRemoval") as? Bool ?? false
    if purchased {
      bannerView.isHidden = true
      settingsArray[0] = ["Thanks for the purchase ❤️"]
      viewBottomConstraintForBanner.constant = 0
    }else {
      bannerView.adUnitID = Key.adUnitID
      bannerView.rootViewController = self
      bannerView.load(GADRequest())
    }
    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
      settingsArray[3] = [version]
      settingTableView.reloadData()
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    let purchased = UserDefaults.standard.value(forKey: "purchasedAdsRemoval") as? Bool ?? false
    if purchased {
      bannerView.isHidden = true
      settingsArray[0] = ["Thanks for the purchase ❤️"]
      viewBottomConstraintForBanner.constant = 0
    }else {
      bannerView.adUnitID = Key.adUnitID
      bannerView.rootViewController = self
      bannerView.load(GADRequest())
    }
    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
      settingsArray[3] = [version]
      settingTableView.reloadData()
    }
    requestProductInfo()
    SKPaymentQueue.default().add(self)
  }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return settingsArray.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return settingsArray[section].count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell(style: .default, reuseIdentifier: "settingsCell")
    cell.textLabel?.text = settingsArray[indexPath.section][indexPath.row]
    cell.textLabel?.font = UIFont(name: "Avenir-Medium", size: 17.0)
    cell.selectionStyle = .none
    
    if indexPath.section == 1 {
      cell.textLabel?.textColor = UIColor(red: 255/255, green: 85/255, blue: 85/255, alpha: 1.0)
    }
    return cell
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return settingsTitleArray[section]
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch indexPath.section {
    case 0:
      //removeAds
      let purchased = UserDefaults.standard.value(forKey: "purchasedAdsRemoval") as? Bool ?? false
      if !purchased {
        let purchaseAlertController = UIAlertController(title: "Are you sure?".localized(), message: "By pressing the purchase button, you will be purchasing USD$0.99 to remove ads", preferredStyle: .alert)
        let purchase = UIAlertAction(title: "Purchase", style: .default) { (_) in
          print("purchase button pressed")
          let payment = SKPayment(product: self.productsArray.first as! SKProduct)
          SKPaymentQueue.default().add(payment)
          self.transactionInProgress = true
        }
        let cancel = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil)
        purchaseAlertController.addAction(purchase)
        purchaseAlertController.addAction(cancel)
        self.present(purchaseAlertController, animated: true, completion: nil)
      }
    case 1:
      //RESET TABLE
      // the alert view
      let alertController = UIAlertController(title: "Are you sure?".localized(), message: "By pressing delete button, it will delete every data in the table and cannot be recovered.".localized(), preferredStyle: .alert)
      let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: { _ in
        alertController.dismiss(animated: true, completion: nil)
      })
      let deleteAction = UIAlertAction(title: "Delete".localized(), style: .destructive) { _ in
        let alert = UIAlertController(title: "", message: "Successfully deleted all data".localized(), preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        let when = DispatchTime.now() + 2
        DispatchQueue.main.asyncAfter(deadline: when){
          alert.dismiss(animated: true, completion: {
            self.delegate?.resetPressed()
            self.navigationController?.popViewController(animated: true)
          })
        }
      }
      alertController.addAction(cancelAction)
      alertController.addAction(deleteAction)
      self.present(alertController, animated: true, completion: nil)
    case 2:
      if indexPath.item == 0 {
        //HELP
        ///////////////
        let destination: URL = URL(string: "https://github.com/jeffeom/MHW/blob/master/help_en.md")!
        let safari: SFSafariViewController = SFSafariViewController(url: destination)
        self.present(safari, animated: true, completion: nil)
      }else {
        //CONTACT US
        let contactUsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: ContactUsViewController.identifier) as! ContactUsViewController
        navigationController?.pushViewController(contactUsVC, animated: true)
      }
      //    case 2:
      //      if indexPath.item == 0 {
      //        //RATE OUR APP
      //
      //      }else {
      //        //SHARE OUR APP
      //
    //      }
    default:
      return
    }
  }
}

//MARK: StoreKitDelegate
extension SettingsViewController: SKProductsRequestDelegate, SKPaymentTransactionObserver {
  func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
    for transaction in transactions {
      switch transaction.transactionState {
      case .purchased:
        print("Transaction completed successfully.")
        SKPaymentQueue.default().finishTransaction(transaction)
        transactionInProgress = false
        UserDefaults.standard.set(true, forKey: "purchasedAdsRemoval")
        bannerView.isHidden = true
        viewBottomConstraintForBanner.constant = 0
      case .failed:
        print("Transaction Failed")
        SKPaymentQueue.default().finishTransaction(transaction)
        transactionInProgress = false
      case .restored:
        let alertController = UIAlertController(title: "", message: "Successfully Restored", preferredStyle: .alert)
        self.present(alertController, animated: true, completion: {
          UserDefaults.standard.set(true, forKey: "purchasedAdsRemoval")
        })
        let when = DispatchTime.now() + 2
        DispatchQueue.main.asyncAfter(deadline: when){
          alertController.dismiss(animated: true, completion: nil)
        }
      default:
        print(transaction.transactionState.rawValue)
      }
    }
  }
  
  func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
    if response.products.count != 0 {
      for product in response.products {
        productsArray.append(product)
      }
    }
    else {
      print("There are no products.")
    }
    if response.invalidProductIdentifiers.count != 0 {
      print(response.invalidProductIdentifiers.description)
    }
  }
  
  func requestProductInfo() {
    if SKPaymentQueue.canMakePayments() {
      let productRequest = SKProductsRequest(productIdentifiers: Set(productIDs))
      productRequest.delegate = self
      productRequest.start()
    }
    else {
      print("Cannot perform In App Purchases.")
    }
  }
}
