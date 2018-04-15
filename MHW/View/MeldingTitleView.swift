//
//  MeldingTitleView.swift
//  MHW
//
//  Created by Jeff Eom on 2018-04-10.
//  Copyright © 2018 Jeff Eom. All rights reserved.
//

import UIKit

protocol MeldingTitleViewDelgate: class {
  func pressedSetting(rv: UICollectionReusableView)
}

class MeldingTitleView: UICollectionReusableView {
  @IBOutlet weak var orderNumberLabel: UILabel!
  @IBOutlet weak var currentRowLabel: UILabel!
  
  static let identifier = "meltingTitleView"
  weak var delegate: MeldingTitleViewDelgate?
  
  @IBAction func pressedSetting(_ sender: UIButton) {
    delegate?.pressedSetting(rv: self)
  }
}
