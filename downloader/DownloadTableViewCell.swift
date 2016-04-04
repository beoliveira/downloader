//
//  DownloadTableViewCell.swift
//  downloader
//
//  Created by Thiago Peres on 13/03/16.
//  Copyright © 2016 peres. All rights reserved.
//

import UIKit

class DownloadTableViewCell: UITableViewCell {
    
    var downloadObj: Download?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var fileImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    //
    // Returns an UIImage instance containing the icon for the
    // corresponding MIME type string
    //
    func imageForMIMEType(mimeTypeString:String) -> UIImage! {
        if mimeTypeString == "audio/mpeg" || mimeTypeString == "audio/x-mpeg-3" || mimeTypeString == "video/mpeg" || mimeTypeString == "video/x-mpeg" {
            return UIImage(named: "mp3File")
        } else if mimeTypeString == "application/pdf" {
            return UIImage(named: "pdfFile")
        } else if mimeTypeString == "image/png" {
            return UIImage(named: "pngFile")
        } else if mimeTypeString == "image/jpeg" || mimeTypeString == "image/pjpeg" {
            return UIImage(named: "jpgFile")
        }
        
        return UIImage(named: "blankFile")
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupInterfaceForDownload(download:Download, checkProgress:Bool) {
        urlLabel.text = download.urlString
        
        //
        // Handles display for download state
        //
        if download.completed {
            progressLabel?.text = NSLocalizedString("downloads.Downloaded", comment: "")
            
            //
            // Handles files with no filename added
            //
            if download.suggestedFilename?.characters.count > 0 {
                titleLabel.text = download.suggestedFilename
            } else {
                titleLabel.text = NSLocalizedString("downloads.NoFileTitleText", comment: "")
            }
            
            fileImageView.image = imageForMIMEType(download.mimeType!)
        } else {
            if checkProgress == true {
                progressLabel?.text = NSLocalizedString("downloads.ProgressPlaceholder", comment: "")
            }
            titleLabel.text = NSLocalizedString("downloads.Downloading", comment: "")
            //
            // We don't know the mime type at this point, display blank file
            //
            fileImageView.image = imageForMIMEType("")
        }
    }
    
    func setupInterfaceForProgressUpdate(userInfo:Dictionary<NSObject, AnyObject>?) {
        if userInfo == nil {
            return
        }
        
        let progressValue = userInfo!["progress"] as! NSNumber
        let receivedDonwloadObj:Download = userInfo!["downloadObj"] as! Download
        
        //
        // Don't do anything if any of the objects have
        // invalidated in the datastore
        //
        if let dobj = downloadObj {
            if receivedDonwloadObj.invalidated || dobj.invalidated {
                return
            }
        }
        
        let totalBytes = userInfo!["totalBytes"]?.longLongValue
        let totalBytesExpectedToRead = userInfo!["totalBytesExpectedToRead"]?.longLongValue
        
        if receivedDonwloadObj.startDate.compare((downloadObj?.startDate)!) == NSComparisonResult.OrderedSame {
            let formatter = NSByteCountFormatter()
            let formattedFileSize = formatter.stringFromByteCount(totalBytesExpectedToRead!)
            let formattedTotalBytes = formatter.stringFromByteCount(totalBytes!)
            
            //
            // Handles cases where the expected bytes to read (and progress) is not known
            //
            if totalBytesExpectedToRead <= 0 || progressValue.longLongValue <= 0 {
                progressLabel.text = String(format: NSLocalizedString("downloads.ProgressSimplified", comment: ""), formattedTotalBytes)
            } else {
                progressLabel?.text = String(format: NSLocalizedString("downloads.Progress", comment: ""), progressValue.longLongValue, formattedTotalBytes, formattedFileSize)
            }
        }
        
        setupInterfaceForDownload(downloadObj!, checkProgress: false)
    }
    
    func setDownload(download:Download){
        downloadObj = download
        
        setupInterfaceForDownload(download, checkProgress: true)
        
        //
        // Listens to notifications for downloads with that start date
        // to update the cell with download progress
        //
        NSNotificationCenter.defaultCenter().addObserverForName(download.startDateString, object: nil, queue: nil) { (notification) -> Void in
            self.setupInterfaceForProgressUpdate(notification.userInfo)
        }
    }
}