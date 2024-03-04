import AsyncLocationKit
import MapKit
import NiaBisData
import SwiftData
import SwiftUI

@MainActor
struct SearchLocationAndMapView: View {
  @State var position: MapCameraPosition = .userLocation(fallback: .automatic)
  @Query var locations: [Location]

  var body: some View {
    Map(position: $position) {
      UserAnnotation()
      
      ForEach(locations.filter { $0.coodinate != nil }) { location in
        Marker(
          location.name,
          coordinate: location.coodinate!
        )
      }
    }
    .overlay(alignment: .bottomTrailing) {
      Button {
        position = .userLocation(fallback: .automatic)
      } label: {
        Circle()
          .frame(width: 50, height: 50)
          .foregroundStyle(.thinMaterial)
          .overlay {
            Image(systemName: "location.fill")
              .imageScale(.large)
              .foregroundStyle(.blue)
          }
      }
      .padding(.trailing, 10)
      .padding(.bottom, 100)
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
