////
////  Dashboard.swift
////  YaoguaiV3
////
////  Created by Charles Zhao on 7/7/2024.
////
//
//import SwiftUI
//import SwiftData
//
//struct Dashboard: View {
//	@Environment(\.modelContext) private var modelContext
//	
//	@Query private var exercises: [Exercise]
//	@Query private var exerciseRecords: [ExerciseRecord]
//	@Query private var workoutRecords: [WorkoutRecord]
//	
//	// For new workouts (presented on main screen)
//	@State private var currentWorkout: WorkoutRecord? = nil
//	
//	// For existing workouts (presented in sheet)
//	@State private var workoutBeingEdited: WorkoutRecord? = nil
//	
//	var body: some View {
//		NavigationStack {
//			ScrollView {
//				if let workout = currentWorkout {
//					WorkoutEditor(workout: workout, onComplete: {
//						currentWorkout = nil
//					})
//				} else {
//					Button("Start Workout") {
//						currentWorkout = WorkoutRecord()
//					}
//					
//					ForEach(workoutRecords) { workout in
//						HStack {
//							Text(workout.name)
//							Button("Edit") {
//								workoutBeingEdited = workout
//							}
//						}
//					}
//				}
//			}
//			.safeAreaInset(edge: .bottom) {
//				VStack {
//					Text("exercises count: \(exercises.count)")
//					Text("exerciseRecords count: \(exerciseRecords.count)")
//					Text("workoutRecords count: \(workoutRecords.count)")
//				}
//				.background(.bar)
//			}
//			.sheet(item: $workoutBeingEdited) { workout in
//				WorkoutEditor(workout: workout, onComplete: {})
//			}
//		}
//	}
//}
//
//// This should allow editing an existing or a new workout
//struct WorkoutEditor: View {
//	let workoutOG: WorkoutRecord
//	var onComplete: () -> Void
//	@Query private var exercises: [Exercise]
//	@Environment(\.modelContext) private var modelContext
//	
//	@State private var exerciseRecords = [ExerciseRecord]()
//	
//	init(workout: WorkoutRecord, onComplete: @escaping () -> Void) {
//		self.workoutOG = workout
//		self._exerciseRecords = State(initialValue: workout.exercises.map{ $0.copy() })
//		self.onComplete = onComplete
//	}
//	
//	var body: some View {
//		VStack(alignment: .leading) {
//			Button("Add Exercise", action: addExercise)
//			ForEach(exerciseRecords) { exercise in
//				ExerciseRecordEditor(exercise: exercise) {
//					if let index = exerciseRecords.firstIndex(where: { $0 == exercise }) {
//						exerciseRecords.remove(at: index)
//					}
//					modelContext.delete(exercise)
//				}
//				.padding(.bottom)
//			}
//			
//			Button("Complete Workout") {
//				// Update the actual workout record with temporary changes
//				// This assumes you have logic to update the original workout in modelContext
//				onComplete()
//			}
//			
//			Button("Cancel Workout") {
//				onComplete()
//				
//				// Clean up the temporary edit workout
////				modelContext.delete(workout)
//				try? modelContext.transaction {
//					exerciseRecords.forEach{ modelContext.delete($0) }
//				}
//			}
//	}
//		.frame(maxWidth: .infinity)
//		.padding()
//		.onDisappear {
//			try? modelContext.transaction {
//				exerciseRecords.forEach{ modelContext.delete($0) }
//			}
//		}
//	}
//	
//	func addExercise() {
//		let exerciseRecord = ExerciseRecord()
//		exerciseRecord.details = exercises.randomElement()
//		exerciseRecords.append(exerciseRecord)
//	}
//}
//
//extension WorkoutRecord {
//	func copy() -> WorkoutRecord {
//		let copy = WorkoutRecord(name: self.name)
//		copy.isCurrentWorkout = self.isCurrentWorkout
//		copy.exercises = self.exercises.map{ exercise in
//			return exercise.copy()
//		}
//		return copy
//	}
//}
//
//extension ExerciseRecord {
//	func copy() -> ExerciseRecord {
//		let copy = ExerciseRecord()
//		copy.sets = self.sets
//		copy.details = self.details
//		return copy
//	}
//	
////	convenience init(from exerciseRecord: ExerciseRecord) {
////		self.init()
////		self.details = exerciseRecord.details
////		self.sets = exerciseRecord.sets
////	}
//}
//
//struct ExerciseRecordEditor: View {
//	@Bindable var exercise: ExerciseRecord
//	var delete: () -> Void
//	
//	var body: some View {
//		VStack(alignment: .leading) {
//			HStack {
//				Text(exercise.details?.name ?? "")
//				Button("Delete", action: delete)
//			}
//			
//			Button("Add Set") {
//				exercise.sets.append(SetRecord())
//			}
//			
//			if exercise.sets.count > 0 {
//				HStack {
//					VStack {
//						ForEach($exercise.sets) { set in
//							SetRecordEditor(set: set, delete: {
//								if let index = exercise.sets.firstIndex(where: { $0 == set.wrappedValue }) {
//									exercise.sets.remove(at: index)
//								}
//							})
//							.padding(.leading)
//						}
//					}
//					.overlay(alignment: .leading) {
//						Rectangle()
//							.frame(width: 1)
//					}
//				}
//				.padding(.leading)
//			}
//		}
//	}
//}
//
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
//
//#Preview {
//	do {
//		let modelContainer: ModelContainer
//		modelContainer = try ModelContainer(for: WorkoutRecord.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
//		
//		let pullups = Exercise(name: "Pullups")
//		let pushups = Exercise(name: "Pushups")
//		
//		modelContainer.mainContext.insert(pullups)
//		modelContainer.mainContext.insert(pushups)
//		
//		@MainActor
//		func addWorkoutRecord() {
//			let record1 = WorkoutRecord(name: "Upper")
//			let exercise1 = ExerciseRecord()
//			let exercise2 = ExerciseRecord()
//			modelContainer.mainContext.insert(exercise1)
//			modelContainer.mainContext.insert(exercise2)
//			exercise1.details = pullups
//			exercise2.details = pushups
//			record1.exercises = [exercise1, exercise2]
//			modelContainer.mainContext.insert(record1)
//		}
//		
//		addWorkoutRecord()
//		
//		return Dashboard()
//			.modelContainer(modelContainer)
//	} catch {
//		return Text("Problem bulding ModelContainer.")
//	}
//}
