//
//  AddGemsViewController.swift
//  MHW
//
//  Created by Jeff Eom on 2018-04-10.
//  Copyright © 2018 Jeff Eom. All rights reserved.
//

import UIKit
import GoogleMobileAds

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
  @IBOutlet weak var bannerView: GADBannerView!
  @IBOutlet weak var viewBottomConstraintForBanner: NSLayoutConstraint!
  
  static let identifier = "addGemsVC"
  let hangulSystem = YKHangul()
  
  var gemsArray: [String] = []
  var alphabetDict: [String: [String]] = [:]
  var sortedKeysInDict: [String] = []
  
  var indexPathSelected: IndexPath?
  
  var editMode = false
  var savedArray = SavedArray(context: PersistenceService.context)
  
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
    title = "Add Gems".localized()
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
    appearance()
    fetchGemssFromJSON()
    currentGemSelected = 0
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    let purchased = UserDefaults.standard.value(forKey: "purchasedAdsRemoval") as? Bool ?? false
    if purchased {
      bannerView.isHidden = true
      viewBottomConstraintForBanner.constant = 0
    }
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
    let alertController = UIAlertController(title: "Reset?".localized(), message: "Do you want to start from the beginning?".localized(), preferredStyle: .alert)
    let resetAction = UIAlertAction(title: "Reset".localized(), style: .destructive) { (_) in
      print("reset")
      self.firstGemButton.setTitle("X", for: .normal)
      self.secondGemButton.setTitle("X", for: .normal)
      self.thirdGemButton.setTitle("X", for: .normal)
    }
    let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil)
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
    if editMode {
      guard let section = indexPathSelected?.section else { return }
      previousVC.gemToReplace = gemList
      previousVC.gemEditSection = section
      PersistenceService.saveContext()
      navigationController?.popToViewController(previousVC, animated: true)
    }else {
      previousVC.gemListToAdd = gemList
      PersistenceService.saveContext()
      navigationController?.popToViewController(previousVC, animated: true)
    }
  }
}

//MARK: Setup
extension AddGemsViewController {
  func appearance() {
    createRoundShadowView(withShadowView: firstGemContentShadowView, andContentView: firstGemContentView, withCornerRadius: 8, withOpacity: 0.25)
    createRoundShadowView(withShadowView: secondGemContentShadowView, andContentView: secondGemContentView, withCornerRadius: 8, withOpacity: 0.25)
    createRoundShadowView(withShadowView: thirdGemContentShadowView, andContentView: thirdGemContentView, withCornerRadius: 8, withOpacity: 0.25)
  }
  
  func fetchGemssFromJSON() {
    if let path = Bundle.main.path(forResource: "gem_en".localized(), ofType: "json") {
      do {
        let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
        if let jsonResult = jsonResult as? [String: AnyObject], let gemDictArray = jsonResult["gem"] as? [[String: AnyObject]] {
          // do stuff
          for aGemDict in gemDictArray {
            let gem = aGemDict["name"] as! String
            gemsArray.append(gem)
            var initialLetter = String(gem.uppercased().first ?? " ".first!)
            let currentLang = UserDefaults.standard.array(forKey: "AppleLanguages")?.first as? String
            if (currentLang?.contains("ko") ?? false) {
              initialLetter = hangulSystem.getStringConsonant(string: String(gem.first ?? " ".first!), consonantType: .Initial)
            }
            var letterArray = alphabetDict[initialLetter] ?? [String]()
            letterArray.append(gem)
            alphabetDict[initialLetter] = letterArray
            sortedKeysInDict = Array(alphabetDict.keys).sorted(by: <)
            gemListTableView.reloadData()
          }
        }
      } catch {
        print(error.localizedDescription)
      }
    }
  }
}

//MARK: UITableViewDelegate & DataSource
extension AddGemsViewController: UITableViewDelegate, UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return sortedKeysInDict.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return alphabetDict[sortedKeysInDict[section]]?.count ?? 0
  }
  
  func sectionIndexTitles(for tableView: UITableView) -> [String]? {
    return sortedKeysInDict
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return sortedKeysInDict[section]
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell(style: .default, reuseIdentifier: "gemCell")
    cell.textLabel?.font = UIFont(name: "Avenir", size: 18)
    cell.textLabel?.textColor = UIColor(red: 67/255, green: 61/255, blue: 63/255, alpha: 1.0)
    cell.textLabel?.text = alphabetDict[sortedKeysInDict[indexPath.section]]?[indexPath.row]
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
