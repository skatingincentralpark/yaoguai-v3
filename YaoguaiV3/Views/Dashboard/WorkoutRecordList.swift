//
//  WorkoutRecordList.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 4/10/2024.
//

import SwiftUI
import SwiftData

struct WorkoutRecordList: View {
	@Query private var workoutRecords: [WorkoutRecord]
	@State private var workoutBeingEdited: WorkoutRecord? = nil
	@Environment(\.modelContext) private var modelContext
	@Environment(CurrentWorkoutManager.self) private var workoutManager
	var workoutRecordsFiltered: [WorkoutRecord] {
		workoutRecords.filter { $0.id != workoutManager.currentWorkoutId }
	}
	
	var body: some View {
		ForEach(workoutRecordsFiltered) { workout in
			Button(workout.name) {
				workoutBeingEdited = workout
			}
			.swipeActions(edge: .trailing, allowsFullSwipe: true) {
				Button("Delete") {
					modelContext.delete(workout)
				}
				.tint(.red)
			}
		}
		.sheet(item: $workoutBeingEdited) { workout in
			WorkoutRecordEditorWrapper(workoutId: workout.id, in: modelContext.container)
		}
	}
}

#Preview {
    WorkoutRecordList()
}
