//
//  DashboardV2.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 10/7/2024.
//

import SwiftUI
import SwiftData

struct DashboardV2: View {
	@Environment(\.modelContext) private var modelContext
	
	@Query private var exercises: [Exercise]
	@Query private var exerciseRecords: [ExerciseRecord]
	@Query private var workoutRecords: [WorkoutRecord]
	
	// For new workouts (presented on main screen)
	@State private var currentWorkout: WorkoutRecord? = nil
	
	// For existing workouts (presented in sheet)
	@State private var workoutBeingEdited: WorkoutRecord? = nil
	
	var body: some View {
		NavigationStack {
			ScrollView {
				Button("Add Dummy Exercise Details") {
					let pullups = Exercise(name: "Pullups")
					let pushups = Exercise(name: "Pushups")
					
					modelContext.insert(pullups)
					modelContext.insert(pushups)
				}

				Button("Start New Workout", action: startNewWorkout)
				
				ForEach(workoutRecords) { workout in
					HStack {
						Text(workout.name)
						Button("Edit") {
							workoutBeingEdited = workout
						}
						Button("Delete") {
							modelContext.delete(workout)
						}
					}
				}
			}
			.safeAreaInset(edge: .bottom) {
				VStack {
					Text("exercises count: \(exercises.count)")
					Text("exerciseRecords count: \(exerciseRecords.count)")
					Text("workoutRecords count: \(workoutRecords.count)")
				}
				.frame(maxWidth: .infinity)
				.padding()
				.background(.bar)
			}
			.sheet(item: $workoutBeingEdited) { workout in
				WorkoutEditorV2(workoutId: workout.id, in: modelContext.container)
			}
			.sheet(item: $currentWorkout) { workout in
				WorkoutEditorV2(workoutId: workout.id, in: modelContext.container, autosave: true)
			}
		}
	}
	
	private func startNewWorkout() {
		let newWorkout = WorkoutRecord(name: "Blabla")
		modelContext.insert(newWorkout)
		// Forces code to run on next runloop, similar to process.nextTick
		Task { currentWorkout = newWorkout }
	}
}

struct WorkoutEditorV2: View {
	@Environment(\.dismiss) var dismiss
	@Bindable var workout: WorkoutRecord
	@Query private var exercises: [Exercise]
	
	var modelContext: ModelContext
	
	/// Since workoutId is of type PersistentIdentifier, the ID needs to belong to an object that's been inserted
	/// into the context already, otherwise bugs will appear.
	///
	/// IT'S DECIDED: WE WILL ALWAYS INSERT THE MODEL BEFORE EDITING.  This also allows us to keep
	/// track of the ID of the model so we can persist the current workout.
	///
	/// I just need to remove it if it's cancelled.
	init(workoutId: PersistentIdentifier, in container: ModelContainer, autosave: Bool = false) {
		modelContext = ModelContext(container)
		modelContext.autosaveEnabled = autosave
		workout = modelContext.model(for: workoutId) as? WorkoutRecord ?? WorkoutRecord()
	}
	
	func getExerciseDetail(for exerciseId: PersistentIdentifier) -> Exercise {
		return modelContext.model(for: exerciseId) as? Exercise ?? Exercise(name: "AUTO_GENERATED")
	}
	
	var title: String {
		if modelContext.autosaveEnabled { return "New" }
		return "Editing"
	}
	
	var body: some View {
		NavigationStack {
			ScrollView {
				VStack(alignment: .leading) {
					Button("Add Random Exercise") {
						if let exerciseDetails = exercises.randomElement() {
							let record = ExerciseRecord()
							record.details = getExerciseDetail(for: exerciseDetails.id)
							workout.exercises.append(record)
						}
					}
					.padding(.bottom)
					
					ForEach(workout.orderedExercises) { exercise in
						ExerciseRecordEditor(exercise: exercise, delete: {
							if let index = workout.exercises.firstIndex(where: { $0 == exercise }) {
								workout.exercises.remove(at: index)
							}
							modelContext.delete(exercise)
						})
						.padding(.bottom)
					}
				}
				.padding()
				.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
				.toolbar {
					ToolbarItem(placement: .principal) {
						Text(title)
							.bold()
					}
					
					if modelContext.autosaveEnabled {
						ToolbarItem(placement: .cancellationAction) {
							Button("Cancel") {
								/// Deleting from this peer context doesn't remove the relationships... via the deleteRule
								/// So need to do it explicity.  WTF.
								try? modelContext.transaction {
									workout.exercises.forEach { modelContext.delete($0) }
									modelContext.delete(workout)
									try? modelContext.save()
								}
								dismiss()
							}
						}
					} else {
						ToolbarItem(placement: .cancellationAction) {
							Button("Discard") {
								dismiss()
							}
						}
					}
					
					ToolbarItem(placement: .confirmationAction) {
						Button("Save") {
							print(workout)
							modelContext.insert(workout)
							try? modelContext.save()
							dismiss()
						}
					}
				}
			}
		}
	}
}

