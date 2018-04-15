//
//  PopupSetupViewController.swift
//  MHW
//
//  Created by Jeff Eom on 2018-04-10.
//  Copyright © 2018 Jeff Eom. All rights reserved.
//

import UIKit

protocol CellPopupDelegate: class {
  func pressed1_1()
  func pressed1_2()
  func pressed2()
  func pressedCurrentRow()
}

class PopupSetupViewController: UIViewController {
  @IBOutlet var superView: UIView!
  @IBOutlet weak var contentShadowView: UIView!
  @IBOutlet weak var contentView: UIView!
  @IBOutlet weak var cancelButton: UIButton!
  
  weak var delegate: CellPopupDelegate?
  var indexPathSelected: IndexPath?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    createRoundShadowView(withShadowView: contentShadowView, andContentView: contentView, withCornerRadius: 8, withOpacity: 0.25)
    cancelButton.layer.cornerRadius = 8
    cancelButton.clipsToBounds = true
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    UIView.animate(withDuration: 0.3) {
      guard let superView = self.superView else { return }
      superView.backgroundColor = UIColor.black.withAlphaComponent(0.25)
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    guard let superView = self.superView else { return }
    superView.backgroundColor = UIColor.clear
  }
  
  
  @IBAction func pressedCancelButton(_ sender: UIButton) {
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func pressed1_1(_ sender: UIButton) {
    delegate?.pressed1_1()
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func pressed1_2(_ sender: UIButton) {
    delegate?.pressed1_2()
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func pressed2(_ sender: UIButton) {
    delegate?.pressed2()
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func pressedToEditRow(_ sender: UIButton) {
    guard let navController = self.presentingViewController as? UINavigationController else { return }
    dismiss(animated: true, completion: {
      let addGemsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: AddGemsViewController.identifier) as! AddGemsViewController
      addGemsVC.editMode = true
      addGemsVC.indexPathSelected = self.indexPathSelected
      navController.pushViewController(addGemsVC, animated: true)
    })
  }
  
  @IBAction func pressedToSetAsCurrentRow(_ sender: UIButton) {
    dismiss(animated: true, completion: nil)
    delegate?.pressedCurrentRow()
  }
}
