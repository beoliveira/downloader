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
    
    func setDownload(download:Download){
        self.urlLabel.text = download.urlString
        downloadObj = download

        if download.completed {
            self.progressLabel?.text = "Downloaded"
            self.titleLabel.text = download.fileName
            self.fileImageView.image = imageForMIMEType(download.mimeType!)
        } else {
            self.progressLabel?.text = "Progress: 0% (0kb / 0kb)"
            self.titleLabel.text = "Downloading... ⬇️"
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(download.startDateString, object: nil, queue: nil) { (notification) -> Void in
            let userInfo = notification.userInfo
            let progressValue = userInfo!["progress"] as! NSNumber
            let receivedDonwloadObj:Download = userInfo!["downloadObj"] as! Download
            
            if let dobj = self.downloadObj {
                if receivedDonwloadObj.invalidated || dobj.invalidated {
                    return
                }
            }
            
            let totalBytes = userInfo!["totalBytes"]?.longLongValue
            let totalBytesExpectedToRead = userInfo!["totalBytesExpectedToRead"]?.longLongValue
            
            if receivedDonwloadObj.startDate.compare((self.downloadObj?.startDate)!) == NSComparisonResult.OrderedSame {
                let formatter = NSByteCountFormatter()
                let formattedFileSize = formatter.stringFromByteCount(totalBytesExpectedToRead!)
                
                self.progressLabel?.text = String(format: "Progress: %lld%% (%@ / %@)", progressValue.longLongValue, formatter.stringFromByteCount(totalBytes!), formattedFileSize)
            }
        }
    }
}