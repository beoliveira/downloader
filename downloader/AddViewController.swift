//
//  AddViewController.swift
//  downloader
//
//  Created by Thiago Peres on 13/03/16.
//  Copyright © 2016 peres. All rights reserved.
//

import UIKit

protocol AddViewControllerDelegate:class {
    func didAddDownload()
}

class AddViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    weak var delegate:AddViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //
        // Check if there's an URL present in pasteboard and
        // adds it to the pasteboard
        //
        if let pasteboardURLString = UIPasteboard.generalPasteboard().string {
            if pasteboardURLString.containsString("http") {
                self.textView.text = pasteboardURLString
            }
        }
    }
    
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
        delegate?.didAddDownload()
    }
}
