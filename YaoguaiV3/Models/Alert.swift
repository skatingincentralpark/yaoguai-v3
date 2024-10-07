//
//  Alert.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 7/10/2024.
//

import Foundation
import SwiftUI

enum AlertType {
	case success
	case warning
	case error
	case info
	
	var backgroundColor: Color {
		switch self {
		case .success: return Color.green.opacity(0.8)
		case .warning: return Color.yellow.opacity(0.8)
		case .error: return Color.red.opacity(0.8)
		case .info: return Color.blue.opacity(0.8)
		}
	}
	
	var icon: String {
		switch self {
		case .success: return "checkmark.circle"
		case .warning: return "exclamationmark.triangle"
		case .error: return "xmark.octagon"
		case .info: return "info.circle"
		}
	}
}

struct Alert: Identifiable {
	var id: UUID = UUID()
	var message: String
	var type: AlertType
}

@Observable
class AlertManager {
	static let shared = AlertManager()
	private(set) var alerts: [Alert] = []
	
	func addAlert(_ message: String, type: AlertType) {
		print("Adding Alert")
		alerts.append(Alert(message: message, type: type))
	}
	
	func removeAlert(_ alert: Alert) {
		print("Removing Alert")
		alerts.removeAll { $0.id == alert.id } // Remove alert using its ID
	}
	
	private init() {}
}


