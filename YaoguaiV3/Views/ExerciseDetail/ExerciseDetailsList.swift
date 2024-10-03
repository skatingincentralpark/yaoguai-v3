//
//  ExerciseDetailsList.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 28/9/2024.
//

import SwiftUI
import SwiftData

struct ExerciseDetailsList: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) private var dismiss
	
	@Query private var exercises: [Exercise]
	
	var category: ExerciseCategory?
	
	var exercisesFiltered: [Exercise] {
		if let category = category {
			return exercises.filter { $0.category == category }
		}
		
		return exercises
	}
	
	@State private var newExerciseSheetPresented = false
	@State private var exerciseToEdit: Exercise? = nil
	
	var onSelect: ((Exercise) -> Void)?
	
	init(onSelect: ((Exercise) -> Void)? = nil, category: ExerciseCategory? = nil) {
		self.onSelect = onSelect
		self.category = category
	}
	
	var body: some View {
		NavigationStack {
			List {
				Button("Add New Exercise") {
					newExerciseSheetPresented = true
				}
				ForEach(exercisesFiltered) { exercise in
					Button(action: {
						if let onSelect {
							onSelect(exercise)
						}
						dismiss()
					}) {
						VStack(alignment: .leading) {
							Text(exercise.name)
							Text(exercise.category.title)
								.font(.footnote)
						}
					}
					.swipeActions(edge: .trailing, allowsFullSwipe: true) {
						Button("Delete") {
							/// Need to prevent deleting if it's a permanent exercise
							modelContext.delete(exercise)
						}
						.tint(.red)
					}
					.swipeActions {
						Button("Edit") {
							exerciseToEdit = exercise
						}
						.tint(.yellow)
					}
				}
			}
		}
		.sheet(isPresented: $newExerciseSheetPresented) {
			ExerciseDetailsEditor()
		}
		.sheet(item: $exerciseToEdit) { exercise in
			ExerciseDetailsEditor(exercise: exercise)
		}
	}
}

#Preview {
	do {
		let (container, _) = try setupPreview()
		
		return ExerciseDetailsList()
			.modelContainer(container)
	} catch {
		return Text("Failed to build preview")
	}
}
