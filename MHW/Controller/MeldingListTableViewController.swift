//
//  ViewController.swift
//  MHW
//
//  Created by Jeff Eom on 2018-04-10.
//  Copyright © 2018 Jeff Eom. All rights reserved.
//

import UIKit
import CoreData
import Localize_Swift
import GoogleMobileAds
import SwiftyStoreKit

class MeldingListTableViewController: UIViewController {
  @IBOutlet weak var meldingListCollectionView: UICollectionView!
  @IBOutlet weak var bannerView: GADBannerView!
  @IBOutlet weak var viewBottomConstraintForBanner: NSLayoutConstraint!
  var currentStatus: CurrentStatus = CurrentStatus(currentRow: nil, currentOrderList: .notSet)
  var gemLists: [GemList] = []
  var orderLists: [OrderList] = []
  var gemListToAdd: GemList?
  var gemToReplace: GemList?
  var gemEditSection: Int?
  var gemsToHighlight: [String] = []
  var gemHighlightList = GemHighlightList(context: PersistenceService.context)
  var savedArray = SavedArray(context: PersistenceService.context)
  var selectedIndexPath: IndexPath?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    automaticallyAdjustsScrollViewInsets = false
    verifyPurchase()
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
    meldingListCollectionView.scrollIndicatorInsets = UIEdgeInsetsMake(-10, 0, -10, -10)
    meldingListCollectionView.reloadData()
    fetchSavedArray()
    fetchGemHighlightList()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    let purchased = UserDefaults.standard.value(forKey: "purchasedAdsRemoval") as? Bool ?? false
    if purchased {
      bannerView.isHidden = true
      viewBottomConstraintForBanner.constant = 0
    }
    fetchGemHighlightList()
    if let gemListToAdd = gemListToAdd {
      if savedArray.gemLists == nil {
        savedArray.gemLists = NSOrderedSet(array: [])
        savedArray.addToGemLists(gemListToAdd)
      }else {
        savedArray.addToGemLists(gemListToAdd)
      }
      gemLists.append(gemListToAdd)
      if gemListToAdd.savedArray == nil {
        gemListToAdd.savedArray = SavedArray(context: PersistenceService.context)
      }

      let theOrder = Order(context: PersistenceService.context)
      if savedArray.orders == nil {
        savedArray.orders = NSOrderedSet(array: [])
        savedArray.addToOrders(theOrder)
      }else {
        savedArray.addToOrders(theOrder)
      }
      if orderLists.isEmpty {
        orderLists.append(.order1_1)
        theOrder.number = OrderList.order1_1.text()
        if theOrder.savedArray == nil {
          theOrder.savedArray = SavedArray(context: PersistenceService.context)
        }
      }else {
        orderLists.append((orderLists.last?.next())!)
        theOrder.number = orderLists.last?.text()
        savedArray.addToOrders(theOrder)
      }
      if gemLists.count == 1 {
        self.currentStatus = CurrentStatus(currentRow: 0, currentOrderList: .order1_1)
        savedArray.currentRow = 0
      }
      PersistenceService.saveContext()
      meldingListCollectionView.reloadData()
      meldingListCollectionView.scrollToItem(at: IndexPath(item: 0, section: gemLists.count - 1), at: .top, animated: true)
      self.gemListToAdd = nil
    }else if let gemToReplace = gemToReplace, let gemEditSection = gemEditSection {
      gemLists.remove(at: gemEditSection)
      gemLists.insert(gemToReplace, at: gemEditSection)
      savedArray.replaceGemLists(at: gemEditSection, with: gemToReplace)
      PersistenceService.saveContext()
      meldingListCollectionView.reloadData()
    }
  }
}


//MARK: Setup
extension MeldingListTableViewController {
  func fetchSavedArray() {
    let savedArrayFetchRequest: NSFetchRequest<SavedArray> = SavedArray.fetchRequest()
    do {
      var savedArrays = try PersistenceService.context.fetch(savedArrayFetchRequest)
      if savedArrays.count > 1 {
        let arraysToErase = savedArrays.filter({ $0.gemLists?.count == 0 })
        for anArrayToErase in arraysToErase {
          PersistenceService.context.delete(anArrayToErase as NSManagedObject)
          savedArrays.remove(at: savedArrays.index(of: anArrayToErase)!)
          PersistenceService.saveContext()
        }
      }
      if !savedArrays.isEmpty {
        savedArray = savedArrays[0]
        self.gemLists = Array(savedArray.gemLists ?? []) as! [GemList]
        let orders = Array(savedArray.orders ?? []) as! [Order]
        self.orderLists =  orders.compactMap({ OrderList.from(string: $0.number!) })
        if orderLists.count == 0 {
          currentStatus = CurrentStatus(currentRow: Int(savedArray.currentRow), currentOrderList: .notSet)
        }else {
          currentStatus = CurrentStatus(currentRow: Int(savedArray.currentRow), currentOrderList: self.orderLists[Int(savedArray.currentRow)])
        }
        meldingListCollectionView.reloadData()
      }else {
        savedArray = SavedArray(context: PersistenceService.context)
        meldingListCollectionView.reloadData()
      }
    }catch {
      print(error.localizedDescription)
    }
  }
  
