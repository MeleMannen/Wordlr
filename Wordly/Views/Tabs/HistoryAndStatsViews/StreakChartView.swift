//
//  StreakChartView.swift
//  Wordle
//
//  Created by Kristoffer Melen on 21/09/2025.
//

import SwiftUI
import Charts

struct StreakChartView: View {
	@Environment(\.colorScheme) private var colorScheme
	@Environment(\.accessibilityReduceMotion) private var reduceMotion
	@AppStorage("userWantsNormalTheme") private var userWantsNormalTheme: Bool = true

	@State var title: String
	@Binding var longestStreakPerLetters: [(language: LanguageSelection, streaks: [(index: Int, currentStreak: Int, longestStreak: Int)])]
	@Binding var maxStreakLength: Double

	private let gradient = LinearGradient(colors: [.orange, .yellow, .yellow, .yellow, .yellow, .white], startPoint: .bottomLeading, endPoint: .topTrailing)

	private var useGradientTheme: Bool {
		!userWantsNormalTheme && colorScheme == .dark
	}

    var body: some View {
		VStack(alignment: .leading) {
			Text(self.title)
				.font(.title3).bold()
				.conditionalShadow(color: .black.opacity(0.05), radius: 2, x: 1, y: 1)
				.padding(.top, 3)
			ForEach(self.longestStreakPerLetters, id: \.language) { longestStreakPerLetter in
				if !longestStreakPerLetter.streaks.isEmpty {
					Text(longestStreakPerLetter.language.localizedName)
						.font(.headline)
						.padding(.top, 3)
						.padding(.leading, 3)

					streakChart(language: longestStreakPerLetter.language, streaks: longestStreakPerLetter.streaks)
				}
			}
			
			legend
		}
    }

	@ViewBuilder
	private func streakChart(language: LanguageSelection, streaks: [(index: Int, currentStreak: Int, longestStreak: Int)]) -> some View {
		Chart {
			ForEach(streaks, id: \.index) { streak in
				currentStreakBar(streak)
				longestStreakBar(streak)
			}
		}
		.chartXScale(domain: 0...self.maxStreakLength)
		.chartYAxis {
			AxisMarks(preset: .extended, position: .leading) { _ in
				AxisValueLabel(horizontalSpacing: 15)
					.font(.footnote)
			}
		}
		.chartXAxis {
			AxisMarks(preset: .extended, position: .bottom, values: .automatic(minimumStride: 1.0)) { _ in
				AxisGridLine()
				AxisTick()
				AxisValueLabel(centered: false, anchor: .topTrailing)
					.font(.footnote)
			}
		}
		.animation(reduceMotion ? nil : .easeInOut(duration: 1.0), value: streaks.count)
		.accessibilityLabel("\(self.title), \(language.localizedName)")
		.accessibilityValue(WordlrAccessibilityFormatter.streakChartSummary(title: self.title, language: language, streaks: streaks))
		.frame(minHeight: CGFloat(streaks.count * 100))
	}

	private func currentStreakBar(_ streak: (index: Int, currentStreak: Int, longestStreak: Int)) -> some ChartContent {
		let currentDouble = Double(streak.currentStreak)
		let currentValue = streak.currentStreak == 0 ? 0.005 * self.maxStreakLength : currentDouble
		return BarMark(
			x: .value("Current", currentValue),
			y: .value("Number of guesses", " \(streak.index) "),
			height: .fixed(20.0)
		)
		.foregroundStyle(useGradientTheme ? AnyShapeStyle(gradient) : AnyShapeStyle(Color.green))
		.annotation(position: currentDouble < (self.maxStreakLength / 8.0) ? .trailing : .overlay) {
			Text("\(streak.currentStreak)")
				.foregroundColor(currentDouble < (self.maxStreakLength / 8.0) ? .primary : .white)
				.font(.headline)
				.frame(minWidth: CGFloat(15*"\(streak.currentStreak)".count), alignment: .center)
				.shadow(color: .black.opacity(currentDouble < (self.maxStreakLength / 8.0) ? 0.0 : 0.3), radius: 1, x: 1, y: 1)
				.padding(.leading, streak.currentStreak == 0 ? 3 : 0)
		}
		.position(by: .value("Current", "Current"))
	}

	private func longestStreakBar(_ streak: (index: Int, currentStreak: Int, longestStreak: Int)) -> some ChartContent {
		let longestDouble = Double(streak.longestStreak)
		return BarMark(
			x: .value("Longest", streak.longestStreak),
			y: .value("Number of guesses", " \(streak.index) "),
			height: .fixed(20.0)
		)
		.foregroundStyle(useGradientTheme ? AnyShapeStyle(Color.green) : AnyShapeStyle(Color.orange))
		.annotation(position: longestDouble < (self.maxStreakLength / 8.0) ? .trailing : .overlay) {
			Text("\(streak.longestStreak)")
				.foregroundColor(longestDouble < (self.maxStreakLength / 8.0) ? .primary : .white)
				.font(.headline)
				.frame(minWidth: CGFloat(15*"\(streak.longestStreak)".count), alignment: .center)
				.shadow(color: .black.opacity(longestDouble < (self.maxStreakLength / 8.0) ? 0.0 : 0.3), radius: 1, x: 1, y: 1)
		}
		.position(by: .value("Longest", "Longest"))
	}

	private var legend: some View {
		HStack {
			Circle()
				.foregroundStyle(useGradientTheme ? AnyShapeStyle(gradient) : AnyShapeStyle(Color.green))
				.frame(width: 10, height: 10)
			Text("Current")
				.foregroundStyle(.secondary)
				.font(.footnote)
				.padding(.trailing, 10)
			Circle()
				.foregroundStyle(useGradientTheme ? AnyShapeStyle(Color.green) : AnyShapeStyle(Color.orange))
				.frame(width: 10, height: 10)
			Text("Longest")
				.foregroundStyle(.secondary)
				.font(.footnote)
		}
		.padding(.top, 5)
		.padding(.leading, 3)
	}
}

#Preview {
	StreakChartView(title: "Daily word streaks 🔥", longestStreakPerLetters:  .constant([(language: .english, streaks: [(5, 1, 1)]), (language: .spanish, streaks: []), (language: .norwegian, streaks: [])]), maxStreakLength: .constant(1.0))
}
