import Foundation

public struct IdentifiedItem<Item: Hashable>: Identifiable, Hashable {
  public let id: UUID
  public let item: Item

  public init(id: UUID = UUID(), item: Item) {
    self.id = id
    self.item = item
  }
}

extension IdentifiedItem: Codable where Item: Codable {
  
}

extension IdentifiedItem: Sendable where Item: Sendable {
  
}
