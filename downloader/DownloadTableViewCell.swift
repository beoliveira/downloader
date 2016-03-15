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

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setDownload(download:Download){
        self.textLabel?.text = download.urlString
        downloadObj = download
        
        NSNotificationCenter.defaultCenter().addObserverForName(download.urlString, object: nil, queue: nil) { (notification) -> Void in
            let userInfo = notification.userInfo
            let progressValue = userInfo!["progress"] as! NSNumber
            let receivedDonwloadObj:Download = userInfo!["downloadObj"] as! Download
            
            let totalBytes = userInfo!["totalBytes"]?.longLongValue
            let totalBytesExpectedToRead = userInfo!["totalBytesExpectedToRead"]?.longLongValue
            
            let formatter = NSByteCountFormatter()
            
            if receivedDonwloadObj.startDate.compare((self.downloadObj?.startDate)!) == NSComparisonResult.OrderedSame {
                self.detailTextLabel?.text = String(format: "Progress: %lld%% (%@ / %@)", progressValue.longLongValue, formatter.stringFromByteCount(totalBytes!), formatter.stringFromByteCount(totalBytesExpectedToRead!))
            }
        }
    }
}