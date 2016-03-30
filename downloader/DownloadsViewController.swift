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
import AVKit
import AVFoundation
import DZNEmptyDataSet

class DownloadsViewController: UITableViewController, UIPopoverPresentationControllerDelegate, QLPreviewControllerDataSource, AddViewControllerDelegate, DZNEmptyDataSetSource {

    let realm = try! Realm()
    var token:NotificationToken?
    var downloads:Results<Download>?
    var player: AVPlayer!
    
    func isMP3MIMEType(string: String) -> Bool {
        let string = string.lowercaseString
        return string == "audio/mpeg" || string == "audio/x-mpeg-3" || string == "video/mpeg" || string == "video/x-mpeg"
    }
    
    func handleOpenFileForDownloadAtIndexPath(indexPath:NSIndexPath) {
        let downloadObj = downloads![indexPath.row]
        
        if let url = downloadObj.fileURL {
            //
            // Plays MP3 files
            //
            if isMP3MIMEType(downloadObj.mimeType!) {
                //
                // Start the AVAudioSession that enables background audio playback
                //
                do {
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                    print("AVAudioSession Category Playback OK")
                    do {
                        try AVAudioSession.sharedInstance().setActive(true)
                        print("AVAudioSession is Active")
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
                
                //
                // Present the audio file
                //
                let asset = AVAsset(URL: url)
                let item = AVPlayerItem(asset: asset)
                player = AVPlayer(playerItem: item)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                presentViewController(playerViewController, animated: true) {
                    self.player.play()
                }
            }
            //
            // Preview file
            //
            else if QLPreviewController.canPreviewItem(url) {
                let previewQL = QLPreviewController()
                previewQL.dataSource = self
                previewQL.currentPreviewItemIndex = indexPath.row
                showViewController(previewQL, sender: self)
            }
        } else {
            let alert = UIAlertController(title: "Download In Progress", message: "File is still downloading", preferredStyle: UIAlertControllerStyle.Alert)
            let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            })
            alert.addAction(ok)
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        self.tableView.emptyDataSetSource = self
        self.tableView.tableFooterView = UIView()
        
        token = realm.objects(Download).addNotificationBlock { (results, error) -> () in
            self.downloads = results
            self.tableView.reloadData()
        }
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
        
        downloads = realm.objects(Download)
        tableView.reloadData()
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
            let vc = segue.destinationViewController as! AddViewController
            vc.modalPresentationStyle = .Popover
            vc.popoverPresentationController?.delegate = self
            vc.delegate = self
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
        handleOpenFileForDownloadAtIndexPath(indexPath)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let downloadObj = downloads![indexPath.row]
            
            //
            // Removes file from file system and then removes object from data store
            //
            do {
                if (downloadObj.fileName != nil) {
                    try NSFileManager.defaultManager().removeItemAtPath(downloadObj.fileURL!.path!)
                    print("File deleted successfully")
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
            try! realm.write {
                realm.delete(downloadObj)
            }
            downloads = realm.objects(Download)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    // MARK: - UIPopoverPresentationControllerDelegate

    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    // MARK: - QLPreviewControllerDataSource
    
    func previewController(controller: QLPreviewController, previewItemAtIndex index: Int) -> QLPreviewItem {
        return downloads![index].fileURL!
    }
    
    func numberOfPreviewItemsInPreviewController(controller: QLPreviewController) -> Int {
        return downloads!.count;
    }
    
    func didAddDownload() {
        downloads = realm.objects(Download)
        tableView.reloadData()
    }
    
    // MARK: - DZNEmptyDataSetSource
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString.init(string: "No Downloads")
    }
}

