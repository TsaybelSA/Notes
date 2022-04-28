//
//  FontStore.swift
//  Notes
//
//  Created by Сергей Цайбель on 23.04.2022.
//

import SwiftUI

struct FontSettings: Codable {
	var fontSize = 20
	var bold = false
	var italic = false
}

class FontStore: ObservableObject {
										// (fontSize, bold, italic)
	@Published private(set) var fontSettings = FontSettings() {
		didSet {
			storeInUserDefaults()
			print(fontSettings.fontSize)
		}
	}
	
	// will save font after closing view
	func saveFont(withSize fontSize: Int, bold: Bool, italic: Bool) {
		self.fontSettings = FontSettings(fontSize: fontSize, bold: bold, italic: italic)
	}
	
	init() {
		restoreFromUserDefaults()
	}
	
	private var userDefaultKey = "FontSettings"
	
	private func storeInUserDefaults() {
		UserDefaults.standard.set(try? JSONEncoder().encode(fontSettings), forKey: userDefaultKey)
	}
	
	private func restoreFromUserDefaults() {
		if let json = UserDefaults.standard.data(forKey: userDefaultKey) {
			if let decodedFontSettings = try? JSONDecoder().decode(FontSettings.self, from: json) {
				fontSettings = decodedFontSettings
			}
		}
	}

}
