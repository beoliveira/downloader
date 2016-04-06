//
//  NSFileManager+DocumentDirectory.swift
//  downloader
//
//  Created by Andrew on 06/04/16.
//  Copyright © 2016 peres. All rights reserved.
//

import Foundation

extension NSFileManager {
    
    class func documentDirectoryUrl() -> NSURL? {
        return NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first
    }    
}
