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
    dynamic var fileURLString: String? = nil
    dynamic var mimeType: String? = nil
    
    var fileURL:NSURL {
        get {
            return NSURL(string: self.fileURLString!)!.filePathURL!
        }
    }
}
