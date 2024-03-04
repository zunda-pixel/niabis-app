import NiaBisData
import SwiftData
import SwiftUI

public struct ContentView: View {
  let errorController = ErrorController()

  public init() {

  }

  public var body: some View {
    SearchLocationAndMapView()
      .environment(errorController)
      // TODO Remove inMemory
      .modelContainer(for: Location.self, inMemory: true)

  }
}

#Preview {
  ContentView()
    .previewModelContainer()
}
