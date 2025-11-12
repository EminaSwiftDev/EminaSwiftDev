//
//  HallOfFameView.swift
//  carpark
//

import SwiftUI

struct LeaderboardPanel: View {
    @ObservedObject var storageManager: StorageController
    @Environment(\.colorScheme) var currentScheme
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    bestUnitsSection
                    bestOperatorsSection
                }
                .padding()
            }
            .background(ColorPalette.backgroundMain(scheme: currentScheme))
            .navigationTitle("Hall of Fame")
        }
    }
    
    private var bestUnitsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "trophy.fill")
                    .foregroundColor(.yellow)
                    .font(.title2)
                
                Text("Top Vehicles")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            if storageManager.bestPerformers().isEmpty {
                placeholderCard(message: "No data for ranking yet")
            } else {
                ForEach(Array(storageManager.bestPerformers().enumerated()), id: \.element.id) { position, unit in
                    BestUnitDisplay(unit: unit, position: position + 1)
                }
            }
        }
    }
    
    private var bestOperatorsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.blue)
                    .font(.title2)
                
                Text("Top Drivers")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            if storageManager.eliteOperators().isEmpty {
                placeholderCard(message: "No data for ranking yet")
            } else {
                ForEach(Array(storageManager.eliteOperators().enumerated()), id: \.offset) { position, operatorData in
                    BestOperatorDisplay(
                        operatorName: operatorData.0,
                        distance: operatorData.1,
                        performance: operatorData.2,
                        position: position + 1,
                        units: storageManager.transportUnits.filter { $0.operatorName == operatorData.0 }
                    )
                }
            }
        }
    }
    
    private func placeholderCard(message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(ColorPalette.backgroundSecondary(scheme: currentScheme))
        .cornerRadius(12)
    }
}

struct BestUnitDisplay: View {
    let unit: TransportUnit
    let position: Int
    @Environment(\.colorScheme) var currentScheme
    
    var positionTint: Color {
        let tintMap: [Int: Color] = [
            1: .yellow,
            2: .gray,
            3: .orange
        ]
        return tintMap[position] ?? .blue
    }
    
    var positionSymbol: String {
        let symbolMap: [Int: String] = [
            1: "crown.fill",
            2: "medal.fill",
            3: "medal.fill"
        ]
        return symbolMap[position] ?? "star.fill"
    }
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(positionTint.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                VStack(spacing: 4) {
                    Image(systemName: positionSymbol)
                        .foregroundColor(positionTint)
                        .font(.title3)
                    Text("#\(position)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(positionTint)
                }
            }
            
            if let imageBytes = unit.imageBytes, let image = UIImage(data: imageBytes) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: unit.category.symbolName)
                            .font(.title2)
                            .foregroundColor(.blue)
                    )
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(unit.unitName)
                    .font(.headline)
                
                Text(unit.operatorName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 12) {
                    Label(String(format: "%.0f km", unit.totalDistanceCovered), systemImage: "road.lanes")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Label(String(format: "%.2f km/$", unit.costPerformance), systemImage: "chart.line.uptrend.xyaxis")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(ColorPalette.backgroundCard(scheme: currentScheme))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct BestOperatorDisplay: View {
    let operatorName: String
    let distance: Double
    let performance: Double
    let position: Int
    let units: [TransportUnit]
    @Environment(\.colorScheme) var currentScheme
    
    var positionTint: Color {
        let tintMap: [Int: Color] = [
            1: .yellow,
            2: .gray,
            3: .orange
        ]
        return tintMap[position] ?? .blue
    }
    
    var positionSymbol: String {
        let symbolMap: [Int: String] = [
            1: "crown.fill",
            2: "medal.fill",
            3: "medal.fill"
        ]
        return symbolMap[position] ?? "star.fill"
    }
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(positionTint.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                VStack(spacing: 4) {
                    Image(systemName: positionSymbol)
                        .foregroundColor(positionTint)
                        .font(.title3)
                    Text("#\(position)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(positionTint)
                }
            }
            
            if let firstUnit = units.first,
               let operatorImageBytes = firstUnit.operatorImageBytes,
               let image = UIImage(data: operatorImageBytes) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.purple.opacity(0.2))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.title)
                            .foregroundColor(.purple)
                    )
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(operatorName)
                    .font(.headline)
                
                Text("\(units.count) vehicle(s)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 12) {
                    Label(String(format: "%.0f km", distance), systemImage: "road.lanes")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Label(String(format: "%.2f km/$", performance), systemImage: "chart.line.uptrend.xyaxis")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(ColorPalette.backgroundCard(scheme: currentScheme))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}
