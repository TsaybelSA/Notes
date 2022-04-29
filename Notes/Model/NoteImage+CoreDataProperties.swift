//
//  NoteImage+CoreDataProperties.swift
//  Notes
//
//  Created by Сергей Цайбель on 29.04.2022.
//
//

import Foundation
import CoreData


extension NoteImage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NoteImage> {
        return NSFetchRequest<NoteImage>(entityName: "NoteImage")
    }

    @NSManaged public var data: Data
    @NSManaged public var id: UUID
    @NSManaged public var date: Date
    @NSManaged public var note: Note

	
}

extension NoteImage : Identifiable {

}
