import NiaBisData
import SwiftData
import SwiftUI

public struct ContentView: View {
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
      .modelContainer(container)
  }
}

#Preview {
  ContentView()
    .previewModelContainer()
}
