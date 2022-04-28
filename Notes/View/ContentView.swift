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
	
	@EnvironmentObject var fontStore: FontStore
	
	@FetchRequest(sortDescriptors: []) var folders: FetchedResults<Folder>
		
	@State private var searchText = ""
	
	@Environment(\.editMode) var editMode
	
	@State private var editingNote: Note?
			
	
	//MARK: fix searching
	var body: some View {
		NavigationView {
			List {
				ForEach(folders.reversed(), id:\.self) { folder in
					if !folder.notesArray.isEmpty {
						Section(header: Text(folder.name)) {
							ForEach(filterNotes(folder.notesArray, by: searchText)) { note in
								NoteView(note)
								.onTapGesture {
									withAnimation {
										editingNote = note
										editMode?.wrappedValue = .inactive
									}
								}
								.contextMenu {
									MenuForNote(note)
								}
							}
							.onDelete { indexSet in
								deleteNotes(with: indexSet, from: folder)
							}
							
						}
					}
				}

			}
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					EditButton()
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
			.searchable(text: $searchText)
			.navigationTitle("My Notes")
		}


	}
	
	private func filterNotes(_ notesArray: [Note] , by searchedText: String) -> [Note] {
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
	
	private func deleteNotes(with indexSet: IndexSet, from folder: Folder) {
		for index in indexSet {
			withAnimation {
				let note = folder.notesArray[index]
				authenticate {
					folder.removeFromNotes(note)
				}
			}
		}
		try? viewContext.save()
	}
	
	private func createFirstFolders() {
		let pined = Folder(context: viewContext)
		pined.name = "Pined"
		let unsorted = Folder(context: viewContext)
		unsorted.name = "Notes"
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

