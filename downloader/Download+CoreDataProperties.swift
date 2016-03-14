//
//  Download+CoreDataProperties.swift
//  downloader
//
//  Created by Thiago Peres on 14/03/16.
//  Copyright © 2016 peres. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Download {

    @NSManaged var urlString: String?
    @NSManaged var fileName: String?
    @NSManaged var fileURLString: String?
    @NSManaged var mimeType: String?

}
