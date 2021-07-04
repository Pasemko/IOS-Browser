//
//  BookMark+CoreDataProperties.swift
//  Browser
//
//  Created by Andrii Pasemko on 30.06.2021.
//
//

import Foundation
import CoreData


extension BookMark {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BookMark> {
        return NSFetchRequest<BookMark>(entityName: "BookMark")
    }

    @NSManaged public var createdOn: Date?
    @NSManaged public var isActive: Bool
    @NSManaged public var title: String?
    @NSManaged public var url: String?

}

extension BookMark : Identifiable {

}
