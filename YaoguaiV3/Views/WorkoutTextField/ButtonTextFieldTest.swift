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

		let textField = PaddedTextField()
		
//		textField.layer.borderWidth = 1.0
//		textField.layer.borderColor = UIColor.gray.cgColor
		textField.layer.cornerRadius = 8.0
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.tag = id
		
		let button = UIButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
//		button.backgroundColor = .lightGray
		button.layer.opacity = 0.2
		button.addTarget(context.coordinator, action: #selector(Coordinator.buttonTapped), for: .touchUpInside)
		button.tag = id
		
		containerView.addSubview(textField)
		containerView.addSubview(button)
		
		DispatchQueue.main.async {
			print("TextField height after layout: \(textField.frame.height)")
		}
		
		NSLayoutConstraint.activate([
			// Text field constraints
			textField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
			textField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
			textField.topAnchor.constraint(equalTo: containerView.topAnchor),
			textField.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
			
			// Button constraints
			button.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
			button.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
			button.topAnchor.constraint(equalTo: textField.topAnchor),
			button.bottomAnchor.constraint(equalTo: textField.bottomAnchor),
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
	ScrollView {
		VStack(spacing: 10) {
			ForEach(0...10, id: \.self) { i in
				HStack(spacing: 10) {
					SimpleTextField(id: i + 1)
						.frame(height: 30)
						.background(.gray)
						.clipShape(RoundedRectangle(cornerRadius: 6))
					SimpleTextField(id: i + 2)
						.frame(height: 30)
						.background(.gray)
						.clipShape(RoundedRectangle(cornerRadius: 6))
					SimpleTextField(id: i + 3)
						.frame(height: 30)
						.background(.gray)
						.clipShape(RoundedRectangle(cornerRadius: 6))
				}
			}
		}
	}
	.padding()
}
