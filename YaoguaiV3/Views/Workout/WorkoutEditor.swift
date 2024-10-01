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
	@State private var exerciseListSheetShown = false
	
	init(workout: T, modelContext: ModelContext) {
		self.workout = workout
		self.modelContext = modelContext
	}
	
	var body: some View {
		ScrollView {
			VStack(alignment: .leading) {
				TextField("Name", text: $workout.name)
				Button("Add Exercise") {
					exerciseListSheetShown = true
				}
				ExerciseList(workout: workout, modelContext: modelContext)
			}
			.padding()
			.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
		}
		.sheet(isPresented: $exerciseListSheetShown, content: {
			ExerciseDetailList { exerciseDetails in
				if let exercise = modelContext.model(for: exerciseDetails.id) as? Exercise {
					workout.addExercise(details: exercise)
				} else {
					fatalError("Exercise not found.")
				}
			}
		})
	}
	
	struct ExerciseList: View {
		@Bindable var workout: T
		let modelContext: ModelContext
		
		var body: some View {
			ForEach(workout.orderedExercises) { exercise in
				ExerciseEditor(
					exercise: exercise,
					delete: {
						workout.removeExercise(exercise)
						modelContext.delete(exercise)
					},
					modelContext: modelContext
				)
				.padding(.bottom)
			}
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
