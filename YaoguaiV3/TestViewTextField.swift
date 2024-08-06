//
//  TestViewTextField.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 31/7/2024.
//

import SwiftUI

struct TestViewTextField: View {
	
	@State private var text = ""
	@FocusState private var focused
	
	var body: some View {
		VStack {
			Text(text)
			UITextFieldViewRepresentable(text: $text) // Using it
				.frame(height: 44)
				.border(focused ? .red : .black)
				.background(focused ? .pink : .clear)
				.focused($focused)
				.keyboardType(.numberPad)
		}
	}
}

#Preview {
    TestViewTextField()
}

// MARK: UITextFieldViewRepresentable
struct UITextFieldViewRepresentable: UIViewRepresentable {
	
	@Binding var text: String
	typealias UIViewType = UITextField
	
	
	func makeUIView(context: Context) -> UITextField {
		let textField = UITextField()
		textField.delegate = context.coordinator
		return textField
	}
	
	// From SwiftUI to UIKit
	func updateUIView(_ uiView: UITextField, context: Context) {
		uiView.text = text
	}
	
	// From UIKit to SwiftUI
	func makeCoordinator() -> Coordinator {
		return Coordinator(text: $text)
	}
	
	class Coordinator: NSObject, UITextFieldDelegate {
		@Binding var text: String
		
		init(text: Binding<String>) {
			self._text = text
		}
		
		func textFieldDidChangeSelection(_ textField: UITextField) {
			text = textField.text ?? ""
		}
	}
}

//// Custom TextField with disabling paste action
//class UITextField: UITextField {
//	override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
//		
//		if action == #selector(paste(_:)) {
//			return false
//		}
//		
//		return super.canPerformAction(action, withSender: sender)
//	}
//}
