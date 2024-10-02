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
			WorkoutTemplate.self
		])
		
		let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
		
		do {
			let modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
			self.sharedModelContainer = modelContainer
			self._workoutManager = State(initialValue: WorkoutManager(modelContext: modelContainer.mainContext))
		} catch {
			fatalError("Could not create ModelContainer: \(error)")
		}
	}
	
	var body: some Scene {
		WindowGroup {
			TabView {
				Group {
					Dashboard()
						.tabItem {
							Label("Home", systemImage: "figure.dance")
						}
					
					WorkoutTemplateList()
						.tabItem {
							Label("Templates", systemImage: "list.bullet.rectangle.fill")
						}
					
					ExerciseDetailList()
						.tabItem {
							Label("Exercises", systemImage: "list.bullet")
						}
				}
				.safeAreaInset(edge: .bottom) {
					ModelCounter()
				}
			}
		}
		.modelContainer(sharedModelContainer)
		.environment(workoutManager)
	}
	
	struct ModelCounter: View {
		@Query private var exercises: [Exercise]
		@Query private var exerciseRecords: [ExerciseRecord]
		@Query private var workoutRecords: [WorkoutRecord]
		
		var body: some View {
			VStack {
				Text("Exercises count: \(exercises.count)")
				Text("ExerciseRecords count: \(exerciseRecords.count)")
				Text("WorkoutRecords count: \(workoutRecords.count)")
			}
			.font(.footnote.monospaced())
			.foregroundStyle(.secondary)
			.frame(maxWidth: .infinity)
			.padding()
		}
	}
}

