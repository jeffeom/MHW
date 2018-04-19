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
import SwiftyStoreKit

protocol ResetDelegate: class {
  func resetPressed()
}

class SettingsViewController: UIViewController {
  static let identifier = "settingsVC"
  @IBOutlet weak var settingTableView: UITableView!
  @IBOutlet weak var bannerView: GADBannerView!
  @IBOutlet weak var viewBottomConstraintForBanner: NSLayoutConstraint!
  
  var settingsArray = [["Remove Ads & Buy developer a cup of coffee ☕️".localized(), "Restore in-app Purchases".localized()], ["Reset Table".localized()], ["Help".localized(), "Contact Us".localized()], [""]]
  var settingsTitleArray = ["Remove Ads".localized(), "Reset Table".localized(), "Contact".localized(), "Version".localized()]
  
  var productIDs: [String] = ["adRemoval"]
  
  weak var delegate: ResetDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Settings".localized()
    retrieveProductInfo()
    let purchased = UserDefaults.standard.value(forKey: "purchasedAdsRemoval") as? Bool ?? false
    if purchased {
      bannerView.isHidden = true
      settingsArray[0] = ["Thanks for the purchase ❤️".localized()]
      viewBottomConstraintForBanner.constant = 0
    }else {
      bannerView.isHidden = false
      viewBottomConstraintForBanner.constant = 50
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
      settingsArray[0] = ["Thanks for the purchase ❤️".localized()]
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
    cell.textLabel?.adjustsFontSizeToFitWidth = true
    cell.textLabel?.minimumScaleFactor = 0.5
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
      if indexPath.item == 0 {
        //removeAds
        let purchased = UserDefaults.standard.value(forKey: "purchasedAdsRemoval") as? Bool ?? false
        if !purchased {
          let purchaseAlertController = UIAlertController(title: "Are you sure?".localized(), message: "By pressing the purchase button, you will be paying USD$1.99".localized(), preferredStyle: .alert)
          let purchase = UIAlertAction(title: "Purchase".localized(), style: .default) { (_) in
            print("purchase button pressed")
            self.purchaseProduct()
            let alert = UIAlertController(title: nil, message: "Please wait...".localized(), preferredStyle: .alert)
            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            loadingIndicator.startAnimating()
            alert.view.addSubview(loadingIndicator)
            self.present(alert, animated: true, completion: nil)
          }
          let cancel = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil)
          purchaseAlertController.addAction(purchase)
          purchaseAlertController.addAction(cancel)
          self.present(purchaseAlertController, animated: true, completion: nil)
        }
      }else {
        //restore purchase
        self.restorePurchases()
        let alert = UIAlertController(title: nil, message: "Please wait...".localized(), preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating()
        alert.view.addSubview(loadingIndicator)
        self.present(alert, animated: true, completion: nil)
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
        let currentLang = UserDefaults.standard.array(forKey: "AppleLanguages")?.first as? String
        var destination = URL(string: "https://github.com/jeffeom/MHW/blob/master/help_en.md")!
        if (currentLang?.contains("ko") ?? false) {
          destination = URL(string: "https://github.com/jeffeom/MHW/blob/master/help_ko.md")!
        }else {
          destination = URL(string: "https://github.com/jeffeom/MHW/blob/master/help_en.md")!
        }
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
extension SettingsViewController{
  func retrieveProductInfo() {
    SwiftyStoreKit.retrieveProductsInfo(["adRemoval"]) { result in
      if let product = result.retrievedProducts.first {
        let priceString = product.localizedPrice!
        print("Product: \(product.localizedDescription), price: \(priceString)")
      }
      else if let invalidProductId = result.invalidProductIDs.first {
        print("Invalid product identifier: \(invalidProductId)")
      }
      else {
        print("Error: \(String(describing: result.error))")
      }
    }
  }
  
  func purchaseProduct() {
    SwiftyStoreKit.retrieveProductsInfo(["adRemoval"]) { result in
      if let product = result.retrievedProducts.first {
        SwiftyStoreKit.purchaseProduct(product, quantity: 1, atomically: true) { result in
          self.dismiss(animated: true, completion: nil)
          switch result {
          case .success(let product):
            print("Purchase Success: \(product.productId)")
            UserDefaults.standard.set(true, forKey: "purchasedAdsRemoval")
            self.navigationController?.popViewController(animated: true)
            // fetch content from your server, then:
            if product.needsFinishTransaction {
              SwiftyStoreKit.finishTransaction(product.transaction)
            }
          case .error(let error):
            var errorMessage = ""
            switch error.code {
            case .unknown: errorMessage = "Unknown error. Please contact support"
            case .clientInvalid: errorMessage = "Not allowed to make the payment"
            case .paymentCancelled: break
            case .paymentInvalid: errorMessage = "The purchase identifier was invalid"
            case .paymentNotAllowed: errorMessage = "The device is not allowed to make the payment"
            case .storeProductNotAvailable: errorMessage = "The product is not available in the current storefront"
            case .cloudServicePermissionDenied: errorMessage = "Access to cloud service information is not allowed"
            case .cloudServiceNetworkConnectionFailed: errorMessage = "Could not connect to the network"
            case .cloudServiceRevoked: errorMessage = "User has revoked permission to use this cloud service"
            }
            let alert = UIAlertController(title: "", message: errorMessage, preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
            let when = DispatchTime.now() + 2
            DispatchQueue.main.asyncAfter(deadline: when){
              alert.dismiss(animated: true, completion: nil)
            }
          }
        }
      }
    }
  }
  
  func restorePurchases() {
    SwiftyStoreKit.restorePurchases(atomically: true) { results in
      self.dismiss(animated: true, completion: nil)
      var message = ""
      var success = false
      if results.restoreFailedPurchases.count > 0 {
        success = false
        message = "Restore Failed".localized()
      }
      else if results.restoredPurchases.count > 0 {
        success = true
        message = "Restore Success".localized()
        UserDefaults.standard.set(true, forKey: "purchasedAdsRemoval")
      }
      else {
        success = false
        message = "Nothing to Restore".localized()
      }
      let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
      self.present(alert, animated: true, completion: nil)
      let when = DispatchTime.now() + 2
      DispatchQueue.main.asyncAfter(deadline: when){
        alert.dismiss(animated: true, completion: {
          if success {
            self.navigationController?.popViewController(animated: true)
          }
        })
      }
    }
  }
}
