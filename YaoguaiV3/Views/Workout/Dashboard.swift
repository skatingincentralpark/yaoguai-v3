//
//  Dashboard.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 10/7/2024.
//

import SwiftUI
import SwiftData

struct Dashboard: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(WorkoutManager.self) private var workoutManager
	
	@State var newWorkoutSheetShowing = false
	
	var body: some View {
		NavigationStack {
			Button("Delete Exercise Records", role: .destructive, action: {
				try? modelContext.delete(model: ExerciseRecord.self)
			})
			.buttonStyle(.bordered)
			.padding()
			
			ScrollView {
				if workoutManager.currentWorkout != nil {
					Button("Continue Workout"){
						newWorkoutSheetShowing.toggle()
					}
					.buttonStyle(.bordered)
				} else {
					Button("Add Dummy Exercise Details", action: addDummyExercises)
					
					Button("Start New Workout") {
						workoutManager.startNewWorkout()
						newWorkoutSheetShowing.toggle()
					}
					.buttonStyle(.bordered)
					
					WorkoutList()
				}
			}
			.padding()
			.safeAreaInset(edge: .bottom) {
				ModelCounter()
			}
			.sheet(isPresented: $newWorkoutSheetShowing) {
				if let workout = workoutManager.currentWorkout {
					WorkoutEditorWrapper(workoutId: workout.id, in: modelContext.container, isNewWorkout: true)
				} else {
					Text("Loading...")
				}
			}
		}
	}
	
	func addDummyExercises() {
		let pullups = Exercise(name: "Pullups")
		let pushups = Exercise(name: "Pushups")
		
		modelContext.insert(pullups)
		modelContext.insert(pushups)
	}
	
	struct ModelCounter: View {
		@Query private var exercises: [Exercise]
		@Query private var exerciseRecords: [ExerciseRecord]
		@Query private var workoutRecords: [WorkoutRecord]
		
		var body: some View {
			VStack {
				Text("exercises count: \(exercises.count)")
				Text("exerciseRecords count: \(exerciseRecords.count)")
				Text("workoutRecords count: \(workoutRecords.count)")
			}
			.frame(maxWidth: .infinity)
			.padding()
			.background(.bar)
		}
	}
	
	struct WorkoutList: View {
		@Query private var workoutRecords: [WorkoutRecord]
		@State private var workoutBeingEdited: WorkoutRecord? = nil
		@Environment(\.modelContext) private var modelContext
		@Environment(WorkoutManager.self) private var workoutManager
		
		var body: some View {
			VStack {
				ForEach(workoutRecords) { workout in
					HStack {
						Text(workout.name)
						Button("Edit") {
							workoutBeingEdited = workout
						}
						Button("Delete") {
							modelContext.delete(workout)
						}
					}
				}
			}
			.sheet(item: $workoutBeingEdited) { workout in
				WorkoutEditorWrapper(workoutId: workout.id, in: modelContext.container)
			}
		}
	}
}

#Preview {
	do {
		let modelContainer: ModelContainer
		modelContainer = try ModelContainer(for: WorkoutRecord.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
		
		let pullups = Exercise(name: "Pullups")
		let pushups = Exercise(name: "Pushups")
		
		modelContainer.mainContext.insert(pullups)
		modelContainer.mainContext.insert(pushups)
		
		@MainActor
		func addWorkoutRecord() {
			let record1 = WorkoutRecord(name: "Upper")
			let exercise1 = ExerciseRecord()
			let exercise2 = ExerciseRecord()
			modelContainer.mainContext.insert(exercise1)
			modelContainer.mainContext.insert(exercise2)
			exercise1.details = pullups
			exercise2.details = pushups
			record1.exercises = [exercise1, exercise2]
			modelContainer.mainContext.insert(record1)
		}
		
		addWorkoutRecord()
		
		let workoutManager = WorkoutManager(modelContext: modelContainer.mainContext)
		
		return Dashboard()
			.modelContainer(modelContainer)
			.environment(workoutManager)
	} catch {
		return Text("Problem bulding ModelContainer.")
	}
}
