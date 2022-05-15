//
//  ContentView.swift
//  Notes
//
//  Created by Сергей Цайбель on 12.04.2022.
//

import SwiftUI
import CoreMIDI

struct ContentView: View {
	@Environment(\.managedObjectContext) var viewContext
		
	@Environment(\.editMode) var editMode
		
	@EnvironmentObject var fontStore: FontStore
	
	@EnvironmentObject var secureControl: SecureControl
	
	@FetchRequest(sortDescriptors: []) var folders: FetchedResults<Folder>
		
	@State private var searchText = ""
	
	@State private var editingNote: Note?
	
	@State private var showingGrid = false
			
	var body: some View {
		NavigationView {
			ZStack {
				if showingGrid {
					GridLayout(searchText: $searchText, folders: folders)
						.transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing)))
				} else {
					ListLayout(searchText: $searchText, folders: folders)
						.transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
				}
			}
			.searchable(text: $searchText)
			.navigationTitle("My Notes")
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					showingGrid ? nil : EditButton()
				}
				ToolbarItem(placement: .navigationBarLeading) {
					AnimatedActionButton(systemImage: showingGrid ? "list.dash" : "square.grid.2x2") {
						showingGrid.toggle()
					}
				}
				ToolbarItemGroup(placement: .bottomBar) {
					Text(countAmountOfNotes())
					AnimatedActionButton(systemImage: "square.and.pencil") {
						createNewNote()
						editMode?.wrappedValue = .inactive
					}
				}
			}
			.onAppear {
				if folders.isEmpty {
					createFirstFolders()
				}
			}
			.environment(\.editMode, editMode)
			.fullScreenCover(item: $editingNote) { note in
				EditNoteView(note: note)
			}
		}
	}
	
	
	func filterNotes(_ notesArray: [Note] , by searchedText: String) -> [Note] {
		notesArray.filter({ $0.text.lowercased().contains(searchedText.lowercased()) || searchedText == "" })
	}
	
	private func countAmountOfNotes() -> String {
		var count = 0
		for folder in folders {
			count += folder.notesArray.count
		}
		let notesCount = count == 1 ? "\(count) note" : "\(count) notes"
		return notesCount
	}
	

	
	private func createFirstFolders() {
		let pined = Folder(context: viewContext)
		pined.name = "Pined"
		let unsorted = Folder(context: viewContext)
		unsorted.name = "Notes"
		let newNote = Note(context: viewContext)
		newNote.text = "Welcome to Notes. To create new note tap icon in the right corner. You can open context menu by long pressing on note."
		newNote.date = Date()
		newNote.id = UUID()
		newNote.isPined = false
		newNote.isLocked = false
		newNote.folder = unsorted
		try? viewContext.save()
	}
	
	private func createNewNote() {
		let newNote = Note(context: viewContext)
		newNote.text = ""
		newNote.date = Date()
		newNote.id = UUID()
		newNote.isPined = false
		newNote.isLocked = false
		if let folderIndex = folders.firstIndex(where: { $0.name == "Notes" }) {
			newNote.folder = folders[folderIndex]
		}
		try? viewContext.save()
		editingNote = newNote
	}

}

