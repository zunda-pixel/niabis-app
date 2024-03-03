import SwiftUI
import SwiftData
import NiaBisData

public struct ContentView: View {
  let errorController = ErrorController()
  
  public init() {
    
  }
  
  public var body: some View {
    SearchLocationAndMapView()
      .environment(errorController)
      .modelContainer(for: Location.self, inMemory: true) /// TODO Remove inMemory
  }
}

#Preview {
  ContentView()
    .previewModelContainer()
}

