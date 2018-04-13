//
//  UIViewController+RoundShadowView.swift
//  MHW
//
//  Created by Jeff Eom on 2018-04-10.
//  Copyright © 2018 Jeff Eom. All rights reserved.
//

import UIKit

extension UIViewController {
  func createRoundShadowView(withShadowView shadowView: UIView, andContentView contentView: UIView, withCornerRadius cornerRadius: CGFloat, withOpacity opacity: Float) {
    shadowView.backgroundColor = .clear
    shadowView.layer.shadowColor = UIColor.black.cgColor
    shadowView.layer.shadowOffset = CGSize(width: 0, height: 0)
    shadowView.layer.shadowOpacity = opacity
    shadowView.layer.shadowRadius = 2
    
    contentView.backgroundColor = UIColor.white
    contentView.layer.cornerRadius = cornerRadius
    contentView.clipsToBounds = true
  }
}

extension UICollectionViewCell {
  func createRoundShadowView(withShadowView shadowView: UIView, andContentView contentView: UIView, withCornerRadius cornerRadius: CGFloat, withOpacity opacity: Float) {
    shadowView.backgroundColor = .clear
    shadowView.layer.shadowColor = UIColor.black.cgColor
    shadowView.layer.shadowOffset = CGSize(width: 0, height: 0)
    shadowView.layer.shadowOpacity = opacity
    shadowView.layer.shadowRadius = 2
    
    contentView.backgroundColor = UIColor.white
    contentView.layer.cornerRadius = cornerRadius
    contentView.clipsToBounds = true
  }
}
