//
//  StreakManager.swift
//  Wordle
//
//  Created by Kristoffer Melen on 11/06/2025.
//

import Foundation
import SwiftData

final class StreakManager {
    let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func addStreak(id: String, streak: Streak) {
        let streak = StreakEntity(id: id, streak: streak)
        context.insert(streak)
        print("Streak added with ID: \(id), streak: \(streak.streak)")
    }
    
    func updateStreak(_ streak: StreakEntity, with newStreak: Streak) {
        streak.streak = newStreak
        streak.longestStreak = max(streak.longestStreak, newStreak.currentStreak)
        print("Streak updated with ID: \(streak.id), new streak: \(newStreak), longest streak: \(streak.longestStreak)")
        try? context.save()
    }
    
    func fetchStreaks() -> [StreakEntity] {
        do {
            let streaks = try context.fetch(FetchDescriptor<StreakEntity>())
            return streaks
        } catch let error {
            print("Error fetching streaks: \(error.localizedDescription)")
        }
        return []
        
    }
    
    func deleteStreak(_ streak: StreakEntity) {
        context.delete(streak)
        print("Streak deleted with ID: \(streak.id), streak: \(streak.streak)")
    }
}
