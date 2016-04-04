//
//  Download.swift
//  downloader
//
//  Created by Thiago Peres on 14/03/16.
//  Copyright © 2016 peres. All rights reserved.
//

import Foundation
import RealmSwift

class Download: Object {
    dynamic var startDate = NSDate()
    dynamic var urlString = ""
    dynamic var fileName: String? = nil
    dynamic var mimeType: String? = nil
    
    var startDateString:String {
        get {
            return NSDateFormatter.localizedStringFromDate(self.startDate, dateStyle: .FullStyle, timeStyle: .FullStyle)
        }
    }
    
    var formattedFileName: String? {
        get {
            return self.fileName == nil ? nil : self.fileName?.componentsSeparatedByString(",").first
        }
    }
    
    var completed:Bool {
        get {
            return self.fileName != nil
        }
    }
    
    var fileURL:NSURL? {
        get {
            if self.fileName == nil {
                return nil
            }
            
            let directoryURLs = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
            
            return directoryURLs[0].URLByAppendingPathComponent(self.fileName!)
        }
    }
}
