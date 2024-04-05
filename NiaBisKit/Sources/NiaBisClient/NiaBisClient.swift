import Foundation
import HTTPTypes
import HTTPTypesFoundation

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
      .appending(path: "location")
      .appending(queryItems: [
        .init(name: "locationName", value: locationName),
        .init(name: "language", value: language.rawValue),
      ])
    
    var request = HTTPRequest(method: .get, url: url)
    request.headerFields = [
      .accept: "application/json",
      .authorization: "Bearer \(token)"
    ]
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
    let location = try JSONDecoder().decode(LocationInformation.self, from: data)
    
    return location
  }
}
