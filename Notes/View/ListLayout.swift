//
//  ListLayout.swift
//  Notes
//
//  Created by Сергей Цайбель on 14.05.2022.
//

import SwiftUI

struct ListLayout: View {
	@EnvironmentObject var secureControl: SecureControl
	@Environment(\.managedObjectContext) var viewContext
	
	@Binding var searchText: String
	let folders: FetchedResults<Folder>
	
    var body: some View {
		List {
			ForEach(folders.reversed(), id:\.self) { folder in
				if !folder.notesArray.isEmpty {
					Section(header: Text(folder.name)) {
						ForEach(filterNotes(folder.notesArray, by: searchText)) { note in
							NavigationLink {
								EditNoteView(note: note)
							} label: {
								listLayoutNote(note)
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
    }
	
	@ViewBuilder
	func listLayoutNote(_ note: Note) -> some View {
		if !note.isLocked || !secureControl.isLockedState {
			HStack {
				if note.isLocked {
					Image(systemName: "lock.open")
				}
				VStack(alignment: .leading) {
					Text(note.text)
						.font(.body)
						.lineLimit(3)
					Text(note.date.formatted(date: .long, time: .omitted))
						.font(.body)
						.fontWeight(.light)
				}
				Spacer()
				HStack {
					ForEach(note.imagesArray, id: \.self) { image in
						if let uiImage = UIImage(data: image.data) {
							Image(uiImage: uiImage)
								.resizable()
								.aspectRatio(contentMode: .fit)
								.frame(maxHeight: 100)
						}
					}
				}
			}
			.contentShape(Rectangle())
			.transition(AnyTransition.opacity)
			
		} else {
			
			HStack(alignment: .center) {
				Spacer()
				Image(systemName: "lock")
					.font(.title2)
				Spacer()
			}
			.contentShape(Rectangle())
			.transition(AnyTransition.opacity)
		}
	}
	
	func filterNotes(_ notesArray: [Note] , by searchedText: String) -> [Note] {
		notesArray.filter({ $0.text.lowercased().contains(searchedText.lowercased()) || searchedText == "" })
	}
	
	private func deleteNotes(with indexSet: IndexSet, from folder: Folder) {
		for index in indexSet {
			withAnimation {
				let note = folder.notesArray[index]
				if note.isLocked && secureControl.isLockedState {
					authenticate {
						folder.removeFromNotes(note)
						secureControl.changeToUnlockedState()
					}
				} else {
					folder.removeFromNotes(note)
				}
			}
		}
		try? viewContext.save()
	}
}

