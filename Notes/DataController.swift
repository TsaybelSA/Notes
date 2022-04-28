//
//  DataController.swift
//  Notes
//
//  Created by Сергей Цайбель on 12.04.2022.
//

import CoreData
import Foundation

class DataController: ObservableObject {
	let container = NSPersistentContainer(name: "NotesBase")
	
	init() {
		container.loadPersistentStores { description, error in
			if let error = error {
				print("Core Data failed to loar: \(error.localizedDescription)")
				return
			}
			self.container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
		}
	}
}
