//
//  SecureControl.swift
//  Notes
//
//  Created by Сергей Цайбель on 29.04.2022.
//

import SwiftUI

@MainActor
class SecureControl: ObservableObject {

	private(set) var wasUnlockedInCurrentSession = false
	
	private(set) var isLockedState = true {
		didSet {
			if isLockedState == false {
				wasUnlockedInCurrentSession = true
			}
			print("changed loskState to \(isLockedState)")
			Task {
				await MainActor.run {
					objectWillChange.send()
				}
			}
		}
	}
	
	func currentSessionIsOver() {
		wasUnlockedInCurrentSession = false
	}
	
	func changeToLockedState() {
		isLockedState = true
	}
	
	func changeToUnlockedState() {
		isLockedState = false
	}
	
	init() {}
}
