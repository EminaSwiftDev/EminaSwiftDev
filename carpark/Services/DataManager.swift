//
//  DataManager.swift
//  carpark
//

import Foundation
import SwiftUI
import Combine

class StorageController: ObservableObject {
    static let instance = StorageController()
    
    @Published var transportUnits: [TransportUnit] = []
    @Published var preferences: ApplicationPreferences = ApplicationPreferences()
    
    private let unitsStorageKey = "vehicles_data"
    private let preferencesStorageKey = "app_settings"
    
    init() {
        restoreFromDisk()
    }
    
    func persistToDisk() {
        if let encodedUnits = try? JSONEncoder().encode(transportUnits) {
            UserDefaults.standard.set(encodedUnits, forKey: unitsStorageKey)
        }
        if let encodedPrefs = try? JSONEncoder().encode(preferences) {
            UserDefaults.standard.set(encodedPrefs, forKey: preferencesStorageKey)
        }
    }
    
    func restoreFromDisk() {
        if let storedData = UserDefaults.standard.data(forKey: unitsStorageKey),
           let decodedUnits = try? JSONDecoder().decode([TransportUnit].self, from: storedData) {
            transportUnits = decodedUnits
        }
        
        if let storedPrefs = UserDefaults.standard.data(forKey: preferencesStorageKey),
           let decodedPrefs = try? JSONDecoder().decode(ApplicationPreferences.self, from: storedPrefs) {
            preferences = decodedPrefs
        }
    }
    
    func eraseAllRecords() {
        transportUnits.removeAll()
        persistToDisk()
    }
    
    func registerNewUnit(_ unit: TransportUnit) {
        transportUnits.append(unit)
        persistToDisk()
    }
    
    func modifyUnit(_ unit: TransportUnit) {
        if let idx = transportUnits.firstIndex(where: { $0.id == unit.id }) {
            transportUnits[idx] = unit
            persistToDisk()
        }
    }
    
    func removeUnit(_ unit: TransportUnit) {
        transportUnits.removeAll { $0.id == unit.id }
        persistToDisk()
    }
    
    func appendTripLog(unitIdentifier: UUID, log: TripRecord) {
        if let idx = transportUnits.firstIndex(where: { $0.id == unitIdentifier }) {
            transportUnits[idx].tripLogs.append(log)
            persistToDisk()
        }
    }
    
    var aggregatedDistance: Double {
        transportUnits.reduce(0) { $0 + $1.totalDistanceCovered }
    }
    
    var aggregatedExpenditure: Double {
        transportUnits.reduce(0) { $0 + $1.totalExpenditure }
    }
    
    var aggregatedEnergyUsage: Double {
        transportUnits.reduce(0) { $0 + $1.totalEnergyUsed }
    }
    
    func groupedByCategory() -> [TransportCategory: [TransportUnit]] {
        Dictionary(grouping: transportUnits, by: { $0.category })
    }
    
    func groupedByOperator() -> [String: [TransportUnit]] {
        Dictionary(grouping: transportUnits, by: { $0.operatorName })
    }
    
    func groupedByEnergyType() -> [EnergySource: [TransportUnit]] {
        Dictionary(grouping: transportUnits, by: { $0.energyType })
    }
    
    func expenditureByEnergy() -> [EnergySource: Double] {
        let grouped = groupedByEnergyType()
        return grouped.mapValues { units in
            units.reduce(0) { $0 + $1.totalExpenditure }
        }
    }
    
    func distanceByOperator() -> [String: Double] {
        let grouped = groupedByOperator()
        return grouped.mapValues { units in
            units.reduce(0) { $0 + $1.totalDistanceCovered }
        }
    }
    
    func bestPerformers() -> [TransportUnit] {
        transportUnits
            .filter { $0.totalDistanceCovered > 0 && $0.totalExpenditure > 0 }
            .sorted { $0.costPerformance > $1.costPerformance }
            .prefix(5)
            .map { $0 }
    }
    
    func eliteOperators() -> [(String, Double, Double)] {
        let operatorMetrics = groupedByOperator().map { (operatorName, units) -> (String, Double, Double) in
            let distance = units.reduce(0) { $0 + $1.totalDistanceCovered }
            let expenditure = units.reduce(0) { $0 + $1.totalExpenditure }
            let performance = expenditure > 0 ? distance / expenditure : 0
            return (operatorName, distance, performance)
        }
        return operatorMetrics
            .filter { $0.1 > 0 }
            .sorted { $0.2 > $1.2 }
            .prefix(5)
            .map { $0 }
    }
}
