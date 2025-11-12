//
//  VehicleModels.swift
//  carpark
//

import Foundation
import SwiftUI

enum TransportCategory: String, Codable, CaseIterable {
    case sedan = "Sedan"
    case suv = "SUV"
    case truck = "Truck"
    case van = "Van"
    case bus = "Bus"
    
    var symbolName: String {
        let mapping: [TransportCategory: String] = [
            .sedan: "car.fill",
            .suv: "car.2.fill",
            .truck: "truck.box.fill",
            .van: "box.truck.fill",
            .bus: "bus.fill"
        ]
        return mapping[self] ?? "car.fill"
    }
}

enum EnergySource: String, Codable, CaseIterable {
    case gasoline = "Gasoline"
    case diesel = "Diesel"
    case gas = "Gas"
    case electric = "Electric"
    case hybrid = "Hybrid"
    
    var symbolName: String {
        switch self {
        case .gasoline, .diesel:
            return "fuelpump.fill"
        case .gas:
            return "flame.fill"
        case .electric:
            return "bolt.fill"
        case .hybrid:
            return "leaf.fill"
        }
    }
    
    var defaultUnitCost: Double {
        let costMapping: [EnergySource: Double] = [
            .gasoline: 50.0,
            .diesel: 55.0,
            .gas: 30.0,
            .electric: 10.0,
            .hybrid: 45.0
        ]
        return costMapping[self] ?? 50.0
    }
}

struct TransportUnit: Identifiable, Codable {
    var id = UUID()
    var unitName: String
    var modelName: String
    var category: TransportCategory
    var energyType: EnergySource
    var operatorName: String
    var imageBytes: Data?
    var operatorImageBytes: Data?
    var tripLogs: [TripRecord] = []
    var registrationDate: Date = Date()
    
    var totalDistanceCovered: Double {
        tripLogs.reduce(0) { accumulator, log in
            accumulator + log.distanceTraveled
        }
    }
    
    var totalEnergyUsed: Double {
        tripLogs.reduce(0) { accumulator, log in
            accumulator + log.energyConsumed
        }
    }
    
    var totalExpenditure: Double {
        tripLogs.reduce(0) { accumulator, log in
            accumulator + log.moneySpent
        }
    }
    
    var efficiencyRate: Double {
        guard totalDistanceCovered > 0 else { return 0 }
        return (totalEnergyUsed / totalDistanceCovered) * 100
    }
    
    var costPerformance: Double {
        guard totalExpenditure > 0 else { return 0 }
        return totalDistanceCovered / totalExpenditure
    }
}

struct TripRecord: Identifiable, Codable {
    var id = UUID()
    var recordDate: Date
    var distanceTraveled: Double
    var energyConsumed: Double
    var moneySpent: Double
    var additionalInfo: String
}

struct ApplicationPreferences: Codable {
    var initialTab: NavigationTab = .statistics
    var monetarySymbol: String = "$"
    var distanceMeasure: String = "km"
    var energyMeasure: String = "L"
}

enum NavigationTab: String, Codable {
    case statistics = "Analytics"
    case logbook = "Journal"
    case computations = "Calculator"
    case leaderboard = "Hall of Fame"
}
