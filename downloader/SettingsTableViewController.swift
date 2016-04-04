//
//  SettingsTableViewController.swift
//  downloader
//
//  Created by Thiago Peres on 30/03/16.
//  Copyright © 2016 peres. All rights reserved.
//

import UIKit
import MessageUI

class SettingsTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    
    func actionReportBug() {
        if MFMailComposeViewController.canSendMail() {
            let emailVC = MFMailComposeViewController()
            let debugString = ""
            emailVC.setSubject("Bug Report")
            emailVC.setToRecipients(["test@test.com"])
            emailVC.mailComposeDelegate = self
            emailVC.setMessageBody(debugString, isHTML: false)
            presentViewController(emailVC, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: NSLocalizedString("settings.EmailErrorAlertTitle", comment: ""),
                                          message: NSLocalizedString("settings.EmailErrorAlertMessage", comment: ""),
                                          preferredStyle: UIAlertControllerStyle.Alert)
            let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            })
            alert.addAction(ok)
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func actionReviewOnAppStore() {
        let url = NSURL(string: "http://www.test.com")!
        
        if UIApplication.sharedApplication().canOpenURL(url) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        //
        // Handles cell taps to appropriate actions
        //
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if cell?.reuseIdentifier == "reportBug" {
            actionReportBug()
        } else if cell?.reuseIdentifier == "reviewOnAppStore" {
            actionReviewOnAppStore()
        }
    }
    
    // MARK: - MFMailComposeViewControllerDelegate
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}
