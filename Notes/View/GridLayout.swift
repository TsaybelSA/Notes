//
//  GridLayout.swift
//  Notes
//
//  Created by Сергей Цайбель on 14.05.2022.
//

import SwiftUI

struct GridLayout: View {
	
	@EnvironmentObject var secureControl: SecureControl
	
	@Binding var searchText: String
	let folders: FetchedResults<Folder>
	
	let columns = [GridItem(.adaptive(minimum: 150, maximum: 180))]

    var body: some View {
		ScrollView {
			GeometryReader { geo in
				LazyVGrid(columns: columns) {
					ForEach(folders.reversed(), id:\.self) { folder in
						if !folder.notesArray.isEmpty {
							Section(header: Text(folder.name).font(.headline)) {
								ForEach(filterNotes(folder.notesArray, by: searchText)) { note in
									NavigationLink {
										EditNoteView(note: note)
									} label: {
										gridLayoutNote(note, from: folder, with: geo)
											.foregroundColor(.primary)
									}
									.contextMenu {
										MenuForNote(note)
									}
									
								}
								
							}
						}
					}
				}
			}
		}

	}
	
	@ViewBuilder
	func gridLayoutNote(_ note: Note, from folder : Folder, with geo: GeometryProxy) -> some View {
		Group {
			if !note.isLocked || !secureControl.isLockedState {
				HStack {
					VStack {
						if note.isLocked {
							Image(systemName: "lock.open")
						}
						Text(note.text)
							.font(.body)
							.lineLimit(3)
							.multilineTextAlignment(.leading)
						Text(note.date.formatted(date: .long, time: .omitted))
							.font(.caption)
							.fontWeight(.light)
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
			   }
			   .padding()
			} else {
				VStack(alignment: .center) {
					Image(systemName: "lock")
						.font(.title2)
				}
				.padding()
			}
		}
		.frame(width: geo.size.width * 0.45)
		.background(.thickMaterial)
		.clipShape(RoundedRectangle(cornerRadius: 10))
		.overlay {
			RoundedRectangle(cornerRadius: 10)
				.stroke(.gray)
		}
	}


	func filterNotes(_ notesArray: [Note] , by searchedText: String) -> [Note] {
		notesArray.filter({ $0.text.lowercased().contains(searchedText.lowercased()) || searchedText == "" })
	}
}
