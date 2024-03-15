import SwiftData
import Foundation
import Contacts
import MapKit

@Model
public final class Location: Identifiable {
  public typealias ID = UUID

  public var id: ID = UUID()
  public var name: String = ""
  public var content: String = ""
  public var createdDate: Date = Date.now
  public var updatedDate: Date?

  public var latitude: Double?
  public var longitude: Double?
  
  public var postalCode: String?
  public var country: String?
  public var state: String?
  public var city: String?
  public var subAdministrativeArea: String?
  public var subLocality: String?
  public var street: String?

  public var phoneNumber: String?
  public var url: URL?

  public var budget: Int?
  public var starCount: Int?
  public var tags: [String] = []
  public var photoURLs: [URL] = []
  public var photoDatas: [Data] = []

  public init(
    id: ID,
    name: String,
    content: String,
    createdDate: Date,
    updatedDate: Date? = nil,
    latitude: Double? = nil,
    longitude: Double? = nil,
    postalCode: String? = nil,
    country: String? = nil,
    state: String? = nil,
    city: String? = nil,
    subAdministrativeArea: String? = nil,
    subLocality: String? = nil,
    street: String? = nil,
    phoneNumber: String? = nil,
    url: URL? = nil,
    budget: Int? = nil,
    starCount: Int? = nil,
    tags: [String],
    photoURLs: [URL],
    photoDatas: [Data]
  ) {
    self.id = id
    self.name = name
    self.content = content
    self.createdDate = createdDate
    self.updatedDate = updatedDate
    self.latitude = latitude
    self.longitude = longitude
    self.postalCode = postalCode
    self.country = country
    self.state = state
    self.city = city
    self.subAdministrativeArea = subAdministrativeArea
    self.subLocality = subLocality
    self.street = street
    self.phoneNumber = phoneNumber
    self.url = url
    self.budget = budget
    self.starCount = starCount
    self.tags = tags
    self.photoURLs = photoURLs
    self.photoDatas = photoDatas
  }
}

extension Location {
  public var coodinate: CLLocationCoordinate2D? {
    guard let latitude, let longitude else { return nil }
    return .init(latitude: latitude, longitude: longitude)
  }
  
  public func postalAddress(style: CNPostalAddressFormatter.Style) -> CNPostalAddress {
    let postalAddress = CNMutablePostalAddress()
    
    switch style {
    case .full:
      postalCode.map { postalAddress.postalCode = $0 }
      state.map { postalAddress.state = $0 }
      city.map { postalAddress.city = $0 }
      subAdministrativeArea.map { postalAddress.subAdministrativeArea = $0 }
      subLocality.map { postalAddress.subLocality = $0 }
      street.map { postalAddress.street = $0 }
    case .medium:
      state.map { postalAddress.state = $0 }
      city.map { postalAddress.city = $0 }
      subAdministrativeArea.map { postalAddress.subAdministrativeArea = $0 }
      subLocality.map { postalAddress.subLocality = $0 }
      street.map { postalAddress.street = $0 }
    case .short:
      state.map { postalAddress.state = $0 }
      city.map { postalAddress.city = $0 }
    }
    
    return postalAddress
  }
}
