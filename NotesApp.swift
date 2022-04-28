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
	var body: some Scene {
		WindowGroup {
			ContentView()
				.environmentObject(fontStore)
				.environment(\.managedObjectContext, dataController.container.viewContext)
		}
	}
}
