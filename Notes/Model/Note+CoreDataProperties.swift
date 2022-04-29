//
//  Note+CoreDataProperties.swift
//  Notes
//
//  Created by Сергей Цайбель on 29.04.2022.
//
//

import Foundation
import CoreData
import SwiftUI


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var date: Date
    @NSManaged public var id: UUID
    @NSManaged public var images: Data?
    @NSManaged public var isLocked: Bool
    @NSManaged public var isPined: Bool
    @NSManaged public var text: String
    @NSManaged public var folder: Folder?
    @NSManaged public var image: NSSet?
	
	public var imagesArray: [UIImage] {
	var imageSet = [UIImage]()
	let set = image as? Set<NoteImage> ?? []
		for image in set {
			if let uiImage = UIImage(data: image.data) {
				imageSet.append(uiImage)
			}
		}
	return imageSet
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
