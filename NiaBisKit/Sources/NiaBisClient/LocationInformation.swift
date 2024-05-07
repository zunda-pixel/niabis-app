import Foundation

public struct LocationInformation: Sendable, Codable, Hashable, Identifiable {
  public var id: Int
  public var description: String
  public var photoIDs: [UUID]
  public var cuisines: [LabelContent]
}
