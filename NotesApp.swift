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
	
	//by observing the changes in this parameter for the main screen
	//can judge whether it is necessary to lock notes
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
					
			//after changing scenePhase to "active" from "inactive" (it means app wasn`t closed)
			//need to check had app been already unlocked, if so change "isLockState" to false
			case .active:
					if secureControl.wasUnlockedInCurrentSession == true {
						secureControl.changeToUnlockedState()
					}
					print("ScenePhase: active")
					
			//changing scenePhase to "background" or "inactive"
			//cause change lockState (all secured notes will be invisible)
			//if scenePhase "background" need to change "wasUnlockedInCurrentSession" to false
			//because current session was over
			case .background:
					print("ScenePhase: background")
					secureControl.currentSessionIsOver()
					secureControl.changeToLockedState()
			case .inactive:
					secureControl.changeToLockedState()
					print("ScenePhase: inactive")
			@unknown default: print("ScenePhase: unexpected state")
			}
		}
	}
}
