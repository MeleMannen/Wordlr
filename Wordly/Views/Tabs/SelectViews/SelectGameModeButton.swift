//
//  SelectGameModeButton.swift
//  Wordle
//
//  Created by Kristoffer Melen on 22/05/2026.
//

import SwiftUI

struct SelectGameModeButton: View {
	@Environment(\.colorScheme) private var colorScheme
	@AppStorage("userWantsNormalTheme") private var userWantsNormalTheme: Bool = true
	
	let title: LocalizedStringKey
	let mode: GameMode
	let appManager: AppManager
	let streak: Int?
	let isAvailable: Bool
	let impactTrigger: Bool
	let errorTrigger: Bool
	let startAction: () -> Void
	let blockedAction: () -> Void
	
	var body: some View {
		Group {
			if isAvailable {
				NavigationLink(destination: GameView().environment(appManager)) {
					label
				}
				.simultaneousGesture(TapGesture().onEnded {
					startAction()
				})
				.conditionalHaptic(.impact, trigger: impactTrigger)
				.selectGameModeButtonStyle(mode: mode, isAvailable: true)
			} else {
				Button(action: blockedAction) {
					label
				}
				.buttonStyle(.plain)
				.conditionalHaptic(.error, trigger: errorTrigger)
				.selectGameModeButtonStyle(mode: mode, isAvailable: false)
			}
		}
	}
	
	private var label: some View {
		titleText
			.contentTransition(.numericText(value: Double(streak ?? 0)))
			.multilineTextAlignment(.center)
			.lineSpacing(5)
			.font(.title2).bold()
			.padding()
			.frame(maxWidth: .infinity)
			.foregroundStyle(.white)
			.background {
				background
			}
	}
	
	private var titleText: Text {
		if let streak {
			return Text(title) + Text(" - \(streak)🔥")
		}
		
		return Text(title)
	}
	
	@ViewBuilder
	private var background: some View {
		switch mode {
			case .normal:
				normalBackground
			case .dailyWord:
				dailyWordBackground
			case .both:
				normalBackground
		}
	}
	
	@ViewBuilder
	private var normalBackground: some View {
		let useGreen = !userWantsNormalTheme && colorScheme == .dark
		if isAvailable {
			if #available(iOS 26.0, *) {
					RoundedRectangle(cornerRadius: 15)
						.foregroundStyle(Color(uiColor: useGreen ? .systemGreen : .systemOrange))
			} else {
				RoundedRectangle(cornerRadius: 15)
					.foregroundStyle(useGreen ? .green : .orange)
			}
		} else {
			RoundedRectangle(cornerRadius: 15)
				.foregroundStyle((useGreen ? Color.green : Color.orange).opacity(0.3))
		}
	}
	
	@ViewBuilder
	private var dailyWordBackground: some View {
		let opacity = isAvailable ? 1.0 : 0.3
		
		if !userWantsNormalTheme && colorScheme == .dark {
			RoundedRectangle(cornerRadius: 15)
				.foregroundStyle(appManager.gradient.opacity(opacity))
				.gradientShadow(gradient: appManager.shadowGradient, radius: 3, x: 0, y: 0)
		} else if isAvailable {
			if #available(iOS 26.0, *) {
					RoundedRectangle(cornerRadius: 15)
						.foregroundStyle(Color(uiColor: .systemGreen))
			} else {
				RoundedRectangle(cornerRadius: 15)
					.foregroundStyle(.green)
			}
		} else {
			RoundedRectangle(cornerRadius: 15)
				.foregroundStyle(Color.green.opacity(opacity))
		}
	}
}

private struct SelectGameModeButtonStyle: ViewModifier {
	@Environment(\.colorScheme) private var colorScheme
	@AppStorage("userWantsNormalTheme") private var userWantsNormalTheme: Bool = true
	
	let mode: GameMode
	let isAvailable: Bool
	
	func body(content: Content) -> some View {
		if #available(iOS 26.0, *) {
			if mode == .dailyWord && !userWantsNormalTheme && colorScheme == .dark && isAvailable {
				content
					.conditionalShadow(color: .black.opacity(0.4), radius: 4, x: 4, y: 4)
					.glassEffect(.regular.interactive(), in: .rect(cornerRadius: 15.0))
			} else if isAvailable {
				let useGreen = mode == .normal && !userWantsNormalTheme && colorScheme == .dark
				let tintColor: Color = mode == .normal ? (useGreen ? .green : .orange) : .green
				content
					.conditionalShadow(color: .black.opacity(0.4), radius: 4, x: 4, y: 4)
					.glassEffect(.regular.tint(tintColor).interactive(), in: .rect(cornerRadius: 15.0))
			} else {
				content
					.conditionalShadow(color: .black.opacity(0.4), radius: 4, x: 4, y: 4)
					.glassEffect(.regular.interactive(), in: .rect(cornerRadius: 15.0))
			}
		} else if isAvailable {
			content
				.buttonStyle(GrowingButton())
				.conditionalShadow(color: .black.opacity(0.4), radius: 4, x: 4, y: 4)
		} else {
			content
		}
	}
}

private extension View {
	func selectGameModeButtonStyle(mode: GameMode, isAvailable: Bool) -> some View {
		modifier(SelectGameModeButtonStyle(mode: mode, isAvailable: isAvailable))
	}
}
