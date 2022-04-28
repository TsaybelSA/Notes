//
//  Note+CoreDataProperties.swift
//  Notes
//
//  Created by Сергей Цайбель on 29.04.2022.
//
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var date: Date
    @NSManaged public var id: UUID?
    @NSManaged public var isLocked: Bool
    @NSManaged public var isPined: Bool
    @NSManaged public var text: String
    @NSManaged public var images: NSData?
    @NSManaged public var folder: Folder?

}

extension Note : Identifiable {

}
