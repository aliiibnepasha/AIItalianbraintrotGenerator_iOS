import Foundation
import UIKit

enum ImageGenerationError: LocalizedError {
    case invalidResponse
    case serverError(statusCode: Int, message: String)
    case missingImageURL(rawResponse: String)
    case invalidImageData
    case downloadFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return L10n.ServiceError.unexpectedResponse
        case .serverError(let statusCode, let message):
            return L10n.ServiceError.statusWithMessage("\(statusCode)", message)
        case .missingImageURL:
            return L10n.ServiceError.missingURL
        case .invalidImageData:
            return L10n.ServiceError.invalidImageData
        case .downloadFailed:
            return L10n.ServiceError.downloadFailed
        }
    }
}

final class ImageGenerationService {
    private let session: URLSession
    private let endpoint = URL(string: "https://fal.run/fal-ai/nano-banana")!
    private let authorizationHeader: String
    
    init(session: URLSession = .shared) {
        self.session = session
        let rawKey = "afca4d3b-06ac-4c71-9e59-352aa2f875fb:df7fc75c25e4b2cad23341028b46bf43"
        authorizationHeader = ImageGenerationService.authorizationHeaderValue(for: rawKey)
    }
    
    func generateImage(prompt: String, negativePrompt: String? = nil) async throws -> UIImage {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(authorizationHeader, forHTTPHeaderField: "Authorization")
        
        var body: [String: Any] = ["prompt": prompt]
        if let negativePrompt, negativePrompt.isEmpty == false {
            body["negative_prompt"] = negativePrompt
        }
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ImageGenerationError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let message = String(data: data, encoding: .utf8) ?? L10n.ServiceError.unknownError
            throw ImageGenerationError.serverError(statusCode: httpResponse.statusCode, message: message)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let payload = try decoder.decode(FalImageResponse.self, from: data)
        
        if let urlString = payload.firstImageURL, let url = URL(string: urlString) {
            return try await downloadImage(from: url)
        }
        
        if let base64 = payload.firstBase64, let imageData = Data(base64Encoded: base64) {
            guard let uiImage = UIImage(data: imageData) else {
                throw ImageGenerationError.invalidImageData
            }
            return uiImage
        }
        
        let rawResponse = String(data: data, encoding: .utf8) ?? L10n.ServiceError.noResponseBody
        throw ImageGenerationError.missingImageURL(rawResponse: rawResponse)
    }
    
    private func downloadImage(from url: URL) async throws -> UIImage {
        let (imageData, _) = try await session.data(from: url)
        guard let uiImage = UIImage(data: imageData) else {
            throw ImageGenerationError.downloadFailed
        }
        return uiImage
    }
    
    private static func authorizationHeaderValue(for rawKey: String) -> String {
        let trimmed = rawKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let lowered = trimmed.lowercased()
        
        if lowered.hasPrefix("basic ") || lowered.hasPrefix("key ") {
            return trimmed
        }
        
        // fal.ai accepts the literal "Key <token>" header, even when the token contains a colon.
        // Avoid auto-converting to Basic auth to prevent 401s with fal-issued keys.
        return "Key \(trimmed)"
    }
}

private struct FalImageResponse: Decodable {
    struct ImageInfo: Decodable {
        let url: String?
        let data: String?
        let base64: String?
        let contentType: String?
        let fileName: String?
        
        enum CodingKeys: String, CodingKey {
            case url
            case data
            case base64
            case contentType
            case fileName
        }
        
        var base64Payload: String? {
            base64 ?? data
        }
    }
    
    struct Output: Decodable {
        let url: String?
        let data: String?
        let base64: String?
        let image: ImageInfo?
        
        var base64Payload: String? {
            base64 ?? data ?? image?.base64Payload
        }
        
        var imageURL: String? {
            url ?? image?.url
        }
    }
    
    struct ResponsePayload: Decodable {
        let images: [ImageInfo]?
        let output: [Output]?
    }
    
    let images: [ImageInfo]?
    let image: ImageInfo?
    let output: [Output]?
    let response: ResponsePayload?
    
    var firstImageURL: String? {
        if let direct = images?.first?.url {
            return direct
        }
        if let single = image?.url {
            return single
        }
        if let directOutput = output?.first?.imageURL {
            return directOutput
        }
        if let responseImages = response?.images?.first?.url {
            return responseImages
        }
        if let responseOutput = response?.output?.first?.imageURL {
            return responseOutput
        }
        return nil
    }
    
    var firstBase64: String? {
        if let data = images?.first?.base64Payload {
            return data
        }
        if let data = image?.base64Payload {
            return data
        }
        if let data = output?.first?.base64Payload {
            return data
        }
        if let data = response?.images?.first?.base64Payload {
            return data
        }
        if let data = response?.output?.first?.base64Payload {
            return data
        }
        return nil
    }
}


