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
    
    static let dateFormater = Download.createDateStringFormatter("EEEE, MMMM d, yyyy - h:mm:ss a") // http://www.codingexplorer.com/swiftly-getting-human-readable-date-nsdateformatter/
    
    var startDateString:String {
        get {
            return Download.dateFormater.stringFromDate(self.startDate)
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

extension Download /* Date Formatter */ {
    
    static func createDateStringFormatter(format: String) -> NSDateFormatter {
        let
        formatter = NSDateFormatter()
        formatter.dateFormat = format
        formatter.locale = NSLocale.currentLocale()
        return formatter
    }
}
