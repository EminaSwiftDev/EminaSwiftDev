//
//  AddVehicleView.swift
//  carpark
//

import SwiftUI
import PhotosUI

struct NewUnitForm: View {
    @ObservedObject var storageManager: StorageController
    @Environment(\.presentationMode) var closeModal
    
    @State private var unitName = ""
    @State private var modelName = ""
    @State private var selectedCategory: TransportCategory = .sedan
    @State private var selectedEnergyType: EnergySource = .gasoline
    @State private var operatorName = ""
    @State private var unitPhoto: UIImage?
    @State private var operatorPhoto: UIImage?
    @State private var unitPhotoPickerVisible = false
    @State private var operatorPhotoPickerVisible = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Vehicle Information")) {
                    TextField("Name (e.g.: Truck 123)", text: $unitName)
                    
                    TextField("Model (e.g.: Ford F-150)", text: $modelName)
                    
                    Picker("Vehicle Type", selection: $selectedCategory) {
                        ForEach(TransportCategory.allCases, id: \.self) { category in
                            HStack {
                                Image(systemName: category.symbolName)
                                Text(category.rawValue)
                            }
                            .tag(category)
                        }
                    }
                    
                    Picker("Fuel Type", selection: $selectedEnergyType) {
                        ForEach(EnergySource.allCases, id: \.self) { energy in
                            HStack {
                                Image(systemName: energy.symbolName)
                                Text(energy.rawValue)
                            }
                            .tag(energy)
                        }
                    }
                }
                
                Section(header: Text("Vehicle Photo")) {
                    if let unitPhoto = unitPhoto {
                        Image(uiImage: unitPhoto)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    Button(action: { unitPhotoPickerVisible = true }) {
                        Label(unitPhoto == nil ? "Add Photo" : "Change Photo", systemImage: "photo")
                    }
                }
                
                Section(header: Text("Driver")) {
                    TextField("Driver Name", text: $operatorName)
                    
                    if let operatorPhoto = operatorPhoto {
                        HStack {
                            Spacer()
                            Image(uiImage: operatorPhoto)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                            Spacer()
                        }
                    }
                    
                    Button(action: { operatorPhotoPickerVisible = true }) {
                        Label(operatorPhoto == nil ? "Add Driver Photo" : "Change Photo", systemImage: "person.crop.circle")
                    }
                }
            }
            .navigationTitle("New Vehicle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        closeModal.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        persistNewUnit()
                    }
                    .disabled(unitName.isEmpty || modelName.isEmpty || operatorName.isEmpty)
                }
            }
            .sheet(isPresented: $unitPhotoPickerVisible) {
                PhotoSelector(selectedImage: $unitPhoto)
            }
            .sheet(isPresented: $operatorPhotoPickerVisible) {
                PhotoSelector(selectedImage: $operatorPhoto)
            }
        }
    }
    
    private func persistNewUnit() {
        var newUnit = TransportUnit(
            unitName: unitName,
            modelName: modelName,
            category: selectedCategory,
            energyType: selectedEnergyType,
            operatorName: operatorName
        )
        
        if let unitPhoto = unitPhoto {
            newUnit.imageBytes = unitPhoto.jpegData(compressionQuality: 0.8)
        }
        
        if let operatorPhoto = operatorPhoto {
            newUnit.operatorImageBytes = operatorPhoto.jpegData(compressionQuality: 0.8)
        }
        
        storageManager.registerNewUnit(newUnit)
        closeModal.wrappedValue.dismiss()
    }
}

struct PhotoSelector: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var closeModal
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let controller = UIImagePickerController()
        controller.delegate = context.coordinator
        controller.sourceType = .photoLibrary
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> PhotoCoordinator {
        PhotoCoordinator(self)
    }
    
    class PhotoCoordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parentView: PhotoSelector
        
        init(_ parentView: PhotoSelector) {
            self.parentView = parentView
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let photo = info[.originalImage] as? UIImage {
                parentView.selectedImage = photo
            }
            parentView.closeModal.wrappedValue.dismiss()
        }
    }
}