struct ExerciseRecordEditor: View {
	@Bindable var exercise: ExerciseRecord
	var delete: () -> Void
	
	var body: some View {
		VStack(alignment: .leading) {
			HStack {
				Text(exercise.id.hashValue.formatted().prefix(7))
					.lineLimit(1)
					.padding(.horizontal)
					.background(.bar)
				Text(exercise.details?.name ?? "")
				Button("Delete", action: delete)
			}
			
			Button("Add Set") {
				exercise.sets.append(SetRecord())
			}
			
			if exercise.sets.count > 0 {
				HStack {
					VStack {
						ForEach($exercise.sets) { set in
							SetRecordEditor(set: set, delete: { _ in
								if let index = exercise.sets.firstIndex(where: { $0 == set.wrappedValue }) {
									exercise.sets.remove(at: index)
								}
							})
							.padding(.leading)
						}
						
											
					}
					.overlay(alignment: .leading) {
						Rectangle()
							.frame(width: 1)
					}
				}
				.padding(.leading)
			}
		}
	}
}

//struct SetRecordEditor: View {
//	@Binding var set: SetRecord
//	var delete: () -> Void
//	
//	var body: some View {
//		HStack {
//			Text("Set")
//			Button("Delete", action: delete)
//		}
//	}
//}

struct SetRecordEditor: View {
	@Binding var set: SetRecord
	
	var delete: (SetRecord) -> Void
	
	@FocusState private var valueFocused: Bool
	@FocusState private var repsFocused: Bool
	@FocusState private var rpeFocused: Bool
	
	var body: some View {
		HStack {
			TextField("Value", value: $set.value, format: .number)
				.keyboardType(.numberPad)
				.focused($valueFocused)
				.textFieldStyle(.specialFocus(focused: valueFocused))
			
			
			TextField("Reps", value: $set.reps, format: .number)
				.keyboardType(.numberPad)
				.focused($repsFocused)
				.textFieldStyle(.specialFocus(focused: repsFocused))
			
			
			TextField("RPE", value: $set.rpe, format: .number)
				.keyboardType(.numberPad)
				.focused($rpeFocused)
				.textFieldStyle(.specialFocus(focused: rpeFocused))
			
			Button(role: .destructive) {
				delete(set)
			} label: {
				Image(systemName: "xmark")
			}
			.buttonStyle(.bordered)
			.tint(.red)
			
			Toggle(isOn: $set.complete) {
				Image(systemName: "checkmark")
			}
			.toggleStyle(.button)
			.buttonStyle(.bordered)
			.tint(set.complete ? .green : .black)
			
		}
	}
}

#Preview {
	do {
		let modelContainer: ModelContainer
		modelContainer = try ModelContainer(for: WorkoutRecord.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
		
		let pullups = Exercise(name: "Pullups")
		let pushups = Exercise(name: "Pushups")
		
		modelContainer.mainContext.insert(pullups)
		modelContainer.mainContext.insert(pushups)
		
		@MainActor
		func addWorkoutRecord() {
			let record1 = WorkoutRecord(name: "Upper")
			let exercise1 = ExerciseRecord()
			let exercise2 = ExerciseRecord()
			modelContainer.mainContext.insert(exercise1)
			modelContainer.mainContext.insert(exercise2)
			exercise1.details = pullups
			exercise2.details = pushups
			record1.exercises = [exercise1, exercise2]
			modelContainer.mainContext.insert(record1)
		}
		
		addWorkoutRecord()
		
		return DashboardV2()
			.modelContainer(modelContainer)
	} catch {
		return Text("Problem bulding ModelContainer.")
	}
}
