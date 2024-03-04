import Foundation

struct IdentifiedItem<Item>: Identifiable {
  let id: UUID
  let item: Item

  init(id: UUID = UUID(), item: Item) {
    self.id = id
    self.item = item
  }
}
