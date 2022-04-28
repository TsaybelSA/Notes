//
//  NoteView.swift
//  Notes
//
//  Created by Сергей Цайбель on 28.04.2022.
//

import SwiftUI

struct NoteView: View, Animatable {
	
	init(_ note: Note) {
		self.note = note
	}
	
	@ObservedObject var note: Note

	
	var body: some View {
		if !note.isLocked {
			HStack {
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
		if let data = note.images, let uiImage = UIImage(data: data as Data) {
			Image(uiImage: uiImage)
				.resizable()
				.aspectRatio(contentMode: .fit)
				.frame(maxHeight: 100)
		}
	}
}

//struct NoteView_Previews: PreviewProvider {
//    static var previews: some View {
//        NoteView()
//    }
//}
