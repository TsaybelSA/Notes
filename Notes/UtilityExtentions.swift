//
//  UtilityExtentions.swift
//  Notes
//
//  Created by Сергей Цайбель on 13.04.2022.
//

import SwiftUI


//MARK: convert date
func convertDateToDateString(date: Date, format: String) -> String {
	let dateFormatter = DateFormatter()
	dateFormatter.locale = Locale(identifier: "ru_RU")
	dateFormatter.dateFormat = format
	dateFormatter.calendar = Calendar(identifier: .iso8601)

	let resultDate = dateFormatter.string(from: date)
	return resultDate
}
//
//extension UIImage {
//	
//	var toData: Data? {
//		return pngData()
//	}
//}


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
