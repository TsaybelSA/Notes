//
//  MenuForNote.swift
//  Notes
//
//  Created by Сергей Цайбель on 26.04.2022.
//

import SwiftUI

struct MenuForNote: View {
	@Environment(\.managedObjectContext) var context
	
	@EnvironmentObject var secureControl: SecureControl

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
			try? context.save()
		}
		
		AnimatedActionButton(title: note.isLocked ? "Remove protection" : "Install Protection", systemImage: note.isLocked ? "lock.open": "lock") {
			if secureControl.isLockedState {
				authenticate {
					note.isLocked.toggle()
					secureControl.changeToUnlockedState()
				}
			} else {
				note.isLocked.toggle()
			}
			try? context.save()
		}
		
		DeleteButton(note: note)
	}
}

struct DeleteButton: View {
	@Environment(\.managedObjectContext) var context
	@FetchRequest(sortDescriptors: []) var folders: FetchedResults<Folder>
	@EnvironmentObject var secureControl: SecureControl
	
	@ObservedObject var note: Note
	var action: (() -> Void)? = nil
	
	var body: some View {
		AnimatedActionButton(role: .destructive, title: "Delete", systemImage: "trash") {
			if note.isLocked && secureControl.isLockedState {
				authenticate {
					deleteNote()
					secureControl.changeToUnlockedState()
				}
			} else {
				deleteNote()
			}
			if let action = action {
				action()
			}
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

