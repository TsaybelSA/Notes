////
////  FlexibleSheet.swift
////  Notes
////
////  Created by Сергей Цайбель on 25.04.2022.
////
//
//import SwiftUI
//
//enum SheetMode {
//	case none
//	case half
//	case full
//}
//
//struct FlexibleSheet: View {
//	
//	var note: Note
//	
//	var sheetMode: Binding<SheetMode>
//	@Binding private var bold: Bool
//	@Binding private var italic: Bool
//	@Binding private var underline: Bool
//	@Binding private var fontSize: Int
//
//
//	
//    var body: some View {
//		VStack {
//			
//			buttonsMenu
//			MenuForNote(note: note)
//
//			Spacer()
//		}
//		.toolbar {
//			ToolbarItemGroup(placement: .keyboard) {
//				buttonsMenu
//			}
//		}
//		.frame(maxWidth: .infinity, maxHeight: .infinity)
//		.background(.ultraThickMaterial)
//		.clipShape(RoundedRectangle(cornerRadius: 25.0, style: .continuous))
//		.offset(y: calculateOffset())
//    }
//	
//	@ViewBuilder
//	func notePreview(note: Note) -> some View {
//		
//	}
//	
//	private func calculateOffset() -> CGFloat {
//		switch sheetMode.wrappedValue {
//			case .none:
//				return UIScreen.main.bounds.height
//			case .half:
//				return UIScreen.main.bounds.height / 2
//			case .full:
//				return 50
//		}
//	}
//	var buttonsMenu: some View {
//		HStack {
//			Toggle(isOn: $bold) {
//				Image(systemName: "bold")
//			}
//			
//			Toggle(isOn: $italic) {
//				Image(systemName: "italic")
//			}
//			
//			Toggle(isOn: $underline) {
//				Image(systemName: "underline")
//			}
//
//			AnimatedActionButton(systemImage: "textformat.size.smaller") {
//				if fontSize >= 16 {
//					fontSize -= 5
//				}
//			}
//			
//			AnimatedActionButton(systemImage: "textformat.size.larger") {
//				if fontSize  <= 40 {
//					fontSize  += 5
//				}
//			}
//		}
//	}
//}
//
