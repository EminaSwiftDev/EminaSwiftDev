import Foundation
import SwiftData

@Model
final class ZenFlowSession {
    var id: String = UUID().uuidString
    var protocolName: String = ""
    var startTime: Date = Date()
    var endTime: Date?
    var eatingWindowEndTime: Date?
    var completed: Bool = false
    var fastingHours: Double = 0
    var eatingHours: Double = 0
    var forceEnded: Bool = false
    var notes: String = ""
    var mood: Int = 0
    var weight: Double?
    var photos: [Data] = []
    
    init(protocolName: String, startTime: Date = Date(), fastingHours: Double, eatingHours: Double) {
        self.protocolName = protocolName
        self.startTime = startTime
        self.fastingHours = fastingHours
        self.eatingHours = eatingHours
        self.completed = false
        self.forceEnded = false
    }
    
    var duration: TimeInterval? {
        guard let endTime = endTime else { return nil }
        return endTime.timeIntervalSince(startTime)
    }
    
    func complete() {
        self.endTime = Date()
        self.completed = true
    }
} 