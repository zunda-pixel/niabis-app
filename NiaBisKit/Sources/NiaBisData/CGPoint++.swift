import Foundation

extension CGPoint: Codable {
  private enum CodingKeys: String, CodingKey {
    case x
    case y
  }
  
  public func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.x, forKey: .x)
    try container.encode(self.y, forKey: .y)
  }
  
  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let x = try container.decode(Double.self, forKey: .x)
    let y = try container.decode(Double.self, forKey: .y)
    self.init(x: x, y: y)
  }
}
