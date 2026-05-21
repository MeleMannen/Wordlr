//
//  StreakChartView.swift
//  Wordle
//
//  Created by Kristoffer Melen on 21/09/2025.
//

import SwiftUI
import Charts

struct StreakChartView: View {
	@State var title: String
	@Binding var longestStreakPerLetters: [(language: LanguageSelection, streaks: [(index: Int, currentStreak: Int, longestStreak: Int)])]
	@Binding var maxStreakLength: Double
	
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
					
					Chart {
						ForEach(longestStreakPerLetter.streaks, id: \.index) { streak in
							let currentDouble = Double(streak.currentStreak)
							let longestDouble = Double(streak.longestStreak)
							BarMark(
								x: .value("Current", (streak.currentStreak == 0) ? 0.005 * self.maxStreakLength : Double(streak.currentStreak)),
								y: .value("Number of guesses", " \(streak.index) "),
								height: .fixed(20.0)
							)
							.foregroundStyle(Color.green)
							.annotation(position: currentDouble < (self.maxStreakLength / 8.0) ? .trailing : .overlay) {
								Text("\(streak.currentStreak)")
									.foregroundColor(currentDouble < (self.maxStreakLength / 8.0) ? .primary : .white)
									.font(.headline)
									.padding(.leading, streak.currentStreak == 0 ? 3 : 0)
							}
							.position(by: .value("Current", "Current"))
							
							BarMark(
								x: .value("Longest", streak.longestStreak),
								y: .value("Number of guesses", " \(streak.index) "),
								height: .fixed(20.0)
							)
							.foregroundStyle(Color.orange)
							.annotation(position: longestDouble < (self.maxStreakLength / 8.0) ? .trailing : .overlay) {
								Text("\(streak.longestStreak)")
									.foregroundColor(longestDouble < (self.maxStreakLength / 8.0) ? .primary : .white)
									.font(.headline)
							}
							.position(by: .value("Longest", "Longest"))
						}
						
					}
					.chartXScale(domain: 0...self.maxStreakLength)
					.chartYAxis {
						AxisMarks(preset: .extended, position: .leading) { _ in
							AxisValueLabel(horizontalSpacing: 15)
								.font(.footnote)
						}
					}
					.animation(.easeInOut(duration: 0.5), value: longestStreakPerLetter.streaks.count)
					.frame(minHeight: CGFloat(longestStreakPerLetter.streaks.count * 100))
				}
			}
			
			HStack {
				Circle()
					.fill(Color.green)
					.frame(width: 5, height: 5)
				Text("Current")
					.foregroundStyle(.secondary)
					.font(.footnote)
					.padding(.trailing, 10)
				Circle()
					.fill(Color.orange)
					.frame(width: 5, height: 5)
				Text("Longest")
					.foregroundStyle(.secondary)
					.font(.footnote)
			}
			.padding(.top, 5)
			.padding(.leading, 3)
		}
    }
}

#Preview {
	StreakChartView(title: "Daily Wordlr streaks 🔥", longestStreakPerLetters:  .constant([(language: .english, streaks: [(5, 1, 1)]), (language: .spanish, streaks: []), (language: .norwegian, streaks: [])]), maxStreakLength: .constant(1.0))
}
