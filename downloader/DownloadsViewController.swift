//
//  MasterViewController.swift
//  downloader
//
//  Created by Thiago Peres on 23/02/16.
//  Copyright © 2016 peres. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift
import QuickLook

class DownloadsViewController: UITableViewController, UIPopoverPresentationControllerDelegate, QLPreviewControllerDataSource {

    let realm = try! Realm()
    var token:NotificationToken?
    var downloads:Results<Download>?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        token = realm.objects(Download).addNotificationBlock { (results, error) -> () in
            self.downloads = results
            self.tableView.reloadData()
        }
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
        
        self.downloads = realm.objects(Download)
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        token!.stop()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "popoverSegue" {
            let vc = segue.destinationViewController
            vc.modalPresentationStyle = .Popover
            vc.popoverPresentationController?.delegate = self
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if downloads == nil {
            return 0
        }
        return downloads!.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! DownloadTableViewCell
        cell.setDownload(downloads![indexPath.row])
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if QLPreviewController.canPreviewItem((downloads!.first?.fileURL)!) {
            let previewQL = QLPreviewController()
            previewQL.dataSource = self
            showViewController(previewQL, sender: self)
        }
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let downloadObj = downloads![indexPath.row]
            do {
                if (downloadObj.fileURLString != nil) {
                    try NSFileManager.defaultManager().removeItemAtPath(downloadObj.fileURL.path!)
                }
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
            try! realm.write {
                realm.delete(downloadObj)
            }
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    // MARK: - UIPopoverPresentationControllerDelegate

    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    // MARK: - QLPreviewControllerDataSource
    
    func previewController(controller: QLPreviewController, previewItemAtIndex index: Int) -> QLPreviewItem {
        print("\(downloads![index].fileURL)")
        return downloads![index].fileURL
    }
    
    func numberOfPreviewItemsInPreviewController(controller: QLPreviewController) -> Int {
        return downloads!.count;
    }
}

