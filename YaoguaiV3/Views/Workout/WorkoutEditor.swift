//
//  WorkoutEditor.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 21/8/2024.
//

import SwiftUI
import SwiftData

struct WorkoutEditor<T: WorkoutCommon>: View {
	@Bindable var workout: T
	let modelContext: ModelContext
	
	init(workout: T, modelContext: ModelContext) {
		self.workout = workout
		self.modelContext = modelContext
		//		print("Initialising WorkoutEditor")
	}
	
	var body: some View {
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
	
	struct ExerciseList: View {
		@Bindable var workout: T
		let modelContext: ModelContext
		
		var body: some View {
			ForEach(workout.orderedExercises) { exercise in
				ExerciseEditor(exercise: exercise, delete: {
					workout.removeExercise(exercise)
					modelContext.delete(exercise)
				})
				.padding(.bottom)
			}
		}
	}
	
	struct AddRandomExerciseButton: View {
		@Query private var exercises: [Exercise]
		@Bindable var workout: T
		let modelContext: ModelContext
		
		func getExerciseDetail(for exerciseId: PersistentIdentifier) -> Exercise {
			return modelContext.model(for: exerciseId) as? Exercise ?? Exercise(name: "AUTO_GENERATED")
		}
		
		var body: some View {
			Button("Add Random Exercise") {
				guard let exerciseDetails = exercises.randomElement() else { return }
				workout.addExercise(with: getExerciseDetail(for: exerciseDetails.id))
				print("workout.exercises.count: \(workout.exercises.count)")
			}
			.padding(.bottom)
		}
	}
}

#Preview(traits: .sizeThatFitsLayout) {
	do {
		let (container, _) = try setupPreview()
		
		let workout = getWorkoutRecord(container.mainContext)
		
		container.mainContext.insert(workout)
		
		return WorkoutEditor(workout: workout, modelContext: container.mainContext)
			.modelContainer(container)
	}  catch {
		return Text("Failed to build preview")
	}
}
