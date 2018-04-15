//
//  ViewController.swift
//  MHW
//
//  Created by Jeff Eom on 2018-04-10.
//  Copyright © 2018 Jeff Eom. All rights reserved.
//

import UIKit
import CoreData

class MeldingListTableViewController: UIViewController {
  @IBOutlet weak var meldingListCollectionView: UICollectionView!
  var currentStatus: CurrentStatus = CurrentStatus(currentRow: nil, currentOrderList: .notSet)
  var gemLists: [GemList] = []
  var orderLists: [OrderList] = []
  
  var gemListToAdd: GemList?
  
  var savedArray = SavedArray(context: PersistenceService.context)
  
  var selectedIndexPath: IndexPath?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    meldingListCollectionView.scrollIndicatorInsets = UIEdgeInsetsMake(-10, 0, -10, -10)
    meldingListCollectionView.reloadData()
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
      savedArray = savedArrays[0]
      guard let gemLists = savedArray.gemLists, let orderLists = savedArray.orders else { return }
      self.gemLists = Array(gemLists) as! [GemList]
      let orders = Array(orderLists) as! [Order]
      self.orderLists =  orders.compactMap({ OrderList.from(string: $0.number!) })
      if orderLists.count == 0 {
        currentStatus = CurrentStatus(currentRow: Int(savedArray.currentRow), currentOrderList: .notSet)
      }else {
        currentStatus = CurrentStatus(currentRow: Int(savedArray.currentRow), currentOrderList: self.orderLists[Int(savedArray.currentRow)])
      }
      meldingListCollectionView.reloadData()
    }catch {
      print(error.localizedDescription)
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if let gemListToAdd = gemListToAdd {
      gemLists.append(gemListToAdd)
      savedArray.addToGemLists(gemListToAdd)
      if orderLists.isEmpty {
        orderLists.append(.order1_1)
        let theOrder = Order(context: PersistenceService.context)
        theOrder.number = OrderList.order1_1.text()
        savedArray.addToOrders(theOrder)
      }else {
        orderLists.append((orderLists.last?.next())!)
        let theOrder = Order(context: PersistenceService.context)
        theOrder.number = orderLists.last?.text()
        savedArray.addToOrders(theOrder)
      }
      self.gemListToAdd = nil
      if gemLists.count == 1 {
        self.currentStatus = CurrentStatus(currentRow: 0, currentOrderList: .order1_1)
        savedArray.currentRow = 0
      }
      PersistenceService.saveContext()
      meldingListCollectionView.reloadData()
    }
  }
}


//MARK: Setup
extension MeldingListTableViewController {
  func changeLabelToMelded() {
    // 1.1 1.2 M 2 2 1.1 1.2 2 2
    if let currentRow = currentStatus.currentRow {
      guard currentRow < orderLists.count else {
        let alertController = UIAlertController(title: "Try again", message: "Need to add in more lists.", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
        return
      }
      orderLists.insert(.melded, at: currentRow)
      orderLists.removeLast()
      let meldOrder = Order(context: PersistenceService.context)
      meldOrder.number = "MELDED"
      savedArray.insertIntoOrders(meldOrder, at: currentRow)
      savedArray.removeFromOrders(at: (savedArray.orders?.count)! - 1)
      PersistenceService.saveContext()
      meldingListCollectionView.reloadData()
    }else {
      let alert = UIAlertController(title: "Error", message: "Please try again.", preferredStyle: .alert)
      present(alert, animated: true, completion: nil)
    }
  }
}

//MARK: IBActions
extension MeldingListTableViewController {
  @IBAction func pressedSettingButton(_ sender: UIBarButtonItem) {
    deleteAllData()
    meldingListCollectionView.reloadData()
  }
  
