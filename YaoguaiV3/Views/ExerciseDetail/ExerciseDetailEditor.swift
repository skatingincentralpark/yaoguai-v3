//
//  ExerciseDetailEditor.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 28/9/2024.
//

import SwiftUI
import SwiftData

struct ExerciseDetailEditor: View {
	@Bindable var exercise: Exercise
	
	var body: some View {
		ScrollView {
			VStack(alignment: .leading) {
				Text(exercise.name)
					.font(.title)
				Text(exercise.category.title)
					.font(.title3)
				
				LabeledContent {
					TextField("Name", text: $exercise.name)
						.textFieldStyle(.roundedBorder)
				} label: {
					Text("Name:")
				}
				
				ExerciseCategoryPicker(selectedCategory: $exercise.category)
			}
			.padding()
		}
	}
	
	struct ExerciseCategoryPicker: View {
		// The binding allows the view to modify an external state variable
		@Binding var selectedCategory: ExerciseCategory
		
		var body: some View {
			Picker("Exercise Category", selection: $selectedCategory) {
				// Loop through all cases of ExerciseCategory and display their titles
				ForEach(ExerciseCategory.allCases, id: \.self) { category in
					Text(category.title).tag(category)
				}
			}
			.background(.quinary)
			.clipShape(RoundedRectangle(cornerRadius: 8))
		}
	}
	
}

#Preview {
	let exercise = Exercise(name: "Farmer Carries", category: .durationAndWeight)
	
	return ExerciseDetailEditor(exercise: exercise)
}
