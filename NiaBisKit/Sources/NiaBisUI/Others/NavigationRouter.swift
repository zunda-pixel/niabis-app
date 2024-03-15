import Observation

@Observable
final class NavigationRouter {
  var routes: [Item] = []

  enum Item: Hashable {
  }
}
