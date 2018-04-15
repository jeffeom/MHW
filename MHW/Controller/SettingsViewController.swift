//
//  SettingsViewController.swift
//  MHW
//
//  Created by Jeff Eom on 2018-04-15.
//  Copyright © 2018 Jeff Eom. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 5
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 10
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell(style: .default, reuseIdentifier: "settingsCell")
    cell.textLabel?.text = "Hi!"
    cell.textLabel?.textColor = UIColor(red: 255/255, green: 85/255, blue: 85/255, alpha: 1.0)
    return cell
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "Setting!"
  }
}
