//
//  SecureControl.swift
//  Notes
//
//  Created by Сергей Цайбель on 29.04.2022.
//

import LocalAuthentication
import SwiftUI

class ViewModel: ObservableObject {

	private(set) var wasUnlockedInCurrentSession = false
	
	@Published private(set) var isLockedState = true {
		didSet {
			if isLockedState == false {
				wasUnlockedInCurrentSession = true
			}
			print("changed loskState to \(isLockedState)")
		}
	}
	
	@Published var showingAlert = false
	@Published var alertTitle = ""
	@Published var alertMessage = ""

	
	func currentSessionIsOver() {
		wasUnlockedInCurrentSession = false
	}
	
	func changeToLockedState() {
		isLockedState = true
	}
	
	func changeToUnlockedState() {
		isLockedState = false
	}
	
	func authenticate(ifSucceed: (() -> Void)? = nil) {
		let context = LAContext()
		var error: NSError?
		if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
			let reason = "We need it to control access to notes"
			
			context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
				if success {
					//authenticated successfully
					Task { @MainActor in
						self.isLockedState = false
					}
					ifSucceed?()
				} else {
					//there was a problem
					// only for learning
//					Task { @MainActor in
//						self.alertTitle = "Failed to authenticate with biometrics!"
//						self.alertMessage = "Please try again."
//						self.showingAlert = true
//					}
				}
			}
		} else {
			//no biometrics
			Task { @MainActor in
				alertTitle = "Failed to authenticate with biometrics!"
				alertMessage = "Check settings of Notes App to give permission."
				showingAlert = true
			}
		}
	}
	
	init() {}
}
