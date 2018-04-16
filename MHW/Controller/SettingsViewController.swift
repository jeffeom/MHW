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

protocol ResetDelegate: class {
  func resetPressed()
}

class SettingsViewController: UIViewController {
  static let identifier = "settingsVC"
  var settingsArray = [["Reset Table".localized()], ["Help".localized(), "Contact Us".localized()], [""]]
  var settingsTitleArray = ["Reset Table".localized(), "Contact".localized(), "Version".localized()]
  
  weak var delegate: ResetDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Settings".localized()
    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
      settingsArray[2] = [version]
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
    if indexPath.section == 0 {
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
    case 1:
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
