//
//  FilteredList.swift
//  Notes
//
//  Created by Сергей Цайбель on 13.04.2022.
//

import CoreData
import SwiftUI

struct FilteredList<T: NSManagedObject, Content: View>: View {
	@Environment(\.managedObjectContext) var context
	@FetchRequest var fetchRequest: FetchedResults<T>
	
	var content: (T) -> Content
	
    var body: some View {
			ForEach(fetchRequest, id: \.self) { item in
				self.content(item)
			}
			.onDelete { indexSet in
				deleteNotes(with: indexSet)
			}
		
    }
	
	//MARK: - need to add filter by date to sortDescriptors
	
	init(searchText: String, @ViewBuilder content: @escaping (T) -> Content) {
		if searchText == "" {
			_fetchRequest = FetchRequest<T>(sortDescriptors: [NSSortDescriptor(keyPath: \Note.date, ascending: false)])
		} else {
			_fetchRequest = FetchRequest<T>(sortDescriptors: [NSSortDescriptor(keyPath: \Note.date, ascending: false)], predicate: NSPredicate(format: "text contains[c] %@", searchText))
		}
		self.content = content
	}
	
	private func deleteNotes(with indexSet: IndexSet) {
		for index in indexSet {
			withAnimation {
				context.delete(fetchRequest[index])
			}
		}
		try? context.save()
	}

}


