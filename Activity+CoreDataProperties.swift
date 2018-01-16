//
//  Activity+CoreDataProperties.swift
//  Core Motion
//
//  Created by DANIEL DURBIN on 3/18/16.
//  Copyright © 2016 DANIEL DURBIN. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Activity {

    @NSManaged var date: Foundation.Date?
    @NSManaged var distance: String?
    @NSManaged var floors: String?
    @NSManaged var steps: String?

}
