//
//  ContactUsViewController.swift
//  MHW
//
//  Created by Jeff Eom on 2018-04-15.
//  Copyright © 2018 Jeff Eom. All rights reserved.
//

import UIKit
import MessageUI

class ContactUsViewController: UIViewController {
  static let identifier = "contactUsVC"
  @IBOutlet weak var contentShadowView: UIView!
  @IBOutlet weak var contentView: UIView!
  @IBOutlet weak var helpAttributedText: UILabel!
  override func viewDidLoad() {
    super.viewDidLoad()
    createRoundShadowView(withShadowView: contentShadowView, andContentView: contentView, withCornerRadius: 8, withOpacity: 0.25)
  }
  
  @IBAction func pressedHelpSupport(_ sender: UIButton) {
    let email = "mhworldapp@gmail.com"
    let title = "Help & Support"
    let mailComposeViewController = configuredMailComposeViewController(email: email, title: title)
    if MFMailComposeViewController.canSendMail() {
      self.present(mailComposeViewController, animated: true, completion: nil)
    }
  }
}

//MARK: MailDelegate
extension ContactUsViewController: MFMailComposeViewControllerDelegate {
  func configuredMailComposeViewController(email: String, title: String) -> MFMailComposeViewController {
    let mailComposerVC = MFMailComposeViewController()
    mailComposerVC.mailComposeDelegate = self
    mailComposerVC.setToRecipients([email])
    mailComposerVC.setSubject(title)
    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
      mailComposerVC.setMessageBody("\n\n\n\n\n\n\n\n\nversion:\(version)", isHTML: false)
    }
    return mailComposerVC
  }
  
  func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
    switch result {
    case .cancelled:
      print("Mail cancelled")
    case .saved:
      print("Mail saved")
    case .sent:
      print("Mail sent")
    case .failed:
      print("Mail sent failure: \(String(describing: error?.localizedDescription))")
    }
    self.dismiss(animated: true, completion: nil)
  }
}
