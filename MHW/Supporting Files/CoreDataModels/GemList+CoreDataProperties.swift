//
//  GemList+CoreDataProperties.swift
//  
//
//  Created by Jeff Eom on 2018-04-16.
//
//

import Foundation
import CoreData


extension GemList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GemList> {
        return NSFetchRequest<GemList>(entityName: "GemList")
    }

    @NSManaged public var firstGem: String?
    @NSManaged public var secondGem: String?
    @NSManaged public var thirdGem: String?
    @NSManaged public var savedArray: SavedArray?

}
