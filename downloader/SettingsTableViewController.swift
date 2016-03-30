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
            // TODO: Notify users
        }
    }
    
    func actionReviewOnAppStore() {
        let url = NSURL(string: "")!
        
        if UIApplication.sharedApplication().canOpenURL(url) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    func shareTheApp() {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}
