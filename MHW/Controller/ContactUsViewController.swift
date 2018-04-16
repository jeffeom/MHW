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
  @IBOutlet weak var helpTitleText: UILabel!
  @IBOutlet weak var helpAttributedText: UILabel!
  @IBOutlet weak var feelFreeText: UILabel!
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Contact Us".localized()
    helpTitleText.text = "Help & Support".localized()
    helpAttributedText.text = "If you have any questions or concerns about the app contact us at: mhworldapp@gmail.com"
    let currentLang = UserDefaults.standard.array(forKey: "AppleLanguages")?.first as? String
    if (currentLang?.contains("ko") ?? false) {
      let helpAttributedString = NSMutableAttributedString(string: "앱 관련 문의 사항이 있으시면 다음으로 연락하십시오: mhworldapp@gmail.com")
      helpAttributedString.addAttribute(.font, value: UIFont(name: "Avenir-Heavy", size: 13.0)!, range: NSRange(location: 30, length: 20))
      helpAttributedString.addAttribute(.foregroundColor, value: UIColor(red: 0, green: 164/255, blue: 255/255, alpha: 1.0), range: NSRange(location: 30, length: 20))
      helpAttributedText.attributedText = helpAttributedString
      feelFreeText.text = "버그 보고서 나 추천 기능에 대해서는 mhworldapp@gmail.com으로 언제든지 문의하십시오. 답장을 보내 주시면 이른 시일 내에 해결해 드리겠습니다."
    }
    createRoundShadowView(withShadowView: contentShadowView, andContentView: contentView, withCornerRadius: 8, withOpacity: 0.25)
  }
  
  @IBAction func pressedHelpSupport(_ sender: UIButton) {
    let email = "mhworldapp@gmail.com"
    let title = "Questions about the app".localized()
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
