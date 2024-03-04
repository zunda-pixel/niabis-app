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
  @Query var locations: [Location]
  
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
    Map(position: $state.position) {
      ForEach(locations.filter { $0.coodinate != nil }) { location in
        Marker(
          location.name,
          coordinate: location.coodinate!
        )
      }
    }
      .edgesIgnoringSafeArea(.all)
      .overlay(alignment: .topTrailing) {
        #if canImport(CoreLocationUI)
        locationButton
        #endif
      }
      .sheet(isPresented: .constant(true)) {
        // TODO Remove NavigationStack (iOS 17 Bug)
        // https://github.com/feedback-assistant/reports/issues/471
        NavigationStack {
          SearchLocationView()
        }
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
