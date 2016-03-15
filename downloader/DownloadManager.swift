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
    
    func addDownload(urlString: String) {
        let destination = downloadDestination()
        
        //
        // Create the download object and sends a notification, adds the download to the global downloads object
        //
        let downloadObj = Download()
        downloadObj.urlString = urlString
        downloadObj.startDate = NSDate()
        try! realm.write {
            realm.add(downloadObj)
        }
        
        manager.download(.GET, urlString, destination: destination)
            .progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
                print(totalBytesRead)
                
                //
                // This closure is NOT called on the main queue for performance
                // reasons. To update your ui, dispatch to the main queue.
                //
                dispatch_async(dispatch_get_main_queue()) {
                    let progress = (Float(totalBytesRead)/Float(totalBytesExpectedToRead)) * 100
                    
                    NSNotificationCenter.defaultCenter().postNotificationName(urlString, object: self, userInfo: [
                        "progress":NSNumber(float: progress),
                        "totalBytes":NSNumber(longLong: totalBytesRead),
                        "totalBytesExpectedToRead":NSNumber(longLong: totalBytesExpectedToRead),
                        "downloadObj":downloadObj])
                }
            }
            .response { _, response, data, error in
                // TODO: Error handling
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
                let predicate = NSPredicate(format: "urlString = %@", urlString)
                
                let downloadedObj = self.realm.objects(Download).filter(predicate).first
                try! self.realm.write {
                    let url = self.downloadedDestination(response!)
                    downloadedObj!.fileURLString = url!.absoluteString
                    downloadedObj!.fileName = response?.suggestedFilename
                    downloadedObj!.mimeType = response?.MIMEType
                }
        }
    }
    
    //
    // Returns an NSURL containing the downloaded file destination
    //
    func downloadedDestination(response: NSHTTPURLResponse) -> NSURL? {
        let directoryURLs = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        
        //
        // Print directory contents
        //
        //            do {
        //                let directoryContents = try NSFileManager.defaultManager().contentsOfDirectoryAtURL(directoryURLs.first!, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions())
        //                print(directoryContents)
        //
        //            } catch let error as NSError {
        //                print(error.localizedDescription)
        //            }
        
        if !directoryURLs.isEmpty {
            //
            // Handles duplicated filenames by adding an integer suffix
            //
            let unencodedFileName = response.suggestedFilename
            
            var intendedPath = directoryURLs[0].URLByAppendingPathComponent(unencodedFileName!)
            var i = 1;
            
            while !NSFileManager.defaultManager().fileExistsAtPath(intendedPath.path!) {
                let components = unencodedFileName?.componentsSeparatedByString(".")
                let filename:String
                
                if components?.count == 1 {
                    filename = String(format: "%@-%d", (components?.first)!, i)
                } else {
                    filename = String(format: "%@-%d.%@", (components?.first)!, i, (components?.last)!)
                }
                
                intendedPath = directoryURLs[0].URLByAppendingPathComponent(filename)
                i += 1
            }
            
            print("Saved path: \(intendedPath)")
            
            return intendedPath
        }
        
        return nil
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
                //
                // Handles duplicated filenames by adding an integer suffix
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
                        filename = String(format: "%@-%d.%@", (components?.first)!, i, (components?.last)!)
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

}
