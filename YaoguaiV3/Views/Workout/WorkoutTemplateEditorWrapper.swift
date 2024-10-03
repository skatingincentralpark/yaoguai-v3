//
//  WorkoutTemplateEditorWrapper.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 21/8/2024.
//

import SwiftUI
import SwiftData

struct WorkoutTemplateEditorWrapper: View {
	@Environment(\.dismiss) var dismiss
	@State private var viewModel: ViewModel
	
	init(workoutId: PersistentIdentifier,
		 in container: ModelContainer,
		 isNewWorkout: Bool = false
	) {
		self.viewModel = ViewModel(workoutId: workoutId, in: container, isNewWorkout: isNewWorkout)
	}
	
	var body: some View {
		WorkoutEditor(workout: viewModel.workout, modelContext: viewModel.modelContext)
			.toolbar {
				if viewModel.isNewWorkout {
					newToolbarContent()
				} else {
					existingToolbarContent()
				}
			}
	}
	
	@ToolbarContentBuilder @MainActor
	func existingToolbarContent() -> some ToolbarContent {
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
	
	@ToolbarContentBuilder @MainActor
	func newToolbarContent() -> some ToolbarContent {
		ToolbarItem(placement: .confirmationAction) {
			Button("Save") {
				viewModel.completeNewWorkout()
				dismiss()
			}
			.tint(.green)
		}
		
		ToolbarItem(placement: .destructiveAction) {
			Button("Discard") {
				viewModel.cancelNewWorkout()
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

extension WorkoutTemplateEditorWrapper {
	@Observable
	class ViewModel {
		var workout: WorkoutTemplate
		let modelContext: ModelContext
		let isNewWorkout: Bool
		
		init(workoutId: PersistentIdentifier,
			 in container: ModelContainer,
			 isNewWorkout: Bool = false
		) {
			self.modelContext = ModelContext(container)
			self.modelContext.autosaveEnabled = false
			self.workout = modelContext.model(for: workoutId) as? WorkoutTemplate ?? WorkoutTemplate()
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
		
		func cancelNewWorkout() {
			try? modelContext.transaction {
				modelContext.delete(workout)
				
				// Although these will be cascade deleted, it won't happen immediately, XCTest assertions fail
				workout.exercises.forEach { template in
					modelContext.delete(template)
				}
			}
		}
		
		func completeNewWorkout() {
			track("💾 Attempting to save")
			
			if workout.name.isEmpty {
				track("⚠️ Didn't save, name can't be empty")
				modelContext.delete(workout)
				try? modelContext.save()
				return
			}
			
			if workout.exercises.count == 0 {
				track("⚠️ Didn't save, exercises can't be empty")
				modelContext.delete(workout)
				try? modelContext.save()
				return
			}
			
			try? modelContext.save()
		}
	}
}
