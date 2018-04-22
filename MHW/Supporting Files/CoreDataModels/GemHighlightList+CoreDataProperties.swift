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

    @NSManaged public var gems: NSOrderedSet?

}

// MARK: Generated accessors for gems
extension GemHighlightList {

    @objc(insertObject:inGemsAtIndex:)
    @NSManaged public func insertIntoGems(_ value: Gem, at idx: Int)

    @objc(removeObjectFromGemsAtIndex:)
    @NSManaged public func removeFromGems(at idx: Int)

    @objc(insertGems:atIndexes:)
    @NSManaged public func insertIntoGems(_ values: [Gem], at indexes: NSIndexSet)

    @objc(removeGemsAtIndexes:)
    @NSManaged public func removeFromGems(at indexes: NSIndexSet)

    @objc(replaceObjectInGemsAtIndex:withObject:)
    @NSManaged public func replaceGems(at idx: Int, with value: Gem)

    @objc(replaceGemsAtIndexes:withGems:)
    @NSManaged public func replaceGems(at indexes: NSIndexSet, with values: [Gem])

    @objc(addGemsObject:)
    @NSManaged public func addToGems(_ value: Gem)

    @objc(removeGemsObject:)
    @NSManaged public func removeFromGems(_ value: Gem)

    @objc(addGems:)
    @NSManaged public func addToGems(_ values: NSOrderedSet)

    @objc(removeGems:)
    @NSManaged public func removeFromGems(_ values: NSOrderedSet)

}
