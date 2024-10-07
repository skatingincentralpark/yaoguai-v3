//
//  AlertList.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 7/10/2024.
//

import SwiftUI

struct AlertList: View {
	var alertManager = AlertManager.shared
	
	var body: some View {
		ForEach(alertManager.alerts) { alert in
			let index = alertManager.alerts.firstIndex(where: { $0.id == alert.id }) ?? 0
			HStack {
				Image(systemName: alert.type.icon) // Use icon from ToastType
					.foregroundColor(.white)
				
				Text(alert.message)
					.bold()
					.foregroundColor(.white)
			}
			.padding()
			.background(alert.type.backgroundColor) // Use background color from ToastType
			.clipShape(RoundedRectangle(cornerRadius: 8.0))
			.onTapGesture {
				withAnimation {
					alertManager.removeAlert(alert)
				}
			}
			.frame(height: 70)
			.offset(y: -CGFloat(index * 70))
			.transition(.asymmetric(insertion: .move(edge: .top), removal: .move(edge: .bottom)).combined(with: .opacity))
			.animation(.easeInOut, value: alertManager.alerts.count)
		}
	}
}

//#Preview {
//    AlertsList()
//}
