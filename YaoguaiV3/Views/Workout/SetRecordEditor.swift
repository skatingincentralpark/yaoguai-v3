//
//  SetRecordEditor.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 21/8/2024.
//

import SwiftUI

struct SetRecordEditor: View {
	@Binding var set: SetRecord
	let exercise: Exercise?
	let index: Int
	var previousSet: SetRecord?
	
	var delete: (SetRecord) -> Void
	
	@FocusState private var valueFocused: Bool
	@FocusState private var repsFocused: Bool
	@FocusState private var rpeFocused: Bool
	
	init(set: Binding<SetRecord>, exercise: Exercise?, index: Int, delete: @escaping (SetRecord) -> Void) {
		self._set = set
		self.exercise = exercise
		self.index = index
		self.delete = delete
		self.previousSet = exercise?.latestRecord?.sets[safe: index]
	}
	
	var body: some View {
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
			
//			Text("\(set.valueString) kg")
			TextField("Enter your score", value: $set.value, format: .number)
				.textFieldStyle(.roundedBorder)
				.padding()
			
			SimpleTextFieldV2(
				id: UUID().hashValue,
				input: Binding(
					get: {
						set.valueString
					},
					set: { newValue in
						print(newValue)
						set.value = Double(newValue)
					}
				),
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
				id: UUID().hashValue,
				input: Binding(
					get: {
						set.repsString
					},
					set: { newValue in
						set.reps = Int(newValue)
					}
				),
				keyboardHeight: 300)
			.focused($repsFocused)
			.frame(height: 30)
			.background(.yellow)
			.clipShape(RoundedRectangle(cornerRadius: 6))
			.overlay {
				RoundedRectangle(cornerRadius: 6)
					.stroke(repsFocused ? .green : .gray, lineWidth: 3.0)
			}
			
			//			SimpleTextFieldV2(
			//				id: UUID().hashValue,
			//				input: Binding(
			//					get: {
			//						set.rpeString
			//					},
			//					set: { newValue in
			//						set.rpe = Double(newValue)
			//					}
			//				),
			//				keyboardHeight: 300)
			//			.focused($rpeFocused)
			//			.frame(height: 30)
			//			.background(.yellow)
			//			.clipShape(RoundedRectangle(cornerRadius: 6))
			//			.overlay {
			//				RoundedRectangle(cornerRadius: 6)
			//					.stroke(rpeFocused ? .green : .gray, lineWidth: 3.0)
			//			}
			
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
