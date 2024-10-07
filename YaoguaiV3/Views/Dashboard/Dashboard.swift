//
//  Dashboard.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 10/7/2024.
//

import SwiftUI
import SwiftData

struct Dashboard: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(CurrentWorkoutManager.self) private var workoutManager
//	@Environment(AlertManager.self) private var alertManager
	let alertManager = AlertManager.shared
	
	@State var newWorkoutSheetShowing = false
	
	var body: some View {
		NavigationStack {
			List {
				Section("Alerts") {
					Button("Add Warning Alert") {
						withAnimation {
							alertManager.addAlert("Warning Alert!", type: .warning)
						}
					}
					
					Button("Add Success Alert") {
						withAnimation {
							alertManager.addAlert("Success Alert!", type: .success)
						}
					}
					
					Button("Add Error Alert") {
						withAnimation {
							alertManager.addAlert("Error Alert!", type: .error)
						}
					}
					
					Button("Add Info Alert") {
						withAnimation {
							alertManager.addAlert("Info Alert!", type: .info)
						}
					}
				}
				
				Section("Development Helpers") {
					Button("Add Dummy Exercise Details", action: addDummyExercises)
					Button("Delete Exercise Records", role: .destructive, action: {
						try? modelContext.delete(model: ExerciseRecord.self)
					})
					Button("Delete Exercise Details", role: .destructive) {
						try? modelContext.delete(model: Exercise.self)
					}
					Button("Delete Workout Templates", role: .destructive) {
						try? modelContext.delete(model: WorkoutTemplate.self)
					}
				}
				
				Section {
					if workoutManager.currentWorkout != nil {
						Button("Continue Workout"){
							newWorkoutSheetShowing.toggle()
						}
					} else {
						Button("Start New Workout") {
							workoutManager.startNewWorkout()
							newWorkoutSheetShowing.toggle()
						}
					}
					
					WorkoutRecordList()
				} header: {
					Text("Workouts")
				} footer: {
					Label("Swipe left to edit/delete", systemImage: "arrow.left.to.line.compact")
				}
				
				Section {
					WorkoutTemplateList()
				} header: {
					Text("Templates")
				} footer: {
					Label("Swipe left to edit/delete", systemImage: "arrow.left.to.line.compact")
				}
				
				
			}
			.sheet(isPresented: $newWorkoutSheetShowing) {
				if let workout = workoutManager.currentWorkout {
					WorkoutRecordEditorWrapper(workoutId: workout.id, in: modelContext.container, isNewWorkout: true)
				} else {
					Text("Loading...")
				}
			}
		}
	}
	
	func addDummyExercises() {
		let pullups = Exercise(name: "Pullups", category: .weightAndReps)
		let pushups = Exercise(name: "Pushups", category: .weightAndReps)
		
		modelContext.insert(pullups)
		modelContext.insert(pushups)
	}
}

#Preview {
	do {
		let (container, workoutManager) = try setupPreview()
		
		return Dashboard()
			.overlay(alignment: .bottom) {
				AlertList()
			}
			.modelContainer(container)
			.environment(workoutManager)
	} catch {
		return Text("Failed to build preview")
	}
}
