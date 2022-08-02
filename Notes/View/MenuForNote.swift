//
//  MenuForNote.swift
//  Notes
//
//  Created by Сергей Цайбель on 26.04.2022.
//

import SwiftUI

struct MenuForNote: View {
	@Environment(\.managedObjectContext) var viewContext
	
	@EnvironmentObject var notesViewModel: ViewModel

	@FetchRequest(sortDescriptors: []) var folders: FetchedResults<Folder>
	
	@ObservedObject var note: Note
	
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
			try? viewContext.save()
		}
		
		AnimatedActionButton(title: note.isLocked ? "Remove protection" : "Install Protection", systemImage: note.isLocked ? "lock.open": "lock") {
			if notesViewModel.isLockedState {
				notesViewModel.authenticate {
					note.isLocked.toggle()
				}
			} else {
				note.isLocked.toggle()
			}
			try? viewContext.save()
		}
		
		DeleteButton(note: note)
	}
}

struct DeleteButton: View {
	@Environment(\.managedObjectContext) var context
	@FetchRequest(sortDescriptors: []) var folders: FetchedResults<Folder>
	@EnvironmentObject var notesViewModel: ViewModel
	
	@ObservedObject var note: Note
	var action: (() -> Void)? = nil
	
	var body: some View {
		AnimatedActionButton(role: .destructive, title: "Delete", systemImage: "trash") {
			if note.isLocked && notesViewModel.isLockedState {
				notesViewModel.authenticate {
					deleteNote()
				}
			} else {
				deleteNote()
			}
			action?()
		}
    }
	
	private func deleteNote() {
		for folder in folders {
			if folder.notesArray.contains(note) {
				folder.removeFromNotes(note)
				for image in note.imagesArray {
					note.removeFromImage(image)
				}
				note.text = ""
				try? context.save()
			}
		}
	}
}

