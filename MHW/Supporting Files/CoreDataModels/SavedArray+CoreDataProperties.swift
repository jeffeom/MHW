//
//  SavedArray+CoreDataProperties.swift
//  MHW
//
//  Created by Jeff Eom on 2018-04-12.
//  Copyright © 2018 Jeff Eom. All rights reserved.
//
//

import Foundation
import CoreData


extension SavedArray {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SavedArray> {
        return NSFetchRequest<SavedArray>(entityName: "SavedArray")
    }

    @NSManaged public var orders: NSOrderedSet?
    @NSManaged public var gemLists: NSOrderedSet?
    @NSManaged public var currentRow: Int64

}

// MARK: Generated accessors for orders
extension SavedArray {

    @objc(insertObject:inOrdersAtIndex:)
    @NSManaged public func insertIntoOrders(_ value: Order, at idx: Int)

    @objc(removeObjectFromOrdersAtIndex:)
    @NSManaged public func removeFromOrders(at idx: Int)

    @objc(insertOrders:atIndexes:)
    @NSManaged public func insertIntoOrders(_ values: [Order], at indexes: NSIndexSet)

    @objc(removeOrdersAtIndexes:)
    @NSManaged public func removeFromOrders(at indexes: NSIndexSet)

    @objc(replaceObjectInOrdersAtIndex:withObject:)
    @NSManaged public func replaceOrders(at idx: Int, with value: Order)

    @objc(replaceOrdersAtIndexes:withOrders:)
    @NSManaged public func replaceOrders(at indexes: NSIndexSet, with values: [Order])

    @objc(addOrdersObject:)
    @NSManaged public func addToOrders(_ value: Order)

    @objc(removeOrdersObject:)
    @NSManaged public func removeFromOrders(_ value: Order)

    @objc(addOrders:)
    @NSManaged public func addToOrders(_ values: NSOrderedSet)

    @objc(removeOrders:)
    @NSManaged public func removeFromOrders(_ values: NSOrderedSet)

}

// MARK: Generated accessors for gemLists
extension SavedArray {

    @objc(insertObject:inGemListsAtIndex:)
    @NSManaged public func insertIntoGemLists(_ value: GemList, at idx: Int)

    @objc(removeObjectFromGemListsAtIndex:)
    @NSManaged public func removeFromGemLists(at idx: Int)

    @objc(insertGemLists:atIndexes:)
    @NSManaged public func insertIntoGemLists(_ values: [GemList], at indexes: NSIndexSet)

    @objc(removeGemListsAtIndexes:)
    @NSManaged public func removeFromGemLists(at indexes: NSIndexSet)

    @objc(replaceObjectInGemListsAtIndex:withObject:)
    @NSManaged public func replaceGemLists(at idx: Int, with value: GemList)

    @objc(replaceGemListsAtIndexes:withGemLists:)
    @NSManaged public func replaceGemLists(at indexes: NSIndexSet, with values: [GemList])

    @objc(addGemListsObject:)
    @NSManaged public func addToGemLists(_ value: GemList)

    @objc(removeGemListsObject:)
    @NSManaged public func removeFromGemLists(_ value: GemList)

    @objc(addGemLists:)
    @NSManaged public func addToGemLists(_ values: NSOrderedSet)

    @objc(removeGemLists:)
    @NSManaged public func removeFromGemLists(_ values: NSOrderedSet)

}
