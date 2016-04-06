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
    dynamic var suggestedFilename: String? = nil
    dynamic var fileName: String? = nil
    dynamic var mimeType: String? = nil
    
    var startDateString:String {
        get {
            return NSDateFormatter.localizedStringFromDate(self.startDate, dateStyle: .FullStyle, timeStyle: .FullStyle)
        }
    }
    
    var completed:Bool {
        get {
            return self.fileName != nil
        }
    }
    
    var fileURL:NSURL? {
        get {
            guard let filename = self.fileName else {
                return nil
            }
            guard let documentDirectoryUrl = NSFileManager.documentDirectoryUrl() else {
                return nil;
            }
            
            return documentDirectoryUrl.URLByAppendingPathComponent(filename)
        }
    }
}
