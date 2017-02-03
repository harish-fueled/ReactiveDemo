//
//  Venue+CoreDataProperties.swift
//  Restaurants
//
//  Created by Harish Saini on 03/02/17.
//  Copyright © 2017 Fueled. All rights reserved.
//

import Foundation
import CoreData


extension Venue {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Venue> {
        return NSFetchRequest<Venue>(entityName: "Venue");
    }

    @NSManaged public var venueId: String?
    @NSManaged public var name: String?
    @NSManaged public var details: String?

}
