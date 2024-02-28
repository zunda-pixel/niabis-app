import SwiftUI

public struct ContentView: View {
  let errorController = ErrorController()
  
  public init() {
    
  }
  
  public var body: some View {
    SearchShopAndMap()
      .environment(errorController)
  }
}

#Preview {
  ContentView()
    .previewModelContainer()
}

