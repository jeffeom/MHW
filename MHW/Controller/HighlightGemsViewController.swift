//
//  HighlightGemsViewController.swift
//  MHW
//
//  Created by Jeff Eom on 2018-04-21.
//  Copyright © 2018 Jeff Eom. All rights reserved.
//

import UIKit
import CoreData
import GoogleMobileAds

class HighlightGemsViewController: UIViewController {
  static let identifier = "highlightGemsVC"
  @IBOutlet weak var gemListTableView: UITableView!
  @IBOutlet weak var viewBottomConstraintForBanner: NSLayoutConstraint!
  @IBOutlet weak var bannerView: GADBannerView!
  
  let hangulSystem = YKHangul()
  var gemsArray: [String] = []
  var alphabetDict: [String: [String]] = [:]
  var sortedKeysInDict: [String] = []
  var gemsToHighlight: [String] = []
  
  var gemHighlightList = GemHighlightList(context: PersistenceService.context)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    automaticallyAdjustsScrollViewInsets = false
    title = "Highlight Gems".localized()
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
    fetchGemssFromJSON()
    let gemHighlightListFetchRequest: NSFetchRequest<GemHighlightList> = GemHighlightList.fetchRequest()
    do {
      var gemHighlightLists = try PersistenceService.context.fetch(gemHighlightListFetchRequest)
      if gemHighlightLists.count > 1 {
        let arraysToErase = gemHighlightLists.filter({ $0.gems?.count == 0 })
        for anArrayToErase in arraysToErase {
          PersistenceService.context.delete(anArrayToErase as NSManagedObject)
          gemHighlightLists.remove(at: gemHighlightLists.index(of: anArrayToErase)!)
          PersistenceService.saveContext()
        }
      }
      if !gemHighlightLists.isEmpty {
        gemHighlightList = gemHighlightLists[0]
        let gemsArray = Array(gemHighlightList.gems ?? []) as! [Gem]
        self.gemsToHighlight = gemsArray.compactMap({ $0.name ?? "" })
        gemListTableView.reloadData()
      }else {
        gemHighlightList = GemHighlightList(context: PersistenceService.context)
        gemListTableView.reloadData()
      }
    }catch {
      print(error.localizedDescription)
    }
  }
}

//MARK: IBActions
extension HighlightGemsViewController {
  @IBAction func pressedSaveButton(_ sender: UIBarButtonItem) {
    self.deleteAllData()
    for i in 0..<gemsToHighlight.count {
      let gem = Gem(context: PersistenceService.context)
      gem.name = gemsToHighlight[i]
      gemHighlightList.addToGems(gem)
    }
    PersistenceService.saveContext()
    let alert = UIAlertController(title: "", message: "Saved successfully".localized(), preferredStyle: .alert)
    self.present(alert, animated: true, completion: nil)
    let when = DispatchTime.now() + 2
    DispatchQueue.main.asyncAfter(deadline: when){
      alert.dismiss(animated: true, completion: {
        self.navigationController?.popViewController(animated: true)
      })
    }
  }
  
  @IBAction func pressedResetButton(_ sender: UIButton) {
    let alertController = UIAlertController(title: "Reset?".localized(), message: "Do you want to start from the beginning?".localized(), preferredStyle: .alert)
    let resetAction = UIAlertAction(title: "Reset".localized(), style: .destructive) { (_) in
      print("reset")
      self.deleteAllData()
      self.gemsToHighlight = []
      self.gemListTableView.reloadData()
    }
    let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil)
    alertController.addAction(resetAction)
    alertController.addAction(cancelAction)
    present(alertController, animated: true, completion: nil)
  }
  
  fileprivate func deleteAllData(){
    let count = (gemHighlightList.gems?.count ?? 0)
    for _ in 0..<count {
      gemHighlightList.removeFromGems(at: 0)
    }
    PersistenceService.saveContext()
  }
}

//MARK: Setup
extension HighlightGemsViewController {
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

//MARK: UITableViewDelegate & Datasource
extension HighlightGemsViewController: UITableViewDelegate, UITableViewDataSource {
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
    if gemsToHighlight.contains((alphabetDict[sortedKeysInDict[indexPath.section]]?[indexPath.row])!) {
      cell.accessoryType = .checkmark
      cell.isSelected = true
    }else {
      cell.accessoryType = .none
      cell.isSelected = false
    }
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let cell = tableView.cellForRow(at: indexPath)
    guard let theGem = cell?.textLabel?.text else { return }
    if cell?.accessoryType == .checkmark {
      if gemsToHighlight.contains(theGem) {
        guard let ip = gemsToHighlight.index(of: theGem) else { return }
        gemsToHighlight.remove(at: ip)
        cell?.accessoryType = .none
      }
    }else if cell?.accessoryType == UITableViewCellAccessoryType.none {
      if !gemsToHighlight.contains(theGem) {
        gemsToHighlight.append(theGem)
        cell?.accessoryType = .checkmark
      }
    }
  }
  
  func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    let cell = tableView.cellForRow(at: indexPath)
    guard let theGem = cell?.textLabel?.text else { return }
    if cell?.accessoryType == .checkmark {
      if gemsToHighlight.contains(theGem) {
        guard let ip = gemsToHighlight.index(of: theGem) else { return }
        gemsToHighlight.remove(at: ip)
        cell?.accessoryType = .none
      }
    }else if cell?.accessoryType == UITableViewCellAccessoryType.none {
      if !gemsToHighlight.contains(theGem) {
        gemsToHighlight.append(theGem)
        cell?.accessoryType = .checkmark
      }
    }
  }
}
