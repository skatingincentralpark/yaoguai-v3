//
//  WorkoutRecordEditorWrapper.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 21/8/2024.
//

import SwiftUI
import SwiftData

/// We use the main context for the WorkoutManager
/// But, for the ViewModel, we use the child context
struct WorkoutRecordEditorWrapper: View {
	@Environment(\.dismiss) var dismiss
	@Environment(CurrentWorkoutManager.self) private var workoutManager
	@State private var viewModel: ViewModel
	
	init(workoutId: PersistentIdentifier,
		 in container: ModelContainer,
		 isNewWorkout: Bool = false
	) {
		self.viewModel = ViewModel(workoutId: workoutId, in: container, isNewWorkout: isNewWorkout)
	}
	
	var body: some View {
		NavigationStack {
			WorkoutEditor(workout: viewModel.workout, modelContext: viewModel.modelContext)
				.toolbar {
					if viewModel.isNewWorkout {
						newWorkoutToolbar()
					} else {
						existingWorkoutToolbar()
					}
				}
		}
	}
	
	@ToolbarContentBuilder @MainActor
	func newWorkoutToolbar() -> some ToolbarContent {
		ToolbarItem(placement: .confirmationAction) {
			Button("Finish") {
				workoutManager.complete()
				dismiss()
			}
			.tint(.green)
		}
		
		ToolbarItem(placement: .destructiveAction) {
			Button("Discard") {
				workoutManager.cancel()
				dismiss()
			}
			.tint(.red)
		}
		
		ToolbarItem(placement: .cancellationAction) {
			Button("Hide") {
				dismiss()
			}
		}
	}
	
	@ToolbarContentBuilder @MainActor
	func existingWorkoutToolbar() -> some ToolbarContent {
		ToolbarItem(placement: .confirmationAction) {
			Button("Save") {
				viewModel.saveExistingWorkout()
				dismiss()
			}
			.tint(.green)
		}
		
		ToolbarItem(placement: .destructiveAction) {
			Button("Delete") {
				viewModel.deleteExistingWorkout()
				dismiss()
			}
			.tint(.red)
		}
		
		ToolbarItem(placement: .cancellationAction) {
			Button("Cancel") {
				dismiss()
			}
		}
	}
}

extension WorkoutRecordEditorWrapper {
	@Observable
	class ViewModel {
		var workout: WorkoutRecord
		let modelContext: ModelContext
		let isNewWorkout: Bool
		
		init(workoutId: PersistentIdentifier,
			 in container: ModelContainer,
			 isNewWorkout: Bool = false
		) {
			self.modelContext = ModelContext(container)
			self.modelContext.autosaveEnabled = isNewWorkout ? true : false
			self.workout = modelContext.model(for: workoutId) as? WorkoutRecord ?? WorkoutRecord()
			self.isNewWorkout = isNewWorkout
		}
		
		func saveExistingWorkout() {
			if modelContext.hasChanges {
				try? modelContext.save()
			}
		}
		
		func deleteExistingWorkout() {
			/// I think we have to explicitly delete the child exercises as we're in a nested context...
			try? modelContext.transaction {
				workout.exercises.forEach { exercise in
					modelContext.delete(exercise)
				}
				
				modelContext.delete(workout)
			}
		}
	}
}
