//
//  Order+CoreDataProperties.swift
//  MHW
//
//  Created by Jeff Eom on 2018-04-12.
//  Copyright © 2018 Jeff Eom. All rights reserved.
//
//

import Foundation
import CoreData


extension Order {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Order> {
        return NSFetchRequest<Order>(entityName: "Order")
    }

    @NSManaged public var number: String?

}
