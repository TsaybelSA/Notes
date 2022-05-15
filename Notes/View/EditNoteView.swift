//
//  EditNoteView.swift
//  Notes
//
//  Created by Сергей Цайбель on 23.04.2022.
//

import SwiftUI

struct EditNoteView: View {
	
	@Environment(\.managedObjectContext) var viewContext
	@FetchRequest(sortDescriptors: []) var folders: FetchedResults<Folder>
	
	@ObservedObject var note: Note
	
	@EnvironmentObject var fontStore: FontStore
	@EnvironmentObject var secureControl: SecureControl
	
	@Environment(\.dismiss) var dismiss
	
	@State private var bold = false
	@State private var italic = false
	@State private var fontSize = 20
	
	var displayFont: Font {
		let font = Font.system(size: CGFloat(fontSize),
			weight: bold == true ? .bold : .regular)
		return italic == true ? font.italic() : font
	}
	
	@State private var selectedImageID: UUID?
	
	@FocusState private var textIsFocused: Bool
	
    var body: some View {
		GeometryReader { geo in
			ScrollView {
				VStack(alignment: .trailing) {
					if !secureControl.isLockedState || !note.isLocked {
						unlockedNote(with: geo)
					} else {
						lockedNote
							.transition(AnyTransition.opacity.animation(.spring()))
					}
				}
				.frame(alignment: .center)
			}
			.navigationTitle(note.isLocked ? "" : "Edit Note")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItemGroup(placement: .navigationBarTrailing) {
					AnimatedActionButton(systemImage: secureControl.isLockedState ? "lock": "lock.open") {
						if secureControl.isLockedState {
							authenticate {
								secureControl.changeToUnlockedState()
							}
						} else {
							secureControl.changeToLockedState()
						}
					}
					if !secureControl.isLockedState || !note.isLocked {
						Menu {
							if Camera.isAvailable {
								AnimatedActionButton(title: "Take a Photo", systemImage: "camera") {
									imagePicker = .camera
								}
							}
							if PhotoLibrary.isAvailable {
								AnimatedActionButton(title: "Chose a Photo", systemImage: "photo") {
									imagePicker = .library
								}
							}
							DeleteButton(note: note) {
								dismiss()
							}
						} label: {
							Image(systemName: "ellipsis.circle")
						}
					}
				}
				ToolbarItemGroup(placement: .keyboard) {
					keyboardButtons
				}
			}
			
			.fullScreenCover(item: $imagePicker) { imagePicker in
				 switch imagePicker {
				 case .camera:
					 Camera(handlePickerImage: { image in handlePickerImage(image)}).ignoresSafeArea(.all)
				 case .library:
					 PhotoLibrary(handlePickedImage: { image in handlePickerImage(image)})
				 }
			 }
			 .onAppear {
				 _fontSize.wrappedValue = fontStore.fontSettings.fontSize
				 _bold.wrappedValue = fontStore.fontSettings.bold
				 _italic.wrappedValue = fontStore.fontSettings.italic
			 }
			 .onDisappear {
				 saveNote()
				 saveFont(withSize: fontSize, bold: bold, italic: italic)
			 }
		}
	}
	
	func unlockedNote(with geo: GeometryProxy) -> some View {
		VStack {
			TextEditor(text: $note.text)
				.lineSpacing(3)
				.font(displayFont)
				.padding()
				.focused($textIsFocused)
				.frame(minHeight: geo.size.height * 0.7, maxHeight: .infinity)
			if !note.imagesArray.isEmpty {
				lineDivider
				imagesOfNote
					.frame(maxHeight: geo.size.height * 0.25)
			}
		}
	}
	
	var lockedNote: some View {
		VStack {
			Image(systemName: "lock")
				.font(.largeTitle)
			Text("Note is protected")
				.font(.title3)
				.padding(.vertical, 5)
			Button("Remove protection") {
				authenticate {
					secureControl.changeToUnlockedState()
				}
			}
			.font(.title3)
		}
		.padding()
	}
	
	var imagesOfNote: some View {
		ScrollView(.horizontal) {
			HStack(alignment: .bottom, spacing: 10) {
				ForEach(note.imagesArray) { noteImage in
					if let uiImage = UIImage(data: noteImage.data) {
						Image(uiImage: uiImage)
							.resizable()
							.scaledToFit()
							.opacity(selectedImageID == noteImage.id ? 0.8 : 1)
							.padding(.horizontal, 10)
							.overlay {
								if noteImage.id == selectedImageID {
									AnimatedActionButton(title: "Delete Image") {
										note.removeFromImage(noteImage)
										selectedImageID = nil
									}
									.borderedCaption()
								}
							}
							.onTapGesture {
								withAnimation {
									if selectedImageID == noteImage.id {
										selectedImageID = nil
									} else {
										selectedImageID = noteImage.id
									}
								}
							}
					}
				}
			}
		}
		.padding(.bottom)
	}
	
	var lineDivider: some View {
		Rectangle()
			.frame(height: 2)
			.foregroundColor(.gray)
			.padding(.vertical)
	}
	
	var keyboardButtons: some View {
		HStack {
			Toggle(isOn: $bold) {
				Image(systemName: "bold")
			}
			
			Toggle(isOn: $italic) {
				Image(systemName: "italic")
			}

			AnimatedActionButton(systemImage: "textformat.size.smaller") {
				if fontSize >= 16 {
					fontSize -= 5
				}
			}
			
			AnimatedActionButton(systemImage: "textformat.size.larger") {
				if fontSize  <= 40 {
					fontSize  += 5
				}
			}
			Spacer()
			
			AnimatedActionButton(title: "Done") {
				textIsFocused = false
			}
		}
	}
	
	@State private var imagePicker: ImagePickerType?

	enum ImagePickerType: Identifiable {
		case camera
		case library
		var id: ImagePickerType { self }
	}
	
	//MARK: note are not updating image after reuploading it
	private func handlePickerImage(_ image: UIImage?) {
		if let pickedImage = image?.jpegData(compressionQuality: 0.4) {
			let image = NoteImage(context: viewContext)
			image.id = UUID()
			image.date = Date()
			image.data = pickedImage
			note.addToImage(image)
			if viewContext.hasChanges {
				try? viewContext.save()
				note.objectWillChange.send()
			}
		}
		imagePicker = nil
	}
						   
	private func saveFont(withSize fontSize: Int, bold: Bool, italic: Bool) {
		fontStore.saveFont(withSize: fontSize, bold: bold, italic: italic)
	}
	
	private func saveNote() {
		// if note text contains something except "space" or note has at least 1 image need to save it
		// if not -> will delete empty note
		if note.text.first(where: { $0 != " " }) != nil || note.imagesArray.count > 0 {
			
			// if it was new note without folder and other properties -> will add it
			if note.folder == nil {
				note.id = UUID()
				note.isPined = false
				note.isLocked = false
				if let folderIndex = folders.firstIndex(where: { $0.name == "Notes" }) {
					note.folder = folders[folderIndex]
				}
				print("New note was saved")
			}
			note.date = Date()
			
		} else {
			// will find and delete note without text and images
			for folder in folders {
				if folder.notesArray.contains(note) {
					folder.removeFromNotes(note)
				}
			}
		}
		
		if viewContext.hasChanges {
			try? viewContext.save()
		}
	}
}

