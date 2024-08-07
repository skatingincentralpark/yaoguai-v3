//
//  ButtonTextFieldTest.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 7/8/2024.
//

import SwiftUI
import UIKit

class PaddedTextField: UITextField {
	var textPadding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
	
	override func textRect(forBounds bounds: CGRect) -> CGRect {
		return bounds.inset(by: textPadding)
	}
	
	override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
		return bounds.inset(by: textPadding)
	}
	
	override func editingRect(forBounds bounds: CGRect) -> CGRect {
		return bounds.inset(by: textPadding)
	}
}

struct SimpleTextField: UIViewRepresentable {
	var id: Int
	
	func makeUIView(context: Context) -> UIView {
		let containerView = UIView()
		containerView.translatesAutoresizingMaskIntoConstraints = false

		let textField = PaddedTextField()
		
		textField.layer.borderWidth = 1.0
		textField.layer.borderColor = UIColor.gray.cgColor
		textField.layer.cornerRadius = 8.0
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.tag = id
		
		let button = UIButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.addTarget(context.coordinator, action: #selector(Coordinator.buttonTapped), for: .touchUpInside)
		button.tag = id
		
		containerView.addSubview(textField)
		containerView.addSubview(button)
		
		NSLayoutConstraint.activate([
			
			// Text field constraints
			textField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
			textField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
			textField.topAnchor.constraint(equalTo: containerView.topAnchor),
			
			// Button constraints
			button.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
			button.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
			button.topAnchor.constraint(equalTo: textField.topAnchor),
			button.bottomAnchor.constraint(equalTo: textField.bottomAnchor),
			
			// Ensure the container view's height is determined by the text field's height
			containerView.topAnchor.constraint(equalTo: textField.topAnchor),
			containerView.bottomAnchor.constraint(equalTo: textField.bottomAnchor)
		])
		
		return containerView
	}
	
	func updateUIView(_ uiView: UIView, context: Context) {
		// No update needed
	}
	
	func makeCoordinator() -> Coordinator {
		Coordinator()
	}
	
	class Coordinator: NSObject {
		@objc func buttonTapped(_ sender: UIButton) {
			guard let containerView = sender.superview,
				  let textField = containerView.subviews.first(where: { $0 is UITextField && $0.tag == sender.tag }) as? UITextField else {
					  return
				  }
			
			// Focuses and selects all
			textField.becomeFirstResponder()
			textField.selectAll(nil)
		}
	}
}

#Preview {
	VStack {
		VStack {
			ForEach(0...10, id: \.self) { i in
				HStack {
					SimpleTextField(id: 1)
						.border(.green)
					SimpleTextField(id: 2)
						.border(.green)
					SimpleTextField(id: 3)
						.border(.green)
					TextField("", text: .constant(""))
						.textFieldStyle(.roundedBorder)
				}
			}
		}
	}
	.padding()
}
