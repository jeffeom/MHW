//
//  GemHighlightList+CoreDataProperties.swift
//  
//
//  Created by Jeff Eom on 2018-04-21.
//
//

import Foundation
import CoreData


extension GemHighlightList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GemHighlightList> {
        return NSFetchRequest<GemHighlightList>(entityName: "GemHighlightList")
    }

    @NSManaged public var gems: NSSet?

}

// MARK: Generated accessors for gems
extension GemHighlightList {

    @objc(addGemsObject:)
    @NSManaged public func addToGems(_ value: Gem)

    @objc(removeGemsObject:)
    @NSManaged public func removeFromGems(_ value: Gem)

    @objc(addGems:)
    @NSManaged public func addToGems(_ values: NSSet)

    @objc(removeGems:)
    @NSManaged public func removeFromGems(_ values: NSSet)

}
