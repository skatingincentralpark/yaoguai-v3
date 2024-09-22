//
//  WorkoutTemplateList.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 15/9/2024.
//

import SwiftUI
import SwiftData

struct WorkoutTemplateList: View {
	@Environment(\.modelContext) private var modelContext
	@Query private var workoutTemplates: [WorkoutTemplate]
	@State var sheetPresented = false
	@State var newTemplate: WorkoutTemplate?
	
	@State private var paths: [WorkoutTemplate] = []
	
	var body: some View {
		NavigationStack(path: $paths) {
			VStack {
				Button("Add Template") {
					let template = WorkoutTemplate()
					modelContext.insert(template)
					newTemplate = template
					paths.append(template)
				}
				
				ScrollView {
					Text("\(workoutTemplates.count)")
					VStack(alignment: .center) {
						ForEach(workoutTemplates) { template in
							HStack(spacing: 20) {
								NavigationLink("Template: \(template.name.isEmpty ? "No Name" : template.name)") {
									WorkoutTemplateEditorWrapper(workoutId: template.id, in: modelContext.container, isNewWorkout: false)
								}
								Button("Delete") {
									modelContext.delete(template)
								}
								.tint(.red)
							}
						}
					}
				}
			}
			.navigationDestination(for: WorkoutTemplate.self) { template in
				WorkoutTemplateEditorWrapper(workoutId: template.id, in: modelContext.container, isNewWorkout: true)
			}
		}
	}
}

struct Test: View {
	var body: some View {
		Text("Hey")
	}
}

#Preview {
	do {
		let modelContainer: ModelContainer
		modelContainer = try ModelContainer(for: WorkoutTemplate.self, WorkoutRecord.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
		
		let pullups = Exercise(name: "Pullups", category: .weightAndReps)
		let pushups = Exercise(name: "Pushups", category: .weightAndReps)
		
		modelContainer.mainContext.insert(pullups)
		modelContainer.mainContext.insert(pushups)
		
		return WorkoutTemplateList()
			.modelContainer(modelContainer)
	} catch {
		return Text("Problem bulding ModelContainer.")
	}
}
