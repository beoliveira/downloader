//
//  DownloadTableViewCellTests.swift
//  downloader
//
//  Created by Andrew on 16/04/16.
//  Copyright © 2016 peres. All rights reserved.
//

import XCTest
@testable import downloader

class DownloadTableViewCellTests: XCTestCase {

    var downloadTableViewCell : DownloadTableViewCell!
    
    override func setUp() {
        super.setUp()
        
        downloadTableViewCell = DownloadTableViewCell();
    }
    
    override func tearDown() {
        super.tearDown()
        
        downloadTableViewCell = nil;
    }

    func testImageForMIMEType() {
        XCTAssertEqual(UIImage(named: "blankFile"), downloadTableViewCell.imageForMIMEType("something"))
        XCTAssertEqual(UIImage(named: "mp3File"),   downloadTableViewCell.imageForMIMEType("audio/mpeg"))
        XCTAssertEqual(UIImage(named: "mp3File"),   downloadTableViewCell.imageForMIMEType("audio/x-mpeg-3"))
        XCTAssertEqual(UIImage(named: "mp3File"),   downloadTableViewCell.imageForMIMEType("video/mpeg"))
        XCTAssertEqual(UIImage(named: "mp3File"),   downloadTableViewCell.imageForMIMEType("video/x-mpeg"))
        
        XCTAssertEqual(UIImage(named: "pdfFile"),   downloadTableViewCell.imageForMIMEType("application/pdf"))
        XCTAssertEqual(UIImage(named: "pngFile"),   downloadTableViewCell.imageForMIMEType("image/png"))
     
        XCTAssertEqual(UIImage(named: "jpgFile"),   downloadTableViewCell.imageForMIMEType("image/jpeg"))
        XCTAssertEqual(UIImage(named: "jpgFile"),   downloadTableViewCell.imageForMIMEType("image/pjpeg"))
    }
}
