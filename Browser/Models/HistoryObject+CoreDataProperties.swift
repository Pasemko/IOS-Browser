//
//  HistoryObject+CoreDataProperties.swift
//  Browser
//
//  Created by Andrii Pasemko on 02.07.2021.
//
//

import Foundation
import CoreData


extension HistoryObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HistoryObject> {
        return NSFetchRequest<HistoryObject>(entityName: "HistoryObject")
    }

    @NSManaged public var url: String?
    @NSManaged public var visitedOn: Date?
    @NSManaged public var title: NSObject?

}

extension HistoryObject : Identifiable {

}
