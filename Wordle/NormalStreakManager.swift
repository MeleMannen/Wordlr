//
//  NormalStreakManager.swift
//  Wordle
//
//  Created by Kristoffer Melen on 01/07/2025.
//

import Foundation
import SwiftData

final class NormalStreakManager {
    let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func addStreak(id: String, streak: NormalStreak) {
        let streak = NormalStreakEntity(id: id, streak: streak)
        context.insert(streak)
        print("Normal Streak added with ID: \(id), streak: \(streak.streak)")
        try? context.save()
    }
    
    func updateStreak(_ streak: NormalStreakEntity, with newStreak: NormalStreak) {
        streak.streak = newStreak
        streak.longestStreak = max(streak.longestStreak, newStreak.currentStreak)
        print("Normal Streak updated with ID: \(streak.id), new streak: \(newStreak), longest streak: \(streak.longestStreak)")
        try? context.save()
    }
    
    func fetchStreaks() -> [NormalStreakEntity] {
        do {
            let streaks = try context.fetch(FetchDescriptor<NormalStreakEntity>())
            return streaks
        } catch let error {
            print("Error fetching normal streaks: \(error.localizedDescription)")
        }
        return []
    }
    
    func deleteStreak(_ streak: NormalStreakEntity) {
        context.delete(streak)
        print("Normal Streak deleted with ID: \(streak.id), streak: \(streak.streak)")
        try? context.save()
    }
}
