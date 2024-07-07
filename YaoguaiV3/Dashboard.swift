//
//  Dashboard.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 7/7/2024.
//

import SwiftUI
import SwiftData

struct Dashboard: View {
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
					WorkoutEditor(workout: workout, onComplete: {
						currentWorkout = nil
					})
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
				.background(.bar)
			}
			.sheet(item: $workoutBeingEdited) { workout in
				WorkoutEditor(workout: workout, onComplete: {})
			}
		}
		
	}
}

struct WorkoutEditor: View {
	let workoutOG: WorkoutRecord
	@State private var workout: WorkoutRecord
	var onComplete: () -> Void
	@Query private var exercises: [Exercise]
	@Environment(\.modelContext) private var modelContext
	
	var body: some View {
		VStack(alignment: .leading) {
			Button("Add Exercise", action: addExercise)
			ForEach(workout.exercises) { exercise in
				ExerciseRecordEditor(exercise: exercise) {
					if let index = workout.exercises.firstIndex(where: { $0 == exercise }) {
						workout.exercises.remove(at: index)
					}
					modelContext.delete(exercise)
				}
				.padding(.bottom)
			}
			
			Button("Complete Workout") {
				// Update the actual workout record with temporary changes
				// This assumes you have logic to update the original workout in modelContext
				onComplete()
			}
			
			Button("Cancel Workout") {
				onComplete()
				// Clean up the temporary edit workout
				modelContext.delete(workout)
			}
		}
		.frame(maxWidth: .infinity)
		.padding()
	}
	
	init(workout: WorkoutRecord, onComplete: @escaping () -> Void) {
		self.workoutOG = workout
		self._workout = State(initialValue: workout)
		self.onComplete = onComplete
	}
	
	func addExercise() {
		let exerciseRecord = ExerciseRecord()
		exerciseRecord.details = exercises.randomElement()
		workout.exercises.append(exerciseRecord)
	}
}

struct ExerciseRecordEditor: View {
	@Bindable var exercise: ExerciseRecord
	var delete: () -> Void
	
	var body: some View {
		VStack(alignment: .leading) {
			HStack {
				Text(exercise.details?.name ?? "")
				Button("Delete", action: delete)
			}
			
			Button("Add Set") {
				exercise.sets.append(SetRecord())
			}
			
			if exercise.sets.count > 0 {
				HStack {
					Rectangle()
						.frame(width: 1)
					VStack {
						ForEach($exercise.sets) { set in
							SetRecordEditor(set: set, delete: {
								if let index = exercise.sets.firstIndex(where: { $0 == set.wrappedValue }) {
									exercise.sets.remove(at: index)
								}
							})
						}
					}
				}
				.padding(.leading)
			}
		}
	}
}

struct SetRecordEditor: View {
	@Binding var set: SetRecord
	var delete: () -> Void
	
	var body: some View {
		HStack {
			Text("Set")
			Button("Delete", action: delete)
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
		
		return Dashboard()
			.modelContainer(modelContainer)
	} catch {
		return Text("Problem bulding ModelContainer.")
	}
}
