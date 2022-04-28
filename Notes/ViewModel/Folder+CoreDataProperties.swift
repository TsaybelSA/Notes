//
//  Folder+CoreDataProperties.swift
//  Notes
//
//  Created by Сергей Цайбель on 29.04.2022.
//
//

import Foundation
import CoreData


extension Folder {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Folder> {
        return NSFetchRequest<Folder>(entityName: "Folder")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String
    @NSManaged public var notes: NSSet?
	
	public var notesArray: [Note] {
		let set = notes as? Set<Note> ?? []
		return set.sorted {
			$0.date > $1.date
		}
	}

}

// MARK: Generated accessors for notes
extension Folder {

    @objc(addNotesObject:)
    @NSManaged public func addToNotes(_ value: Note)

    @objc(removeNotesObject:)
    @NSManaged public func removeFromNotes(_ value: Note)

    @objc(addNotes:)
    @NSManaged public func addToNotes(_ values: NSSet)

    @objc(removeNotes:)
    @NSManaged public func removeFromNotes(_ values: NSSet)

}

extension Folder : Identifiable {

}
