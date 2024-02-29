import SwiftUI

public struct ContentView: View {
  let errorController = ErrorController()
  
  public init() {
    
  }
  
  public var body: some View {
    SearchShopAndMapView()
      .environment(errorController)
  }
}

#Preview {
  ContentView()
    .previewModelContainer()
}

