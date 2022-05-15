//
//  UtilityExtentions.swift
//  Notes
//
//  Created by Сергей Цайбель on 13.04.2022.
//

import LocalAuthentication

import SwiftUI

extension Array where Element == NSItemProvider {
	func loadObjects<T>(ofType theType: T.Type, firstOnly: Bool = false, using load: @escaping (T) -> Void) -> Bool where T: NSItemProviderReading {
		if let provider = first(where: { $0.canLoadObject(ofClass: theType) }) {
			provider.loadObject(ofClass: theType) { object, error in
				if let value = object as? T {
					DispatchQueue.main.async {
						load(value)
					}
				}
			}
			return true
		}
		return false
	}
	func loadObjects<T>(ofType theType: T.Type, firstOnly: Bool = false, using load: @escaping (T) -> Void) -> Bool where T: _ObjectiveCBridgeable, T._ObjectiveCType: NSItemProviderReading {
		if let provider = first(where: { $0.canLoadObject(ofClass: theType) }) {
			let _ = provider.loadObject(ofClass: theType) { object, error in
				if let value = object {
					DispatchQueue.main.async {
						load(value)
					}
				}
			}
			return true
		}
		return false
	}
	func loadFirstObject<T>(ofType theType: T.Type, using load: @escaping (T) -> Void) -> Bool where T: NSItemProviderReading {
		loadObjects(ofType: theType, firstOnly: true, using: load)
	}
	func loadFirstObject<T>(ofType theType: T.Type, using load: @escaping (T) -> Void) -> Bool where T: _ObjectiveCBridgeable, T._ObjectiveCType: NSItemProviderReading {
		loadObjects(ofType: theType, firstOnly: true, using: load)
	}
}



func authenticate(ifSucceed: @escaping () -> Void) {
	let context = LAContext()
	var error: NSError?
	if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
		let reason = "We need it to control access to notes"
		
		context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
			if success {
				//authenticated successfully
				//run the code below 
				ifSucceed()
			} else {
				//there was a problem
				
			}
		}
	} else {
		//no biometrics
		
	}
}
