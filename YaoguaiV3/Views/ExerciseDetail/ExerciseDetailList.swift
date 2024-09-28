//
//  ExerciseDetailList.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 28/9/2024.
//

import SwiftUI
import SwiftData

struct ExerciseDetailList: View {
	@Environment(\.modelContext) private var modelContext
	@Query private var exercises: [Exercise]
	
	var body: some View {
		NavigationStack {
			List {
				ForEach(exercises) { exercise in
					NavigationLink {
						ExerciseDetailEditor(exercise: exercise)
					} label: {
						VStack(alignment: .leading) {
							Text(exercise.name)
							Text(exercise.category.title)
								.font(.footnote)
						}
					}
				}
			}
		}
	}
}

#Preview {
	do {
		let (container, _) = try setupPreview()
		
		return ExerciseDetailList()
			.modelContainer(container)
	} catch {
		return Text("Failed to build preview")
	}
}
