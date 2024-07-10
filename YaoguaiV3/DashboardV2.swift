//
//  DashboardV2.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 10/7/2024.
//

import SwiftUI
import SwiftData

struct DashboardV2: View {
	@Environment(\.modelContext) private var modelContext
	
	@Query private var exercises: [Exercise]
	@Query private var exerciseRecords: [ExerciseRecord]
	@Query private var workoutRecords: [WorkoutRecord]
	
	// For new workouts (presented on main screen)
	@State private var currentWorkout: WorkoutRecord? = nil
	
	// For existing workouts (presented in sheet)
	@State private var workoutBeingEdited: WorkoutRecord? = nil
	
	var body: some View {
		NavigationStack {
			ScrollView {
				if let workout = currentWorkout {
//					WorkoutEditorV2(workout: workout, onComplete: {
//						currentWorkout = nil
//					})
				} else {
					Button("Start Workout") {
						currentWorkout = WorkoutRecord()
					}
					
					ForEach(workoutRecords) { workout in
						HStack {
							Text(workout.name)
							Button("Edit") {
								workoutBeingEdited = workout
							}
						}
					}
				}
			}
			.safeAreaInset(edge: .bottom) {
				VStack {
					Text("exercises count: \(exercises.count)")
					Text("exerciseRecords count: \(exerciseRecords.count)")
					Text("workoutRecords count: \(workoutRecords.count)")
				}
				.frame(maxWidth: .infinity)
				.padding()
				.background(.bar)
			}
			.sheet(item: $workoutBeingEdited) { workout in
				WorkoutEditorV2(workoutId: workout.id, in: modelContext.container)
			}
		}
	}
}

struct WorkoutEditorV2: View {
	@Environment(\.dismiss) var dismiss
	@Bindable var workout: WorkoutRecord
	@Query private var exercises: [Exercise]

	var modelContext: ModelContext

	init(workoutId: PersistentIdentifier, in container: ModelContainer, autosave: Bool = false) {
		modelContext = ModelContext(container)
		modelContext.autosaveEnabled = autosave
		workout = modelContext.model(for: workoutId) as? WorkoutRecord ?? WorkoutRecord()
	}
	
	func getExerciseDetail(for exerciseId: PersistentIdentifier) -> Exercise {
		return modelContext.model(for: exerciseId) as? Exercise ?? Exercise(name: "AUTO_GENERATED")
	}
	
	var body: some View {
		NavigationStack {
			VStack {
				ForEach(workout.exercises) { exercise in
					ExerciseRecordEditor(exercise: exercise, delete: {
						if let index = workout.exercises.firstIndex(where: { $0 == exercise }) {
							workout.exercises.remove(at: index)
						}
						modelContext.delete(exercise)
					})
					.padding(.bottom)
				}
				
				Button("Add Random Exercise") {
					if let exerciseDetails = exercises.randomElement() {
						let record = ExerciseRecord()
						record.details = getExerciseDetail(for: exerciseDetails.id)
						workout.exercises.append(record)
					}
				}
			}
			.toolbar {
				Button("Discard") {
					dismiss()
				}
				
				Button("Save") {
					try? modelContext.save()
					dismiss()
				}
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
		
		return DashboardV2()
			.modelContainer(modelContainer)
	} catch {
		return Text("Problem bulding ModelContainer.")
	}
}
