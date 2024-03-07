import NiaBisData
import SwiftData
import SwiftUI

public struct ContentView: View {
  let errorController = ErrorController()

  public init() {

  }
  
  let container: ModelContainer = {
    let configuration = ModelConfiguration(
      cloudKitDatabase: .private(Constants.privateCloudKitDatabaseName)
    )
    let container = try! ModelContainer(
      for: Location.self,
      configurations: configuration
    )
    return container
  }()

  public var body: some View {
    SearchLocationAndMapView()
      .environment(errorController)
      // TODO Remove inMemory
      .modelContainer(container)
  }
}

#Preview {
  ContentView()
    .previewModelContainer()
}
