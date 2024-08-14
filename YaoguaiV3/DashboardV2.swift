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
	
	@Bindable var workoutManager: WorkoutManager
	@State var newWorkoutSheetShowing = false
	
	var body: some View {
		NavigationStack {
			ScrollView {
				if workoutManager.currentWorkout != nil {
					Button("Continue Workout"){
						newWorkoutSheetShowing.toggle()
					}
					.buttonStyle(.bordered)
				} else {
					Button("Add Dummy Exercise Details") {
						let pullups = Exercise(name: "Pullups")
						let pushups = Exercise(name: "Pushups")
						
						modelContext.insert(pullups)
						modelContext.insert(pushups)
					}
					
					Button("Start New Workout") {
						workoutManager.startNewWorkout()
						newWorkoutSheetShowing.toggle()
					}
					.buttonStyle(.bordered)
					
					WorkoutList(workoutManager: workoutManager)
				}
			}
			.padding()
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
			.sheet(isPresented: $newWorkoutSheetShowing) {
				if let workout = workoutManager.currentWorkout {
					WorkoutEditorWrapper(workoutId: workout.id, in: modelContext.container, workoutManager: workoutManager, isNewWorkout: true)
				} else {
					Text("Loading...")
				}
			}
		}
	}
	
	struct WorkoutList: View {
		@Query private var workoutRecords: [WorkoutRecord]
		// For existing workouts (presented in sheet)
		@State private var workoutBeingEdited: WorkoutRecord? = nil
		@Environment(\.modelContext) private var modelContext
		@Bindable var workoutManager: WorkoutManager
		
		var body: some View {
			VStack {
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
			.sheet(item: $workoutBeingEdited) { workout in
				WorkoutEditorWrapper(workoutId: workout.id, in: modelContext.container, workoutManager: workoutManager)
			}
		}
	}
}

struct WorkoutEditorWrapper: View {
	@Environment(\.dismiss) var dismiss
	
	@Bindable var workout: WorkoutRecord
	let workoutManager: WorkoutManager
	let modelContext: ModelContext
	let isNewWorkout: Bool
	
	init(workoutId: PersistentIdentifier,
		 in container: ModelContainer,
		 workoutManager: WorkoutManager,
		 isNewWorkout: Bool = false
	) {
		self.modelContext = ModelContext(container)
		self.isNewWorkout = isNewWorkout
		self.modelContext.autosaveEnabled = isNewWorkout ? true : false
		self.workout = modelContext.model(for: workoutId) as? WorkoutRecord ?? WorkoutRecord()
		self.workoutManager = workoutManager
		print("Initialising WorkoutEditorWrapper")
	}
	
	var body: some View {
		NavigationStack {
			WorkoutEditorV2(workout: workout, modelContext: modelContext)
				.toolbar {
					if isNewWorkout {
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
					} else {
						ToolbarItem(placement: .confirmationAction) {
							Button("Save") {
								if modelContext.hasChanges {
									try? modelContext.save()
								}
								dismiss()
							}
							.tint(.green)
						}
						
						ToolbarItem(placement: .destructiveAction) {
							Button("Delete") {
								modelContext.delete(workout)
								try? modelContext.save()
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
		}
	}
}

struct WorkoutEditorV2: View {
	@Bindable var workout: WorkoutRecord
	let modelContext: ModelContext
	
	init(workout: WorkoutRecord, modelContext: ModelContext) {
		self.workout = workout
		self.modelContext = modelContext
		print("Initialising WorkoutEditorV2")
	}
	
	var body: some View {
		NavigationStack {
			ScrollView {
				VStack(alignment: .leading) {
					TextField("Name", text: $workout.name)
					AddRandomExerciseButton(workout: workout, modelContext: modelContext)
					ExerciseList(workout: workout, modelContext: modelContext)
				}
				.padding()
				.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
			}
		}
	}
	
	struct ExerciseList: View {
		@Bindable var workout: WorkoutRecord
		let modelContext: ModelContext
		
		var body: some View {
			ForEach(workout.orderedExercises) { exercise in
				ExerciseRecordEditor(exercise: exercise, delete: {
					workout.exercises.removeFirst { $0 == exercise }
					modelContext.delete(exercise)
				})
				.padding(.bottom)
			}
		}
	}
	
	struct AddRandomExerciseButton: View {
		@Query private var exercises: [Exercise]
		@Bindable var workout: WorkoutRecord
		let modelContext: ModelContext
		
		func getExerciseDetail(for exerciseId: PersistentIdentifier) -> Exercise {
			return modelContext.model(for: exerciseId) as? Exercise ?? Exercise(name: "AUTO_GENERATED")
		}
		
		var body: some View {
			Button("Add Random Exercise") {
				if let exerciseDetails = exercises.first {
					let record = ExerciseRecord()
					record.details = getExerciseDetail(for: exerciseDetails.id)
					workout.exercises.append(record)
					print("workout.exercises.count: \(workout.exercises.count)")
				} else {
					print("🚨 No exercises found.  None added.")
				}
			}
			.padding(.bottom)
		}
	}
}

struct ExerciseRecordEditor: View {
	@Bindable var exercise: ExerciseRecord
//	@State var exercise: ExerciseRecord = ExerciseRecord()
	var delete: () -> Void
	
	init(exercise: ExerciseRecord, delete: @escaping () -> Void) {
		self.exercise = exercise
		self.delete = delete
		print("Initialising ExerciseRecordEditor")
	}
	
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

struct SetRecordEditor: View {
	@Binding var set: SetRecord
	
	var delete: (SetRecord) -> Void
	
	@FocusState private var valueFocused: Bool
	@FocusState private var repsFocused: Bool
	@FocusState private var rpeFocused: Bool
	
	var body: some View {
		HStack {
//			SimpleTextField(id: set.id.hashValue)
//				.frame(height: 30)
//				.background(.gray)
//				.clipShape(RoundedRectangle(cornerRadius: 6))
//			SimpleTextField(id: set.id.hashValue)
//				.frame(height: 30)
//				.background(.gray)
//				.clipShape(RoundedRectangle(cornerRadius: 6))
//			SimpleTextField(id: set.id.hashValue)
//				.frame(height: 30)
//				.background(.gray)
//				.clipShape(RoundedRectangle(cornerRadius: 6))
			
//			TextField("Value", value: $set.value, format: .number)
//				.keyboardType(.numberPad)
//				.focused($valueFocused)
//				.textFieldStyle(.specialFocus(focused: valueFocused))
			
//			TextField("Reps", value: $set.reps, format: .number)
//				.keyboardType(.numberPad)
//				.focused($repsFocused)
//				.textFieldStyle(.specialFocus(focused: repsFocused))
//			
//			
//			TextField("RPE", value: $set.rpe, format: .number)
//				.keyboardType(.numberPad)
//				.focused($rpeFocused)
//				.textFieldStyle(.specialFocus(focused: rpeFocused))
			
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
		
		let workoutManager = WorkoutManager(modelContext: modelContainer.mainContext)
		
		return DashboardV2(workoutManager: workoutManager)
			.modelContainer(modelContainer)
	} catch {
		return Text("Problem bulding ModelContainer.")
	}
}
