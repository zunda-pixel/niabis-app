import NiaBisData
import SwiftUI
import SwiftData
import MapKit
import AsyncLocationKit
#if canImport(CoreLocationUI)
import CoreLocationUI
#endif

@MainActor
struct SearchLocationAndMapView: View {
  @State var state: ViewState = .init()

  #if canImport(CoreLocationUI)
  var locationButton: some View {
    LocationButton(.currentLocation) {
      Task(priority: .high) {
        await state.setCurrentLocation()
      }
    }
    .labelStyle(.iconOnly)
    .foregroundColor(.white)
    .clipShape(.rect(cornerSize: .init(width: 15, height: 15)))
    .tint(Color.orange)
    .scaleEffect(1.3)
    .padding(30)
  }
  #endif


  var body: some View {
    Map(position: $state.position)
      .edgesIgnoringSafeArea(.all)
      .overlay(alignment: .topTrailing) {
        #if canImport(CoreLocationUI)
        locationButton
        #endif
      }
      .sheet(isPresented: .constant(true)) {
        SearchLocationView()
          .interactiveDismissDisabled()
          .presentationDetents([.fraction(0.1), .fraction(0.3), .large])
          .presentationBackgroundInteraction(.enabled)
          .presentationDragIndicator(.visible)
      }
  }
}

#Preview {
  SearchLocationAndMapView()
    .previewModelContainer()
    .environment(ErrorController())
}
