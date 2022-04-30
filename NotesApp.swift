//
//  NotesApp.swift
//  Notes
//
//  Created by Сергей Цайбель on 28.04.2022.
//

import SwiftUI

@main
struct NotesApp: App {
	@StateObject private var dataController = DataController()
	@State private var fontStore = FontStore()
	@State private var secureControl = SecureControl()
	
	@Environment(\.scenePhase) var scenePhase
	
	var body: some Scene {
		WindowGroup {
			ContentView()
				.environmentObject(secureControl)
				.environmentObject(fontStore)
				.environment(\.managedObjectContext, dataController.container.viewContext)
		}
		.onChange(of: scenePhase) { (phase) in
			switch phase {
			case .active:
					print("ScenePhase: active")
			case .background:
					print("ScenePhase: background")
					secureControl.changeToLockedState()
			case .inactive:
					print("ScenePhase: inactive")
			@unknown default: print("ScenePhase: unexpected state")
			}
		}
	}
}
