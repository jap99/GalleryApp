//
//  Art+CoreDataProperties.swift
//  TheGallery
//
//  Created by Javid Poornasir on 9/17/16.
//  Copyright © 2016 Javid Poornasir. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Art {

    @NSManaged var productIdentifier: String?
    @NSManaged var imageName: String?
    @NSManaged var purchased: NSNumber?
    @NSManaged var title: String?

}
