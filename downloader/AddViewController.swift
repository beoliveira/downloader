//
//  AddViewController.swift
//  downloader
//
//  Created by Thiago Peres on 13/03/16.
//  Copyright © 2016 peres. All rights reserved.
//

import UIKit

class AddViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    @IBAction func clearButtonPressed(sender: AnyObject) {
        self.textView.text = ""
        self.textView.becomeFirstResponder()
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func addButtonPressed(sender: AnyObject) {
        DownloadManager.sharedInstance.addDownload(self.textView.text)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
