//
//  MyTestUITextField.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 31/8/2024.
//

import SwiftUI

struct NumberTextField<V>: UIViewRepresentable where V: Numeric & LosslessStringConvertible {
	@Binding var value: V
	
	typealias UIViewType = UITextField
	
	func makeUIView(context: UIViewRepresentableContext<NumberTextField>) -> UITextField {
		let editField = UITextField()
		editField.delegate = context.coordinator
		return editField
	}
	
	func updateUIView(_ editField: UITextField, context: UIViewRepresentableContext<NumberTextField>) {
		editField.text = String(value)
	}
	
	func makeCoordinator() -> NumberTextField.Coordinator {
		Coordinator(value: $value)
	}
	
	class Coordinator: NSObject, UITextFieldDelegate {
		var value: Binding<V>
		
		init(value: Binding<V>) {
			self.value = value
		}
		
		func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
					   replacementString string: String) -> Bool {
			
			let text = textField.text as NSString?
			let newValue = text?.replacingCharacters(in: range, with: string)
			
			if let number = V(newValue ?? "0") {
				self.value.wrappedValue = number
				return true
			} else {
				if nil == newValue || newValue!.isEmpty {
					self.value.wrappedValue = 0
				}
				return false
			}
		}
		
		func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
			if reason == .committed {
				textField.resignFirstResponder()
			}
		}
	}
}

struct TestTextFieldWithNumbers: View {
	@State private var value = 0.0
	@FocusState private var focused: Bool
	
	
	var body: some View {
		VStack {
			
			Text("Current value: \(value)")
			Button("Make 999") {
				value = 999
			}
			Divider()
			NumberTextField(value: $value)
				.frame(height: 32)
				.keyboardType(UIKeyboardType.decimalPad)
				.focused($focused)
			
			Button("Submit") {
				focused = false
			}
		}
	}
}


#Preview {
	return ScrollView {
		TestTextFieldWithNumbers()
	}
}
