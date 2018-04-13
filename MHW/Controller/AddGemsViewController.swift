//
//  AddGemsViewController.swift
//  MHW
//
//  Created by Jeff Eom on 2018-04-10.
//  Copyright © 2018 Jeff Eom. All rights reserved.
//

import UIKit

class AddGemsViewController: UIViewController {
  @IBOutlet weak var firstGemContentShadowView: UIView!
  @IBOutlet weak var firstGemContentView: UIView!
  @IBOutlet weak var secondGemContentShadowView: UIView!
  @IBOutlet weak var secondGemContentView: UIView!
  @IBOutlet weak var thirdGemContentShadowView: UIView!
  @IBOutlet weak var thirdGemContentView: UIView!
  @IBOutlet weak var gemListTableView: UITableView!
  @IBOutlet weak var resetButtonView: UIView!
  @IBOutlet weak var firstGemButton: UIButton!
  @IBOutlet weak var secondGemButton: UIButton!
  @IBOutlet weak var thirdGemButton: UIButton!
  
  var currentGemSelected = 0 {
    didSet {
      switch currentGemSelected {
      case 0:
        firstGemButton.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        secondGemButton.backgroundColor = .clear
        thirdGemButton.backgroundColor = .clear
      case 1:
        firstGemButton.backgroundColor = .clear
        secondGemButton.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        thirdGemButton.backgroundColor = .clear
      case 2:
        firstGemButton.backgroundColor = .clear
        secondGemButton.backgroundColor = .clear
        thirdGemButton.backgroundColor = UIColor.black.withAlphaComponent(0.25)
      default:
        break
      }
    }
  }
  
  var checkmarkCount = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    appearance()
    currentGemSelected = 0
  }
  
  @IBAction func pressedFirstGem(_ sender: UIButton) {
    currentGemSelected = 0
  }
  
  @IBAction func pressedSecondGem(_ sender: UIButton) {
    currentGemSelected = 1
  }
  
  @IBAction func pressedThirdGem(_ sender: UIButton) {
    currentGemSelected = 2
  }
}

//MARK: IBAction
extension AddGemsViewController {
  @IBAction func pressedResetButton(_ sender: UIButton) {
    let alertController = UIAlertController(title: "Reset?", message: "Do you want to start from the beginning?", preferredStyle: .alert)
    let resetAction = UIAlertAction(title: "Reset", style: .destructive) { (_) in
      print("reset")
      self.firstGemButton.setTitle("X", for: .normal)
      self.secondGemButton.setTitle("X", for: .normal)
      self.thirdGemButton.setTitle("X", for: .normal)
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    alertController.addAction(resetAction)
    alertController.addAction(cancelAction)
    present(alertController, animated: true, completion: nil)
  }
  
  @IBAction func pressedDoneButton(_ sender: UIBarButtonItem) {
    let gemList = GemList(context: PersistenceService.context)
    gemList.firstGem = firstGemButton.titleLabel?.text
    gemList.secondGem = secondGemButton.titleLabel?.text
    gemList.thirdGem = thirdGemButton.titleLabel?.text
    let previousVC = navigationController?.viewControllers.first as! MeldingListTableViewController
    previousVC.gemListToAdd = gemList
    PersistenceService.saveContext()
    navigationController?.popToViewController(previousVC, animated: true)
  }
}

//MARK: Setup
extension AddGemsViewController {
  func appearance() {
    createRoundShadowView(withShadowView: firstGemContentShadowView, andContentView: firstGemContentView, withCornerRadius: 8, withOpacity: 0.25)
    createRoundShadowView(withShadowView: secondGemContentShadowView, andContentView: secondGemContentView, withCornerRadius: 8, withOpacity: 0.25)
    createRoundShadowView(withShadowView: thirdGemContentShadowView, andContentView: thirdGemContentView, withCornerRadius: 8, withOpacity: 0.25)
  }
}

//MARK: UITableViewDelegate & DataSource
extension AddGemsViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 10
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell(style: .default, reuseIdentifier: "gemCell")
    cell.textLabel?.text = "A"
    cell.selectionStyle = .none
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let cell = tableView.cellForRow(at: indexPath)
    switch currentGemSelected {
    case 0:
      firstGemButton.setTitle(cell?.textLabel?.text, for: .normal)
      currentGemSelected = 1
    case 1:
      secondGemButton.setTitle(cell?.textLabel?.text, for: .normal)
      currentGemSelected = 2
    case 2:
      thirdGemButton.setTitle(cell?.textLabel?.text, for: .normal)
      thirdGemButton.backgroundColor = .clear
    default:
      break
    }
  }
}
