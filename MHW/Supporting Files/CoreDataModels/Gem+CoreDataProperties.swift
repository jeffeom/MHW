//
//  Gem+CoreDataProperties.swift
//  
//
//  Created by Jeff Eom on 2018-04-21.
//
//

import Foundation
import CoreData


extension Gem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Gem> {
        return NSFetchRequest<Gem>(entityName: "Gem")
    }

    @NSManaged public var name: String?
    @NSManaged public var gemHighlightList: GemHighlightList?

}