  func fetchGemHighlightList() {
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
        meldingListCollectionView.reloadData()
      }else {
        gemHighlightList = GemHighlightList(context: PersistenceService.context)
        meldingListCollectionView.reloadData()
      }
    }catch {
      print(error.localizedDescription)
    }
  }
  
  func verifyPurchase() {
    let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: Key.sharedSecret)
    SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
      switch result {
      case .success(let receipt):
        let productId = "adRemoval"
        // Verify the purchase of Consumable or NonConsumable
        let purchaseResult = SwiftyStoreKit.verifyPurchase(
          productId: productId,
          inReceipt: receipt)
        
        switch purchaseResult {
        case .purchased(let receiptItem):
          print("\(productId) is purchased: \(receiptItem)")
        case .notPurchased:
          print("The user has never purchased \(productId)")
        }
      case .error(let error):
        print("Receipt verification failed: \(error)")
      }
    }
  }
  
  func changeLabelToMelded() {
    // 1.1 1.2 M 2 2 1.1 1.2 2 2
    if let currentRow = currentStatus.currentRow {
      guard currentRow < orderLists.count else {
        let alertController = UIAlertController(title: "Try again".localized(), message: "Need to add in more lists.".localized(), preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK".localized(), style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
        return
      }
      orderLists.insert(.melded, at: currentRow)
      orderLists.removeLast()
      let meldOrder = Order(context: PersistenceService.context)
      meldOrder.number = "MELDED".localized()
      savedArray.insertIntoOrders(meldOrder, at: currentRow)
      savedArray.removeFromOrders(at: (savedArray.orders?.count)! - 1)
      PersistenceService.saveContext()
      meldingListCollectionView.reloadData()
    }else {
      let alert = UIAlertController(title: "Error".localized(), message: "Please try again.".localized(), preferredStyle: .alert)
      present(alert, animated: true, completion: nil)
    }
  }
}

