//
//  WorkoutEditor.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 21/8/2024.
//

import SwiftUI
import SwiftData

struct WorkoutEditor: View {
	@Bindable var workout: WorkoutRecord
	let modelContext: ModelContext
	
	init(workout: WorkoutRecord, modelContext: ModelContext) {
		self.workout = workout
		self.modelContext = modelContext
		//		print("Initialising WorkoutEditor")
	}
	
	var body: some View {
		NavigationStack {
			ScrollView {
				VStack(alignment: .leading) {
					TextField("Name", text: $workout.name)
					AddRandomExerciseButton(workout: workout, modelContext: modelContext)
					ExerciseList(workout: workout, modelContext: modelContext)
				}
				.padding()
				.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
			}
		}
	}
	
	struct ExerciseList: View {
		@Bindable var workout: WorkoutRecord
		let modelContext: ModelContext
		
		var body: some View {
			ForEach(workout.orderedExercises) { exercise in
				ExerciseRecordEditor(exercise: exercise, delete: {
					workout.exercises.removeFirst { $0 == exercise }
					modelContext.delete(exercise)
				})
				.padding(.bottom)
			}
		}
	}
	
	struct AddRandomExerciseButton: View {
		@Query private var exercises: [Exercise]
		@Bindable var workout: WorkoutRecord
		let modelContext: ModelContext
		
		func getExerciseDetail(for exerciseId: PersistentIdentifier) -> Exercise {
			return modelContext.model(for: exerciseId) as? Exercise ?? Exercise(name: "AUTO_GENERATED")
		}
		
		var body: some View {
			Button("Add Random Exercise") {
				if let exerciseDetails = exercises.first {
					let record = ExerciseRecord()
					record.details = getExerciseDetail(for: exerciseDetails.id)
					workout.exercises.append(record)
					print("workout.exercises.count: \(workout.exercises.count)")
				} else {
					print("🚨 No exercises found.  None added.")
				}
			}
			.padding(.bottom)
		}
	}
}
