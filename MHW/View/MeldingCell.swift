//
//  MeldingCell.swift
//  MHW
//
//  Created by Jeff Eom on 2018-04-10.
//  Copyright © 2018 Jeff Eom. All rights reserved.
//

import UIKit

class MeldingCell: UICollectionViewCell {
  @IBOutlet weak var cellContentShadowView: UIView!
  @IBOutlet weak var cellContentView: UIView!
  @IBOutlet weak var gemLabel: UILabel!
  
  static let identifier = "MeldingCell"
  
  var cellIsSelected: Bool = false {
    didSet {
      if cellIsSelected {
        gemLabel.backgroundColor = UIColor(red: 139/255, green: 197/255, blue: 237/255, alpha: 1.0)
        gemLabel.textColor = .white
      }else {
        gemLabel.backgroundColor = .white
        gemLabel.textColor = .black
      }
      
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    createRoundShadowView(withShadowView: cellContentShadowView, andContentView: cellContentView, withCornerRadius: 8, withOpacity: 0.25)
  }
}
