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
    @NSManaged public var id: UUID
    @NSManaged public var isLocked: Bool
    @NSManaged public var isPined: Bool
    @NSManaged public var text: String
    @NSManaged public var folder: Folder?
    @NSManaged public var image: NSSet?

	public var imagesArray: [NoteImage] {
			let set = image as? Set<NoteImage> ?? []
			return set.sorted {
				$0.date > $1.date
			}
		}
}

// MARK: Generated accessors for image
extension Note {

    @objc(addImageObject:)
    @NSManaged public func addToImage(_ value: NoteImage)

    @objc(removeImageObject:)
    @NSManaged public func removeFromImage(_ value: NoteImage)

    @objc(addImage:)
    @NSManaged public func addToImage(_ values: NSSet)

    @objc(removeImage:)
    @NSManaged public func removeFromImage(_ values: NSSet)

}

extension Note : Identifiable {

}