//MARK: IBActions
extension MeldingListTableViewController: ResetDelegate {
  @IBAction func pressedSettingButton(_ sender: UIButton) {
    let settingsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "settingsVC") as! SettingsViewController
    settingsVC.delegate = self
    navigationController?.pushViewController(settingsVC, animated: true)
  }
  
  @IBAction func pressedMeldSkip(_ sender: UIButton) {
    if let currentRow = currentStatus.currentRow {
      guard currentRow + 1 < orderLists.count else {
        let alertController = UIAlertController(title: "Try again".localized(), message: "Need to add in more lists.".localized(), preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK".localized(), style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
        return
      }
      changeLabelToMelded()
      currentStatus.currentRow = currentRow + 1
      currentStatus.currentOrderList = .melded
      savedArray.currentRow = Int64(currentStatus.currentRow ?? 0)
      PersistenceService.saveContext()
    }else {
      let alertController = UIAlertController(title: "Try again".localized(), message: "Need to add in more lists.".localized(), preferredStyle: .alert)
      let defaultAction = UIAlertAction(title: "OK".localized(), style: .default, handler: nil)
      alertController.addAction(defaultAction)
      present(alertController, animated: true, completion: nil)
    }
  }
  
  @IBAction func pressedQuestSkip(_ sender: UIButton) {
    if let currentRow = currentStatus.currentRow {
      guard !orderLists.isEmpty else {
        let alertController = UIAlertController(title: "Try again".localized(), message: "Need to add in more lists.".localized(), preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK".localized(), style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
        return
      }
      currentStatus.currentOrderList = orderLists[currentRow]
      switch currentStatus.currentOrderList {
      case .order1_1, .order1_2:
        guard currentRow + 1 < orderLists.count else {
          let alertController = UIAlertController(title: "Try again".localized(), message: "Need to add in more lists.".localized(), preferredStyle: .alert)
          let defaultAction = UIAlertAction(title: "OK".localized(), style: .default, handler: nil)
          alertController.addAction(defaultAction)
          present(alertController, animated: true, completion: nil)
          return
        }
        currentStatus.currentRow = currentRow + 1
      case .order2_1:
        if currentRow == 0 {
          guard currentRow + 2 < orderLists.count else {
            let alertController = UIAlertController(title: "Try again".localized(), message: "Need to add in more lists.".localized(), preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK".localized(), style: .default, handler: nil)
            alertController.addAction(defaultAction)
            present(alertController, animated: true, completion: nil)
            return
          }
          currentStatus.currentRow = currentRow + 2
        }else {
          if orderLists[currentRow - 1] == .order2_1 {
            guard currentRow + 1 < orderLists.count else {
              let alertController = UIAlertController(title: "Try again".localized(), message: "Need to add in more lists.".localized(), preferredStyle: .alert)
              let defaultAction = UIAlertAction(title: "OK".localized(), style: .default, handler: nil)
              alertController.addAction(defaultAction)
              present(alertController, animated: true, completion: nil)
              return
            }
            currentStatus.currentRow = currentRow + 1
          }else {
            guard currentRow + 2 < orderLists.count else {
              let alertController = UIAlertController(title: "Try again".localized(), message: "Need to add in more lists.".localized(), preferredStyle: .alert)
              let defaultAction = UIAlertAction(title: "OK".localized(), style: .default, handler: nil)
              alertController.addAction(defaultAction)
              present(alertController, animated: true, completion: nil)
              return
            }
            currentStatus.currentRow = currentRow + 2
          }
        }
      case .order2_2:
        guard currentRow + 1 < orderLists.count else {
          let alertController = UIAlertController(title: "Try again".localized(), message: "Need to add in more lists.".localized(), preferredStyle: .alert)
          let defaultAction = UIAlertAction(title: "OK".localized(), style: .default, handler: nil)
          alertController.addAction(defaultAction)
          present(alertController, animated: true, completion: nil)
          return
        }
        currentStatus.currentRow = currentRow + 1
      case .melded:
        break
      case .notSet:
        break
      }
      savedArray.currentRow = Int64(currentStatus.currentRow ?? 0)
      PersistenceService.saveContext()
      meldingListCollectionView.reloadData()
    }else {
      let alertController = UIAlertController(title: "Try again".localized(), message: "Need to add in more lists.".localized(), preferredStyle: .alert)
      let defaultAction = UIAlertAction(title: "OK".localized(), style: .default, handler: nil)
      alertController.addAction(defaultAction)
      present(alertController, animated: true, completion: nil)
    }
  }
  
  func resetPressed() {
    deleteAllData()
    gemLists = []
    orderLists = []
    meldingListCollectionView.reloadData()
  }
  
  func deleteAllData(){
    let count = (savedArray.gemLists?.count ?? 0)
    for _ in 0..<count {
      savedArray.removeFromGemLists(at: 0)
      savedArray.removeFromOrders(at: 0)
    }
    PersistenceService.saveContext()
  }
}

//MARK: CVDelegate & Datasource
extension MeldingListTableViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return gemLists.count
  }
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 3
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MeldingCell.identifier, for: indexPath) as! MeldingCell
    switch indexPath.item {
    case 0:
      cell.gemLabel.text = gemLists[indexPath.section].firstGem?.components(separatedBy: " Jewel").first
    case 1:
      cell.gemLabel.text = gemLists[indexPath.section].secondGem?.components(separatedBy: " Jewel").first
    case 2:
      cell.gemLabel.text = gemLists[indexPath.section].thirdGem?.components(separatedBy: " Jewel").first
    default:
      break
    }
    let currentLang = UserDefaults.standard.array(forKey: "AppleLanguages")?.first as? String
    if (currentLang?.contains("ko") ?? false) {
      cell.cellIsSelected = gemsToHighlight.contains(cell.gemLabel.text ?? "")
    }else {
      cell.cellIsSelected = gemsToHighlight.contains((cell.gemLabel.text ?? "") + " Jewel")

    }
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: collectionView.bounds.width / 3 - 10, height: 50)
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: MeldingTitleView.identifier, for: indexPath) as! MeldingTitleView
    view.delegate = self
    view.tag = indexPath.section
    if let currentRow = currentStatus.currentRow {
      view.currentRowLabel.isHidden = currentRow != indexPath.section
    }else {
      view.currentRowLabel.isHidden = true
    }
    guard !orderLists.isEmpty else { return view }
    view.orderNumberLabel.text = orderLists[indexPath.section].text()
    return view
  }
}

