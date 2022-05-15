//
//  UtilityView.swift
//  Notes
//
//  Created by Сергей Цайбель on 13.04.2022.
//

import SwiftUI

extension View {
	func dismissableToolbar (_ dismiss: (() -> Void)?) -> some View {
		self.toolbar {
			ToolbarItem(placement: .navigationBarLeading) {
				if let dismiss = dismiss {
					Button("Close") {
						dismiss()
					}
				}
			}
		}
	}
}

struct AnimatedActionButton: View {
	var role: ButtonRole? = nil
	var title: String? = nil
	var systemImage: String? = nil
	let action: () -> Void
	var body: some View {
		Button (role: role) {
			withAnimation {
				action()
			}
		} label: {
			Group {
				if title != nil && systemImage != nil {
					Label(title!, systemImage: systemImage!)
				} else if title != nil {
					Text(title!)
				} else if systemImage != nil {
					Image(systemName: systemImage!)
				}
			}
		}
		
	}
}

struct BorderedCaption: ViewModifier {
	func body(content: Content) -> some View {
		content
			.padding(10)
			.background(.thinMaterial)
			.clipShape(RoundedRectangle(cornerRadius: 15))
			.foregroundColor(Color.red)
			.font(.largeTitle)
	}
}

extension View {
	func borderedCaption() -> some View {
		modifier(BorderedCaption())
	}
}

