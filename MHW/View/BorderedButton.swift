//
//  BorderedButton.swift
//  MHW
//
//  Created by Jeff Eom on 2018-04-10.
//  Copyright © 2018 Jeff Eom. All rights reserved.
//

import UIKit

class BorderedButton: UIButton {
  override func awakeFromNib() {
    super.awakeFromNib()
    self.layer.borderColor = self.titleLabel?.textColor.cgColor
    self.layer.borderWidth = 1
    self.layer.cornerRadius = 8
    self.clipsToBounds = true
  }
}
