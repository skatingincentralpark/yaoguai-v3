//
//  SetEditor.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 21/8/2024.
//

import SwiftUI

struct SetEditor<T: SetCommon>: View {
	@Binding var set: T
	let exercise: Exercise?
	let index: Int
	var previousSet: SetRecord?
	
	var delete: (T) -> Void
	
	@FocusState private var valueFocused: Bool
	@FocusState private var repsFocused: Bool
	@FocusState private var rpeFocused: Bool
	
	init(set: Binding<T>, exercise: Exercise?, index: Int, delete: @escaping (T) -> Void) {
		self._set = set
		self.exercise = exercise
		self.index = index
		self.delete = delete
		self.previousSet = exercise?.latestRecord?.sets[safe: index]
	}
	
	var body: some View {
		HStack {
			Text("value: \(set.valueString)")
			Text("reps: \(set.repsString)")
		}
		HStack {
			Button(action: {
				if let previousSet {
					set.reps = previousSet.reps
					set.value = previousSet.value
					set.rpe = previousSet.rpe
				}
			}, label: {
				if let previousSet {
					Text("\(previousSet.valueString) kg x \(previousSet.repsString)")
						.fixedSize()
				} else {
					Text("-")
						.fixedSize()
				}
			})
			
			SimpleTextFieldV2(
				value: Binding(
					get: {
						doubleFromMeasurement(self.set.value)
					}, set: { newValue in
						if let newValue {
							set.value = measurementFromDouble(newValue)
						}
					}
				),
				id: UUID().hashValue,
				keyboardHeight: 300)
			.focused($valueFocused)
			.frame(height: 30)
			.background(.yellow)
			.clipShape(RoundedRectangle(cornerRadius: 6))
			.overlay {
				RoundedRectangle(cornerRadius: 6)
					.stroke(valueFocused ? .green : .gray, lineWidth: 3.0)
			}
			
			SimpleTextFieldV2(	
				value: $set.reps,
				id: UUID().hashValue,
				keyboardHeight: 300)
			.focused($repsFocused)
			.frame(width: 70, height: 30)
			.background(.yellow)
			.clipShape(RoundedRectangle(cornerRadius: 6))
			.overlay {
				RoundedRectangle(cornerRadius: 6)
					.stroke(repsFocused ? .green : .gray, lineWidth: 3.0)
			}
			
			Button(role: .destructive) {
				delete(set)
			} label: {
				Image(systemName: "xmark")
			}
			.buttonStyle(.bordered)
			.tint(.red)
			
			// Check if `set` conforms to SetRecord
			if let toggleableSet = set as? SetRecord {
				CompleteToggleView(completeBinding: makeCompleteBinding(for: toggleableSet))
			}
		}
	}
	
	// Helper function to create the Binding
	private func makeCompleteBinding(for toggleableSet: SetRecord) -> Binding<Bool> {
		Binding(get: {
			toggleableSet.complete
		}, set: { newValue in
			// Here we manually update the set with the new value
			var mutableSet = toggleableSet
			mutableSet.complete = newValue
			set = mutableSet as! T // Cast back to T and assign to @Binding set
		})
	}
	
	// Convert Measurement<UnitMass> to Double for TextField
	private func doubleFromMeasurement(_ measurement: Measurement<UnitMass>?) -> Double {
		// If the measurement is nil, return 0.0 as the default
		guard let measurement = measurement else {
			return 0.0
		}
		// Convert the measurement to kilograms and return the double value
		return measurement.converted(to: .kilograms).value
	}
	
	// Convert Double back to Measurement<UnitMass>
	private func measurementFromDouble(_ double: Double) -> Measurement<UnitMass>? {
		// Assuming the input is in kilograms, create and return a Measurement<UnitMass>
		return Measurement(value: double, unit: .kilograms)
	}
}

struct CompleteToggleView: View {
	@Binding var completeBinding: Bool
	
	var body: some View {
		Toggle(isOn: $completeBinding) {
			Image(systemName: "checkmark")
		}
		.toggleStyle(.button)
		.buttonStyle(.bordered)
		.tint(completeBinding ? .green : .black)
	}
}

#Preview(traits: .sizeThatFitsLayout) {
	do {
		let (container, _) = try setupPreview()
		
		let workout = getWorkoutRecord(container.mainContext)
		
		container.mainContext.insert(workout)
		
		let exercise = workout.exercises[0]
		
		return SetEditor(set: .constant(exercise.sets[0]), exercise: exercise.details, index: 0, delete: {_ in })
			.modelContainer(container)
	}  catch {
		return Text("Failed to build preview")
	}
}

