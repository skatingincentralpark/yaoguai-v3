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
			List {
				Section("Development Helpers") {
					Button("Add Dummy Exercise Details", action: addDummyExercises)
					Button("Delete Exercise Records", role: .destructive, action: {
						try? modelContext.delete(model: ExerciseRecord.self)
					})
					Button("Delete Exercise Details", role: .destructive) {
						try? modelContext.delete(model: Exercise.self)
					}
				}
				
				Section("Start Workout") {
					if workoutManager.currentWorkout != nil {
						Button("Continue Workout"){
							newWorkoutSheetShowing.toggle()
						}
					} else {
						Button("Start New Workout") {
							workoutManager.startNewWorkout()
							newWorkoutSheetShowing.toggle()
						}
					}
					
					WorkoutList()
				}
				
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
		let pullups = Exercise(name: "Pullups", category: .weightAndReps)
		let pushups = Exercise(name: "Pushups", category: .weightAndReps)
		
		modelContext.insert(pullups)
		modelContext.insert(pushups)
	}
	
	struct WorkoutList: View {
		@Query private var workoutRecords: [WorkoutRecord]
		@State private var workoutBeingEdited: WorkoutRecord? = nil
		@Environment(\.modelContext) private var modelContext
		@Environment(WorkoutManager.self) private var workoutManager
		var workoutRecordsFiltered: [WorkoutRecord] {
			workoutRecords.filter { $0.id != workoutManager.currentWorkoutId }
		}
		
		var body: some View {
			VStack {
				if workoutRecordsFiltered.isEmpty {
					Label("No Workouts Yet", systemImage: "person.and.background.dotted")
						.foregroundStyle(.secondary)
				} else {
					ForEach(workoutRecordsFiltered) { workout in
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
			}
			.sheet(item: $workoutBeingEdited) { workout in
				WorkoutEditorWrapper(workoutId: workout.id, in: modelContext.container)
			}
		}
	}
}

#Preview {
	do {
		let (container, workoutManager) = try setupPreview()
		
		return Dashboard()
			.modelContainer(container)
			.environment(workoutManager)
	} catch {
		return Text("Failed to build preview")
	}
}
