import SwiftUI

public struct ContentView: View {
  public init() {
    
  }
  
  public var body: some View {
    NavigationStack {
      Text("ContentView")
        .navigationTitle("NiaBis")
    }
  }
}

#Preview {
  ContentView()
}