  @IBAction func pressedMeldSkip(_ sender: UIButton) {
    if let currentRow = currentStatus.currentRow {
      guard currentRow + 1 < orderLists.count else {
        let alertController = UIAlertController(title: "Try again", message: "Need to add in more lists.", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
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
      let alertController = UIAlertController(title: "Try again", message: "Need to add in more lists.", preferredStyle: .alert)
      let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
      alertController.addAction(defaultAction)
      present(alertController, animated: true, completion: nil)
    }
  }
  
  @IBAction func pressedQuestSkip(_ sender: UIButton) {
    if let currentRow = currentStatus.currentRow {
      guard !orderLists.isEmpty else {
        let alertController = UIAlertController(title: "Try again", message: "Need to add in more lists.", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
        return
      }
      currentStatus.currentOrderList = orderLists[currentRow]
      switch currentStatus.currentOrderList {
      case .order1_1, .order1_2:
        guard currentRow + 1 < orderLists.count else {
          let alertController = UIAlertController(title: "Try again", message: "Need to add in more lists.", preferredStyle: .alert)
          let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
          alertController.addAction(defaultAction)
          present(alertController, animated: true, completion: nil)
          return
        }
        currentStatus.currentRow = currentRow + 1
      case .order2_1:
        if orderLists[currentRow - 1] == .order2_1 {
          guard currentRow + 1 < orderLists.count else {
            let alertController = UIAlertController(title: "Try again", message: "Need to add in more lists.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            present(alertController, animated: true, completion: nil)
            return
          }
          currentStatus.currentRow = currentRow + 1
        }else {
          guard currentRow + 2 < orderLists.count else {
            let alertController = UIAlertController(title: "Try again", message: "Need to add in more lists.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            present(alertController, animated: true, completion: nil)
            return
          }
          currentStatus.currentRow = currentRow + 2
        }
      case .order2_2:
        guard currentRow + 1 < orderLists.count else {
          let alertController = UIAlertController(title: "Try again", message: "Need to add in more lists.", preferredStyle: .alert)
          let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
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
      let alertController = UIAlertController(title: "Try again", message: "Need to add in more lists.", preferredStyle: .alert)
      let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
      alertController.addAction(defaultAction)
      present(alertController, animated: true, completion: nil)
    }
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
      cell.gemLabel.text = gemLists[indexPath.section].firstGem
    case 1:
      cell.gemLabel.text = gemLists[indexPath.section].secondGem
    case 2:
      cell.gemLabel.text = gemLists[indexPath.section].thirdGem
    default:
      break
    }
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let cell = collectionView.cellForItem(at: indexPath) as! MeldingCell
    if cell.cellIsSelected {
      cell.isSelected = false
      cell.cellIsSelected = false
    }else {
      cell.isSelected = true
      cell.cellIsSelected = true
    }
    cell.layoutIfNeeded()
  }
  
  func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    let cell = collectionView.cellForItem(at: indexPath) as! MeldingCell
    cell.isSelected = false
    cell.cellIsSelected = false
    cell.layoutIfNeeded()
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
    view.orderNumberLabel.text = orderLists[indexPath.section].text()
    return view
  }
  
  func deleteAllData(){
    let managedContext = PersistenceService.persistentContainer.viewContext
    let deleteGemList = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: "GemList"))
    let deleteOrder = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: "Order"))
    let deleteSavedArray = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: "SavedArray"))
    do {
      try managedContext.execute(deleteGemList)
      try managedContext.execute(deleteOrder)
      try managedContext.execute(deleteSavedArray)
    }
    catch {
      print(error)
    }
  }
}

//MARK: DelegatePatters
extension MeldingListTableViewController: MeldingTitleViewDelgate, CellPopupDelegate {
  func pressedSetting(rv: UICollectionReusableView) {
    let popupSetupVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "popupSetupVC") as! PopupSetupViewController
    popupSetupVC.delegate = self
    modalPresentationStyle = .overCurrentContext
    selectedIndexPath = IndexPath(item: 0, section: rv.tag)
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
      let alertController = UIAlertController(title: "Missing Order", message: "This row cannot be set as a current row.\n\nTry setting the order first, then try again.", preferredStyle: .alert)
      let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
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
