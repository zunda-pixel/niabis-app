import Foundation
import HTTPTypes
import HTTPTypesFoundation

public enum ImageParameter {
  case url(URL)
  case data(Data)
}

public struct NiaBisClient {
  private let token: String
  private let locale: Locale
  private var language: Language {
    Language(locale: locale) ?? .english
  }
  
  private let baseURL: URL = .init(string: "https://api.niabis.com/")!
  
  public init(
    token: String,
    locale: Locale
  ) {
    self.token = token
    self.locale = locale
  }

  public func location(name locationName: String) async throws -> LocationInformation {
    let url: URL = baseURL
      .appending(path: "locationDetail")
      .appending(queryItems: [
        .init(name: "locationName", value: locationName),
        .init(name: "language", value: language.rawValue),
      ])
    
    let request = HTTPRequest(method: .get, url: url, headerFields: .init([
      .init(name: .accept, value: "application/json"),
      .init(name: .authorization, value: "Bearer \(token)")
    ]))
    
    let (data, _) = try await URLSession.shared.data(for: request)
    
    let location = try JSONDecoder().decode(LocationInformation.self, from: data)
    
    return location
  }
  
  public func uploadImage(image: ImageParameter) async throws -> UUID {
    var url: URL = baseURL
      .appending(path: "image")
    
    if case .url(let imageURL) = image {
      url.append(queryItems: [.init(name: "url", value: imageURL.absoluteString)])
    }
    
    let request = HTTPRequest(method: .get, url: url, headerFields: .init([
      .init(name: .accept, value: "application/json"),
      .init(name: .authorization, value: "Bearer \(token)")
    ]))
    
    let data: Data
    switch image {
    case .data(let imageData):
      (data, _) = try await URLSession.shared.upload(for: request, from: imageData)
    case .url(_):
      (data, _) = try await URLSession.shared.data(for: request)
    }
    
    let uploadedImage = try JSONDecoder().decode(UploadImage.self, from: data)
    
    return uploadedImage.id
  }
  
  public func uploadImages(images: [ImageParameter]) async throws -> [UUID] {
    try await withThrowingTaskGroup(of: UUID.self) { group in
      for image in images {
        group.addTask {
          return try await uploadImage(image: image)
        }
      }
      
      var imageIDs: [UUID] = []
      
      for try await imageID in group {
        imageIDs.append(imageID)
      }
      
      return imageIDs
    }
  }
}

private struct UploadImage: Codable {
  var id: UUID
}
