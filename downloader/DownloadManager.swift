//
//  DownloadManager.swift
//  downloader
//
//  Created by Thiago Peres on 11/03/16.
//  Copyright © 2016 peres. All rights reserved.
//

import UIKit
import Alamofire

class DownloadManager: NSObject {
    static let sharedInstance = DownloadManager()
    var manager: Manager
    
    override private init() {
        let configuration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("com.example.app.background")
        manager = Alamofire.Manager(configuration: configuration)
    }
    
    
    
    func addDownload(urlString: String) {
        let destination = Alamofire.Request.suggestedDownloadDestination(directory: .DocumentDirectory, domain: .UserDomainMask)
        
        manager.download(.GET, urlString, destination: destination)
            .progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
                print(totalBytesRead)
                
                // This closure is NOT called on the main queue for performance
                // reasons. To update your ui, dispatch to the main queue.
                dispatch_async(dispatch_get_main_queue()) {
                    print("Total bytes read on main queue: \(totalBytesRead)")
                }
            }
            .response { _, _, data, error in
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
        }
    }
}