//MARK: DelegatePatters
extension MeldingListTableViewController: MeldingTitleViewDelgate, CellPopupDelegate {
  func pressedSetting(rv: UICollectionReusableView) {
    let popupSetupVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "popupSetupVC") as! PopupSetupViewController
    popupSetupVC.delegate = self
    modalPresentationStyle = .overCurrentContext
    selectedIndexPath = IndexPath(item: 0, section: rv.tag)
    popupSetupVC.indexPathSelected = selectedIndexPath
    navigationController?.present(popupSetupVC, animated: true, completion: nil)
  }
  
  func pressed1_1() {
    guard let section = selectedIndexPath?.section else { return }
    orderLists[section] = .order1_1
    for i in 0..<section {
      orderLists[i] = .notSet
    }
    if section + 1 < orderLists.count {
      for j in (section + 1)..<orderLists.count {
        if j != 0 {
          if orderLists[j - 1] == .notSet || orderLists[j - 1] == .melded {
            orderLists[j] = .notSet
          }else {
            orderLists[j] = orderLists[j - 1].next()!
          }
        }
      }
    }
    var indexCount = 0
    for anOrderList in orderLists {
      savedArray.removeFromOrders(at: indexCount)
      let anOrder = Order(context: PersistenceService.context)
      anOrder.number = anOrderList.text()
      savedArray.insertIntoOrders(anOrder, at: indexCount)
      indexCount += 1
    }
    PersistenceService.saveContext()
    meldingListCollectionView.reloadData()
    selectedIndexPath = nil
  }
  
  func pressed1_2() {
    guard let section = selectedIndexPath?.section else { return }
    orderLists[section] = .order1_2
    for i in 0..<section {
      orderLists[i] = .notSet
    }
    if section + 1 < orderLists.count {
      for j in (section + 1)..<orderLists.count {
        if j != 0 {
          if orderLists[j - 1] == .notSet || orderLists[j - 1] == .melded {
            orderLists[j] = .notSet
          }else {
            orderLists[j] = orderLists[j - 1].next()!
          }
        }
      }
    }
    var indexCount = 0
    for anOrderList in orderLists {
      savedArray.removeFromOrders(at: indexCount)
      let anOrder = Order(context: PersistenceService.context)
      anOrder.number = anOrderList.text()
      savedArray.insertIntoOrders(anOrder, at: indexCount)
      indexCount += 1
    }
    PersistenceService.saveContext()
    meldingListCollectionView.reloadData()
    selectedIndexPath = nil
  }
  
  func pressed2() {
    guard let section = selectedIndexPath?.section else { return }
    orderLists[section] = .order2_1
    for i in 0..<section {
      orderLists[i] = .notSet
    }
    if section + 1 < orderLists.count {
      for j in (section + 1)..<orderLists.count {
        if j != 0 {
          if orderLists[j - 1] == .notSet || orderLists[j - 1] == .melded {
            orderLists[j] = .notSet
          }else {
            orderLists[j] = orderLists[j - 1].next()!
          }
        }
      }
    }
    var indexCount = 0
    for anOrderList in orderLists {
      savedArray.removeFromOrders(at: indexCount)
      let anOrder = Order(context: PersistenceService.context)
      anOrder.number = anOrderList.text()
      savedArray.insertIntoOrders(anOrder, at: indexCount)
      indexCount += 1
    }
    PersistenceService.saveContext()
    meldingListCollectionView.reloadData()
    selectedIndexPath = nil
  }
  
  func pressedCurrentRow() {
    guard let section = selectedIndexPath?.section else { return }
    if orderLists[section] == .melded || orderLists[section] == .notSet {
      let alertController = UIAlertController(title: "Missing Order".localized(), message: "This row cannot be set as a current row.\n\nTry setting the order first, then try again.".localized(), preferredStyle: .alert)
      let defaultAction = UIAlertAction(title: "OK".localized(), style: .default, handler: nil)
      alertController.addAction(defaultAction)
      present(alertController, animated: true, completion: nil)
    }else {
      currentStatus = CurrentStatus(currentRow: section, currentOrderList: orderLists[section])
      savedArray.currentRow = Int64(section)
    }
    PersistenceService.saveContext()
    meldingListCollectionView.reloadData()
    selectedIndexPath = nil
  }
}
