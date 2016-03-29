//
//  DownloadManager.swift
//  downloader
//
//  Created by Thiago Peres on 11/03/16.
//  Copyright © 2016 peres. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift

struct Constants {
    static let downloadsDidChangeNotification = "downloadsDidChangeNotification"
    static let downloadProgressDidChangeNotification = "downloadProgressDidChangeNotification"
}

class DownloadManager: NSObject {
    static let sharedInstance = DownloadManager()
    var manager: Manager
    let realm = try! Realm()
    
    override private init() {
        let configuration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("peres.downloader.background")
        manager = Alamofire.Manager(configuration: configuration)
    }
    
    func URLforFileName(string:String) -> NSURL {
        let directoryURLs = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        
        return directoryURLs[0].URLByAppendingPathComponent(string)
    }
    
    func addDownload(urlString: String) {
        //
        // Create the download object and sends a notification, adds the download to the global downloads object
        //
        let downloadObj = Download()
        downloadObj.urlString = urlString
        downloadObj.startDate = NSDate()
        try! realm.write {
            realm.add(downloadObj)
        }
        
        manager.download(.GET, urlString, destination: downloadDestination())
            .progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
                print(totalBytesRead)
                
                //
                // This closure is NOT called on the main queue for performance
                // reasons. To update your ui, dispatch to the main queue.
                //
                dispatch_async(dispatch_get_main_queue()) {
                    let progress = (Float(totalBytesRead)/Float(totalBytesExpectedToRead)) * 100
                    
                    NSNotificationCenter.defaultCenter().postNotificationName(downloadObj.startDateString, object: self, userInfo: [
                        "progress":NSNumber(float: progress),
                        "totalBytes":NSNumber(longLong: totalBytesRead),
                        "totalBytesExpectedToRead":NSNumber(longLong: totalBytesExpectedToRead),
                        "downloadObj":downloadObj])
                }
            }
            .response { _, response, data, error in
                if let error = error {
                    print("Failed with error: \(error)")
                    //
                    // TODO: Error handling
                    //
                } else {
                    print("Downloaded file successfully")
                    //
                    // Update local storage with file information
                    //
                    try! self.realm.write {
                        downloadObj.fileName = self.filenameForResponse(response!)
                        downloadObj.mimeType = response!.MIMEType
                    }
                }
                if let
                    data = data,
                    resumeDataString = NSString(data: data, encoding: NSUTF8StringEncoding)
                {
                    print("Resume Data: \(resumeDataString)")
                } else {
                    print("Resume Data was empty")
                }
        }
    }
    
    //
    // Returns a string containing the downloaded file file name
    //
    func filenameForResponse(response:NSHTTPURLResponse) -> String {
        let components = response.suggestedFilename!.componentsSeparatedByString(".")
        let filename:String
        let dateString = response.allHeaderFields["Date"] as! String
        
        if components.count == 1 {
            filename = String(format: "%@%@", (components.first)!, dateString)
        } else {
            filename = String(format: "%@%@.%@", (components.first)!, dateString, (components.last)!)
        }
        
        return filename
    }
    
    //
    // Print directory contents, for debugging
    //
    func _printDirectoryContents() {
        let directoryURLs = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)

        do {
            let directoryContents = try NSFileManager.defaultManager().contentsOfDirectoryAtURL(directoryURLs.first!, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions())
            print(directoryContents)
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    //
    // Returns an Alamofire DownloadDestination closure that informs the file save path
    //
    // Duplicated file names will get a numeric suffix
    //
    func downloadDestination() -> (NSURL, NSHTTPURLResponse) -> (NSURL) {
        return {
            (temporaryURL, response) in
            
            let directoryURLs = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
            
            if !directoryURLs.isEmpty {
                let url = self.URLforFileName(self.filenameForResponse(response))
                
                print("Path: \(url)")
                
                return url
            }
            
            return temporaryURL
        }
    }

}
