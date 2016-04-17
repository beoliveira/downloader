//
//  DownloadTests.swift
//  downloader
//
//  Created by Andrew on 06/04/16.
//  Copyright © 2016 peres. All rights reserved.
//

import XCTest
@testable import downloader

class DownloadTests: XCTestCase {
    
    static let testFileName = "test.pdf"
    
    func testStartDateString()
    {
        // setting expected locale and timezone
        Download.dateFormater.locale   = NSLocale(localeIdentifier: "en");
        Download.dateFormater.timeZone = NSTimeZone(abbreviation: "GMT")
        
        let download = createDownloadWithStartDate(NSDate(timeIntervalSince1970: 1000))

        XCTAssertEqual("Thursday, January 1, 1970 - 12:16:40 AM", download.startDateString)
    }
    
    func testCompletedFalse()
    {
        let download = createDownloadWithFilename(nil)

        XCTAssertFalse(download.completed)
    }

    func testCompletedTrue()
    {
        let download = createDownloadWithFilename(DownloadTests.testFileName)
        
        XCTAssertTrue(download.completed)
    }
    
    func testFileURL()
    {
        let download = createDownloadWithFilename(DownloadTests.testFileName)
        
        let fileUrl = download.fileURL;
        
        XCTAssertNotNil(fileUrl);
        
        XCTAssertTrue(fileUrl?.scheme == "file");
        XCTAssertTrue(fileUrl?.URLString.hasSuffix("/Documents/test.pdf") ?? false);
    }

}

extension DownloadTests {
    
    func createDownloadWithStartDate(date: NSDate) -> Download
    {
        let
        download = Download()
        download.startDate = NSDate(timeIntervalSince1970: 1000);
        
        return download;
    }

    func createDownloadWithFilename(filename: String?) -> Download
    {
        let
        download = Download()
        download.fileName = filename;
        
        return download;
    }
}
