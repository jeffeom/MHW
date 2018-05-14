//
//  SwitchLanguageViewController.swift
//  MHW
//
//  Created by Jeff Eom on 2018-05-14.
//  Copyright © 2018 Jeff Eom. All rights reserved.
//

import UIKit
import Localize_Swift
import GoogleMobileAds

struct AppleLanguage {
  var language: String?
  
  static func inTypeForm(languageInString: String) -> String {
    switch languageInString {
    case "English".localized():
      return "Base"
    case "Korean".localized():
      return "ko"
    default:
      return "Base"
    }
  }
}

class SwitchLanguageViewController: UIViewController {
  @IBOutlet weak var languageTableView: UITableView!
  @IBOutlet weak var viewBottomConstraintForBanner: NSLayoutConstraint!
  @IBOutlet weak var bannerView: GADBannerView!
  var currentLanguage = UserDefaults.standard.array(forKey: "AppleLanguages")?.first as? String
  let languagesAvailable = ["English".localized(), "Korean".localized()]
  
  static let identifier = "switchLanguageVC"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Switch Language".localized()
    if (currentLanguage?.contains("en") ?? false)  {
      currentLanguage = "Base"
    }else if (currentLanguage?.contains("ko") ?? false) {
      currentLanguage = "ko"
    }
    let purchased = UserDefaults.standard.value(forKey: "purchasedAdsRemoval") as? Bool ?? false
    if purchased {
      bannerView.isHidden = true
      viewBottomConstraintForBanner.constant = 0
    }else {
      bannerView.isHidden = false
      viewBottomConstraintForBanner.constant = 50
      bannerView.adUnitID = Key.adUnitID
      bannerView.rootViewController = self
      bannerView.load(GADRequest())
    }
  }
}

extension SwitchLanguageViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return languagesAvailable.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell(style: .default, reuseIdentifier: "languageCell")
    cell.textLabel?.font = UIFont(name: "Avenir-Medium", size: 17.0)
    cell.textLabel?.text = languagesAvailable[indexPath.row]
    cell.textLabel?.adjustsFontSizeToFitWidth = true
    cell.textLabel?.minimumScaleFactor = 0.5
    cell.selectionStyle = .none
    if currentLanguage == AppleLanguage.inTypeForm(languageInString: cell.textLabel?.text ?? "") {
      cell.accessoryType = .checkmark
      cell.isSelected = true
    }else {
      cell.accessoryType = .none
      cell.isSelected = false
    }
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let cell = tableView.cellForRow(at: indexPath){
      if cell.accessoryType == .none{
        cell.accessoryType = .checkmark
      }else {
        cell.accessoryType = .none
      }
    }
    let previousLang = UserDefaults.standard.array(forKey: "AppleLanguages")?.first as? String
    var selectedLang = "Base"
    switch indexPath.row {
    case 0:
      selectedLang = "Base"
      Localize.setCurrentLanguage("Base")
      UserDefaults.standard.set(["Base"], forKey: "AppleLanguages")
      tableView.cellForRow(at: IndexPath(row: 1, section: 0))?.accessoryType = .none
    case 1:
      selectedLang = "ko"
      Localize.setCurrentLanguage("ko")
      UserDefaults.standard.set(["ko"], forKey: "AppleLanguages")
      tableView.cellForRow(at: IndexPath(row: 0, section: 0))?.accessoryType = .none
    default:
      selectedLang = "Base"
      Localize.setCurrentLanguage("Base")
      UserDefaults.standard.set(["Base"], forKey: "AppleLanguages")
    }
    if previousLang == selectedLang {
      navigationController?.popViewController(animated: true)
    }else {
      let alertController = UIAlertController(title: "Please restart the app".localized(), message: "You need to restart the app to have the app running in the language you just selected.".localized(), preferredStyle: .alert)
      let defaultAction = UIAlertAction(title: "OK".localized(), style: .default, handler: { _ in
        self.navigationController?.popViewController(animated: true)
      })
      alertController.addAction(defaultAction)
      present(alertController, animated: true, completion: nil)
    }
  }
}
