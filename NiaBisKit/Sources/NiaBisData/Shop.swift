import SwiftData
import Tagged
import Foundation

@Model
public final class Shop: Identifiable {
  public typealias ID = Tagged<Shop, UUID>

  public var id: ID
  public var name: String
  public var content: String
  public var createdAt: Date
  public var updatedAt: Date?

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
  public var starCount: Int
  public var tags: [String]
  public var imageDatas: [Data]
  
  public init(
    id: ID,
    name: String,
    content: String,
    createdAt: Date,
    updatedAt: Date? = nil,
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
    starCount: Int,
    tags: [String],
    imageDatas: [Data]
  ) {
    self.id = id
    self.name = name
    self.content = content
    self.createdAt = createdAt
    self.updatedAt = updatedAt
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
    self.imageDatas = imageDatas
  }
}
