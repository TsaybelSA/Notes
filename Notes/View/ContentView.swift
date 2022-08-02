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
	@FetchRequest(sortDescriptors: []) var folders: FetchedResults<Folder>

	@EnvironmentObject var fontStore: FontStore
	@EnvironmentObject var notesViewModel: ViewModel
	
	@Environment(\.editMode) var editMode
	
	@State private var searchText = ""
		
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
						editMode?.wrappedValue = .inactive
						showingGrid.toggle()
					}
				}
				ToolbarItemGroup(placement: .bottomBar) {
					Text(countAmountOfNotes())
					NavigationLink {
						EditNoteView(note: Note(context: viewContext))
					} label: {
						Image(systemName: "square.and.pencil")
					}
				}
			}
			.onAppear {
				if folders.isEmpty {
					createFirstFolders()
				}
			}
			.alert(notesViewModel.alertTitle, isPresented: $notesViewModel.showingAlert) {
				Button("OK") { }
			} message: {
				Text(notesViewModel.alertMessage)
			}
		}
		.environment(\.editMode, editMode)
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
}

