import SwiftUI
import UIKit

struct GeneratedImage: Identifiable, Hashable {
    let id: UUID
    let image: UIImage
    let title: String
    let subtitle: String?
    let createdAt: Date
    let fileName: String
    
    init(
        id: UUID = UUID(),
        image: UIImage,
        title: String,
        subtitle: String?,
        createdAt: Date = Date(),
        fileName: String
    ) {
        self.id = id
        self.image = image
        self.title = title
        self.subtitle = subtitle
        self.createdAt = createdAt
        self.fileName = fileName
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: GeneratedImage, rhs: GeneratedImage) -> Bool {
        lhs.id == rhs.id
    }
}

final class GeneratedContentStore: ObservableObject {
    @Published var lastGenerated: GeneratedImage?
    @Published private(set) var gallery: [GeneratedImage] = []
    @Published private(set) var favorites: [GeneratedImage] = []
    
    private let imagesDirectory: URL
    private let metadataURL: URL
    
    private struct PersistedImage: Codable {
        let id: UUID
        let fileName: String
        let title: String
        let subtitle: String?
        let createdAt: Date
        let isFavorite: Bool
    }
    
    private struct PersistedState: Codable {
        let images: [PersistedImage]
        let lastGeneratedID: UUID?
    }
    
    init() {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        imagesDirectory = documents.appendingPathComponent("GeneratedImages", isDirectory: true)
        metadataURL = documents.appendingPathComponent("generated_images.json")
        
        try? FileManager.default.createDirectory(at: imagesDirectory, withIntermediateDirectories: true)
        loadState()
    }
    
    @discardableResult
    func saveGeneration(image uiImage: UIImage, title: String, subtitle: String?) throws -> GeneratedImage {
        let fileName = "\(UUID().uuidString).png"
        let fileURL = imagesDirectory.appendingPathComponent(fileName)
        
        guard let data = uiImage.pngData() else {
            throw NSError(domain: "GeneratedContentStore", code: 0, userInfo: [NSLocalizedDescriptionKey: L10n.ServiceError.invalidImageData])
        }
        
        try data.write(to: fileURL, options: .atomic)
        
        let generated = GeneratedImage(
            image: uiImage,
            title: title,
            subtitle: subtitle,
            fileName: fileName
        )
        
        lastGenerated = generated
        gallery.insert(generated, at: 0)
        persistFavorites()
        saveState()
        return generated
    }
    
    func toggleFavorite(_ image: GeneratedImage) {
        if let index = favorites.firstIndex(of: image) {
            favorites.remove(at: index)
        } else {
            favorites.insert(image, at: 0)
        }
        saveState()
    }
    
    func isFavorite(_ image: GeneratedImage) -> Bool {
        favorites.contains(image)
    }
    
    func delete(_ image: GeneratedImage) {
        gallery.removeAll { $0 == image }
        favorites.removeAll { $0 == image }
        if lastGenerated == image {
            lastGenerated = gallery.first
        }
        
        let fileURL = imagesDirectory.appendingPathComponent(image.fileName)
        try? FileManager.default.removeItem(at: fileURL)
        saveState()
    }
    
    private func persistFavorites() {
        favorites = favorites.filter { gallery.contains($0) }
    }
    
    private func saveState() {
        persistFavorites()
        
        let images = gallery.map { image in
            PersistedImage(
                id: image.id,
                fileName: image.fileName,
                title: image.title,
                subtitle: image.subtitle,
                createdAt: image.createdAt,
                isFavorite: favorites.contains(image)
            )
        }
        
        let state = PersistedState(images: images, lastGeneratedID: lastGenerated?.id)
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted]
            let data = try encoder.encode(state)
            try data.write(to: metadataURL, options: .atomic)
        } catch {
            print("⚠️ Failed to save generated image state: \(error)")
        }
    }
    
    private func loadState() {
        guard let data = try? Data(contentsOf: metadataURL) else { return }
        
        do {
            let decoder = JSONDecoder()
            let state = try decoder.decode(PersistedState.self, from: data)
            var loadedGallery: [GeneratedImage] = []
            var favoriteIDs = Set<UUID>()
            
            for item in state.images {
                let fileURL = imagesDirectory.appendingPathComponent(item.fileName)
                guard let imageData = try? Data(contentsOf: fileURL),
                      let uiImage = UIImage(data: imageData) else {
                    continue
                }
                
                let generated = GeneratedImage(
                    id: item.id,
                    image: uiImage,
                    title: item.title,
                    subtitle: item.subtitle,
                    createdAt: item.createdAt,
                    fileName: item.fileName
                )
                
                loadedGallery.append(generated)
                if item.isFavorite {
                    favoriteIDs.insert(item.id)
                }
            }
            
            gallery = loadedGallery
            favorites = loadedGallery.filter { favoriteIDs.contains($0.id) }
            if let lastID = state.lastGeneratedID,
               let match = loadedGallery.first(where: { $0.id == lastID }) {
                lastGenerated = match
            } else {
                lastGenerated = loadedGallery.first
            }
        } catch {
            print("⚠️ Failed to load generated image state: \(error)")
        }
    }
    
#if DEBUG
    func loadPreview(_ images: [GeneratedImage]) {
        gallery = images
        favorites = []
        lastGenerated = images.first
    }
#endif
}

