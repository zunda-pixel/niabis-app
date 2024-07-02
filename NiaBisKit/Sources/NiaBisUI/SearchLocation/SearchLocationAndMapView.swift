import MapKit
import NiaBisData
import SwiftData
import SwiftUI

@MainActor
struct SearchLocationAndMapView: View {
  @Query var locations: [Location]
  @Environment(\.openURL) var openURL
  @State var position: MapCameraPosition = .userLocation(fallback: .automatic)
  @State var isPresentedSheet = true
  @State var presentationDetent: PresentationDetent = Constants.presentationDetents.first!
  @State var selectedLocation: Location?
  @State var selectedLocationID: Location.ID?
  
  var body: some View {
    Map(position: $position, selection: $selectedLocationID) {
      UserAnnotation()
      
      ForEach(locations.filter { $0.coordinate != nil }) { location in
        Marker(
          location.name,
          coordinate: location.coordinate!
        )
        .tag(location.id)
      }
    }
    .mapControls {
      MapUserLocationButton()
        .controlSize(.large)

      MapCompass()
        .controlSize(.large)
    }
    .sheet(isPresented: $isPresentedSheet) {
      LocationsView(selectedLocation: $selectedLocation)
        .interactiveDismissDisabled()
        .presentationBackgroundInteraction(.enabled)
        .presentationDragIndicator(.visible)
        .presentationDetents(Set(Constants.presentationDetents), selection: $presentationDetent)
    }
    .onChange(of: selectedLocation) { _, newValue in
      guard let coordinate = newValue?.coordinate else { return }
      position = .item(.init(placemark: .init(coordinate: coordinate)))
    }
    .onChange(of: selectedLocationID) { _, newValue in
      selectedLocation = locations.first { $0.id == newValue }
    }
  }
}

#Preview {
  SearchLocationAndMapView()
    .previewModelContainer()
}
