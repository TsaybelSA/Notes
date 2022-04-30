//
//  NoteView.swift
//  Notes
//
//  Created by Сергей Цайбель on 28.04.2022.
//

import SwiftUI

struct NoteView: View, Animatable {
	
	@ObservedObject var note: Note
	
	@EnvironmentObject var secureControl: SecureControl
	
	init(_ note: Note) {
		self.note = note
	}
	
	var body: some View {
		if !note.isLocked || !secureControl.isLockedState {
			HStack {
				if note.isLocked {
					Image(systemName: "lock.open")
				}
				VStack(alignment: .leading) {
					Text(note.text)
						.font(.body)
						.lineLimit(3)
					Text(convertDateToDateString(date: note.date, format:"dd.MM.yyyy"))
						.font(.body)
						.fontWeight(.light)
				}
				Spacer()
				imageOfNote(note)
			}
			.contentShape(Rectangle())
			.transition(AnyTransition.opacity)
			
		} else {
				
			lockedNote
		}
	}
	
	var lockedNote: some View {
		HStack(alignment: .center) {
			Spacer()
			Image(systemName: "lock")
			Spacer()
		}
		.contentShape(Rectangle())
		.transition(AnyTransition.opacity)
	}
	
	@ViewBuilder
	func imageOfNote(_ note: Note) -> some View {
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

