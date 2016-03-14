//
//  DownloadManager.swift
//  downloader
//
//  Created by Thiago Peres on 11/03/16.
//  Copyright © 2016 peres. All rights reserved.
//

import UIKit
import Alamofire

struct Constants {
    static let downloadsDidChangeNotification = "downloadsDidChangeNotification"
    static let downloadProgressDidChangeNotification = "downloadProgressDidChangeNotification"
}

class DownloadManager: NSObject {
    static let sharedInstance = DownloadManager()
    var manager: Manager
    var downloads: Array<Download> = []
    
    override private init() {
        let configuration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("peres.downloader.background")
        manager = Alamofire.Manager(configuration: configuration)
        
        // TODO: load stored downloads from file
    }
    
    func downloadDestination() -> (NSURL, NSHTTPURLResponse) -> (NSURL) {
        return {
            (temporaryURL, response) in
            
            let directoryURLs = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
            
            do {
                let directoryContents = try NSFileManager.defaultManager().contentsOfDirectoryAtURL(directoryURLs.first!, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions())
                print(directoryContents)
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
            if !directoryURLs.isEmpty {
                //
                // Handles duplicated filenames
                //
                let unencodedFileName = response.suggestedFilename
                
                var intendedPath = directoryURLs[0].URLByAppendingPathComponent(unencodedFileName!)
                var i = 1;
                
                while NSFileManager.defaultManager().fileExistsAtPath(intendedPath.path!) {
                    let components = unencodedFileName?.componentsSeparatedByString(".")
                    let filename:String
                    
                    if components?.count == 1 {
                        filename = String(format: "%@-%d", (components?.first)!, i)
                    } else {
                        filename = String(format: "%@-%d.%@", String(format: "%@-%d.%@", (components?.first)!, i, (components?.last)!))
                    }
                    
                    intendedPath = directoryURLs[0].URLByAppendingPathComponent(filename)
                    i += 1
                }
                
                print("Path: \(intendedPath)")
                
                return intendedPath
            }
            
            return temporaryURL
        }
    }
    
    func addDownload(urlString: String) {
        let destination = downloadDestination()
        
        //
        // Create the download object and sends a notification, adds the download to the global downloads object
        //
        let downloadObj = Download.init()
        downloadObj.urlString = urlString
        downloads.append(downloadObj)
        NSNotificationCenter.defaultCenter().postNotificationName(Constants.downloadsDidChangeNotification, object: self)
        
        manager.download(.GET, urlString, destination: destination)
            .progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
                print(totalBytesRead)
                
                //
                // This closure is NOT called on the main queue for performance
                // reasons. To update your ui, dispatch to the main queue.
                //
                dispatch_async(dispatch_get_main_queue()) {
                    let progress = (totalBytesRead/totalBytesExpectedToRead)*100
                    print("Total bytes read on main queue: \(totalBytesRead)")
                    NSNotificationCenter.defaultCenter().postNotificationName(urlString, object: self, userInfo: ["progress":NSNumber(longLong: progress), "download":downloadObj])
                }
            }
            .response { _, response, data, error in
                if let error = error {                    
                    print("Failed with error: \(error)")
                } else {
                    print("Downloaded file successfully")
                }
                if let
                    data = data,
                    resumeDataString = NSString(data: data, encoding: NSUTF8StringEncoding)
                {
                    print("Resume Data: \(resumeDataString)")
                } else {
                    print("Resume Data was empty")
                }
                downloadObj.fileURLString = destination(NSURL(string: "")!, response!).absoluteString
                downloadObj.fileName = response?.suggestedFilename
                downloadObj.mimeType = response?.MIMEType
        }
    }
}
