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
			.onDisappear {
				if viewModel.isNewWorkout && !viewModel.modelContext.hasChanges {
					viewModel.modelContext.delete(viewModel.workout)
					try? viewModel.modelContext.save()
				}
			}
			.toolbar {
				toolbarContent()
			}
	}
	
	@ToolbarContentBuilder @MainActor
	func toolbarContent() -> some ToolbarContent {
		ToolbarItem(placement: .confirmationAction) {
			Button("Finish") {
				viewModel.saveWorkout()
				dismiss()
			}
			.tint(.green)
		}
		
		ToolbarItem(placement: .destructiveAction) {
			Button("Discard") {
				viewModel.deleteWorkout()
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
		
		func saveWorkout() {
			print("Saving Workout...")
			if modelContext.hasChanges {
				print("Actually saving...")
				try? modelContext.save()
			}
		}
		
		func deleteWorkout() {
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
