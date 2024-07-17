//
//  YaoguaiV3App.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 7/7/2024.
//

import SwiftUI
import SwiftData

@main
struct YaoguaiV3App: App {
	var sharedModelContainer: ModelContainer
	@State private var workoutManager: WorkoutManager
	
	init() {
		let schema = Schema([
			WorkoutRecord.self,
		])
		
		let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
		
		do {
			let modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
			//			try modelContainer.mainContext.delete(model: Exercise.self)
			//			try modelContainer.mainContext.delete(model: ExerciseRecord.self)
			//			try modelContainer.mainContext.delete(model: WorkoutRecord.self)
			//				return try ModelContainer(for: schema, configurations: [modelConfiguration])
			self.sharedModelContainer = modelContainer
			self._workoutManager = State(initialValue: WorkoutManager(modelContext: modelContainer.mainContext))
		} catch {
			fatalError("Could not create ModelContainer: \(error)")
		}
	}
	
	var body: some Scene {
		WindowGroup {
			DashboardV2(workoutManager: workoutManager)
		}
		.modelContainer(sharedModelContainer)
//		.environment(workoutManager)
	}
}
