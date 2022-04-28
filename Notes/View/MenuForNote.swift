//
//  MenuForNote.swift
//  Notes
//
//  Created by Сергей Цайбель on 26.04.2022.
//

import SwiftUI

struct MenuForNote: View {
	@Environment(\.managedObjectContext) var context

	@FetchRequest(sortDescriptors: []) var folders: FetchedResults<Folder>
	
	var note: Note
	
	init(_ note: Note) {
		self.note = note
	}
    var body: some View {
		
		AnimatedActionButton(title: note.isPined ? "Unpin" : "Pin", systemImage: note.isPined ? "pin.slash" : "pin") {
			if note.isPined {
				note.isPined = false
				note.folder = folders.first(where: { $0.name == "Notes" }) ?? folders.first
			} else {
				note.isPined = true
				note.folder = folders.first(where: { $0.name == "Pined" }) ?? folders.first
			}
			try? context.save()
		}

		AnimatedActionButton(title: "Delete", systemImage: "trash") {
			if note.isLocked {
				authenticate {
					deleteNote()
				}
			} else {
				deleteNote()
			}
		}
		
		AnimatedActionButton(title: note.isLocked ? "Remove protection" : "Install Protection", systemImage: note.isLocked ? "lock.open": "lock") {
			authenticate {
				note.isLocked.toggle()
			}
			try? context.save()
		}
    }
	private func deleteNote() {
		for folder in folders {
			if folder.notesArray.contains(note) {
				folder.removeFromNotes(note)
				try? context.save()
			}
		}
	}
}

//struct MenuForNote_Previews: PreviewProvider {
//    static var previews: some View {
//        MenuForNote()
//    }
//}
