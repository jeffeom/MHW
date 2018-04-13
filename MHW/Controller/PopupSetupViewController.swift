//
//  PopupSetupViewController.swift
//  MHW
//
//  Created by Jeff Eom on 2018-04-10.
//  Copyright © 2018 Jeff Eom. All rights reserved.
//

import UIKit

class PopupSetupViewController: UIViewController {
  @IBOutlet var superView: UIView!
  @IBOutlet weak var contentShadowView: UIView!
  @IBOutlet weak var contentView: UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    createRoundShadowView(withShadowView: contentShadowView, andContentView: contentView, withCornerRadius: 8, withOpacity: 0.25)
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
  
  @IBAction func pressed1_1(_ sender: UIButton) {
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func pressed1_2(_ sender: UIButton) {
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func pressed2(_ sender: UIButton) {
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func pressedToSetAsCurrentRow(_ sender: UIButton) {
    dismiss(animated: true, completion: nil)
  }
}
