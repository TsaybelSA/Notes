//
//  SecureControl.swift
//  Notes
//
//  Created by Сергей Цайбель on 29.04.2022.
//

import SwiftUI

@MainActor
class SecureControl: ObservableObject {
	
	private(set) var isLockedState = true {
		didSet {
			Task {
				await MainActor.run {
					objectWillChange.send()
				}
			}
		}
	}
	
	func changeToLockedState() {
		isLockedState = true
	}
	
	func changeToUnlockedState() {
		isLockedState = false
	}
	
	init() {}
}
