//
//  EditNoteView.swift
//  Notes
//
//  Created by Сергей Цайбель on 23.04.2022.
//

import SwiftUI

struct EditNoteView: View {
	@Environment(\.managedObjectContext) var context
	
	@ObservedObject var note: Note
	
	@EnvironmentObject var fontStore: FontStore
	
	@Environment(\.dismiss) var dismiss
	
	@State private var bold = false
	@State private var italic = false
	@State private var fontSize = 20
	
	var displayFont: Font {
		let font = Font.system(size: CGFloat(fontSize),
			weight: bold == true ? .bold : .regular)
		return italic == true ? font.italic() : font
	}
	
	@State private var imageIsChosen = false
	@FocusState private var textIsFocused: Bool
	
    var body: some View {
		NavigationView {
			ZStack {
				if !note.isLocked {
					VStack {
						TextEditor(text: $note.text)
							.lineSpacing(3)
							.font(displayFont)
							.padding()
							.focused($textIsFocused)
						HStack {
							imageOfNote
								.onTapGesture {
									withAnimation {
										imageIsChosen.toggle()
									}
								}
						}
					}
				} else {
					lockedNote
						.transition(AnyTransition.scale)
				}
				
			}
			.dismissableToolbar() {
				dismiss()
			}
			.toolbar {
				ToolbarItemGroup(placement: .navigationBarTrailing) {
					AnimatedActionButton(systemImage: "ellipsis.circle") {
					}
					.contextMenu {
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
					}
				}
				ToolbarItemGroup(placement: .keyboard) {
					buttonsList
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
			 .navigationTitle(note.isLocked ? "" : "Edit Note")

		}
	}
	
	var lockedNote: some View {
		ZStack {
			VStack {
				Spacer()
				Image(systemName: "lock")
					.font(.largeTitle)
				Text("Note is protected")
					.font(.title3)
					.padding(.vertical, 5)
				Button("Remove protection") {
					authenticate {
						note.isLocked.toggle()
					}
				}
				.font(.title3)
				.padding(.vertical, 5)
				Spacer()
			}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background(.ultraThickMaterial)

	}
	
	@ViewBuilder
	var imageOfNote: some View {
		if let data = note.images, let uiImage = UIImage(data: data as Data) {
			Image(uiImage: uiImage)
				.resizable()
				.aspectRatio(contentMode: .fit)
				.opacity(imageIsChosen ? 0.8 : 1)
				.padding()
				.overlay {
					if imageIsChosen {
						AnimatedActionButton(title: "Delete Image") {
							note.images = nil
							imageIsChosen = false
						}
						.borderedCaption()
					}
				}
		}
	}
	
	var buttonsList: some View {
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
		let pickedImage = image?.jpegData(compressionQuality: 0.5)
		note.images = pickedImage as NSData?
		try? context.save()
		imagePicker = nil
		note.objectWillChange.send()
	}
						   
	private func saveFont(withSize fontSize: Int, bold: Bool, italic: Bool) {
		fontStore.saveFont(withSize: fontSize, bold: bold, italic: italic)
	}
	
	private func saveNote() {
		note.date = Date()
		try? context.save()
	}
}

