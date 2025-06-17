//
//  GameRecordManager.swift
//  Wordle
//
//  Created by Kristoffer Melen on 13/06/2025.
//

import Foundation
import SwiftData

final class GameRecordManager {
    let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func addGameRecord(gameRecord: GameRecord) {
        let gameRecordEntity = GameRecordEntity(gameRecord: gameRecord)
        context.insert(gameRecordEntity)
        print("GameRecord added: id: \(gameRecordEntity.id), gameRecord: \(gameRecordEntity.gameRecord)")
    }
    
    func updateGameRecord(_ gameRecordEntity: GameRecordEntity, with newGameRecord: GameRecord) {
        gameRecordEntity.gameRecord = newGameRecord
        print("GameRecordEntity updated: \(gameRecordEntity.gameRecord)")
        try? context.save()
    }
    
    func fetchGameRecords() -> [GameRecordEntity] {
        do {
            let gameRecords = try context.fetch(FetchDescriptor<GameRecordEntity>())
            return gameRecords
        } catch let error {
            print("Error fetching streaks: \(error.localizedDescription)")
        }
        return []
        
    }
    
    func deleteGameRecords(_ gameRecordEntity: GameRecordEntity) {
        context.delete(gameRecordEntity)
        print("GameRecordEntity deleted: \(gameRecordEntity.gameRecord)")
    }
}
