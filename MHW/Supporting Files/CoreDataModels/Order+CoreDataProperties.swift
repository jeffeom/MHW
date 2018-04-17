//
//  Order+CoreDataProperties.swift
//  
//
//  Created by Jeff Eom on 2018-04-16.
//
//

import Foundation
import CoreData


extension Order {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Order> {
        return NSFetchRequest<Order>(entityName: "Order")
    }

    @NSManaged public var number: String?
    @NSManaged public var savedArray: SavedArray?

}
