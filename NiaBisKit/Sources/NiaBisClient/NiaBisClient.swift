import Foundation
import HTTPTypes
import HTTPTypesFoundation

public enum ImageParameter: Sendable, Hashable {
  case url(URL)
  case data(Data)
}

public struct NiaBisClient {
  private let apiToken: String
  private let locale: Locale
  private var language: Language {
    Language(locale: locale) ?? .english
  }
  
  private let baseURL: URL = .init(string: "https://api.niabis.com/")!
  
  public init(
    apiToken: String,
    locale: Locale
  ) {
    self.apiToken = apiToken
    self.locale = locale
  }

  public func location(name locationName: String) async throws -> LocationInformation {
    let url: URL = baseURL
      .appending(path: "locationDetail")
      .appending(queryItems: [
        .init(name: "locationName", value: locationName),
        .init(name: "language", value: language.rawValue),
      ])
    
    let request = HTTPRequest(
      method: .get,
      url: url,
      headerFields: [
        .accept: "application/json",
        .authorization: "Bearer \(apiToken)"
      ]
    )
    
    let (data, _) = try await URLSession.shared.data(for: request)
    
    let location = try JSONDecoder().decode(LocationInformation.self, from: data)
    
    return location
  }
  
  public func uploadImage(image: ImageParameter) async throws -> UUID {
    let url: URL = baseURL
      .appending(path: "image")
    
    var request = HTTPRequest(
      method: .post,
      url: url,
      headerFields: [
        .accept: "application/json",
        .authorization: "Bearer \(apiToken)",
      ]
    )
    
    let data: Data
    switch image {
    case .data(let imageData):
      (data, _) = try await URLSession.shared.upload(for: request, from: imageData)
    case .url(let url):
      request.headerFields.append(.init(name: .contentType, value: "application/json"))
      struct URLImage: Codable {
        let url: URL
      }
      
      let urlImage = URLImage(url: url)
      let body = try! JSONEncoder().encode(urlImage)
      (data, _) = try await URLSession.shared.upload(for: request, from: body)
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
