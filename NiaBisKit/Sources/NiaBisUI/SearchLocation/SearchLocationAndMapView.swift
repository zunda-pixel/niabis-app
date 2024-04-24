import AsyncLocationKit
import MapKit
import NiaBisData
import SwiftData
import SwiftUI

@MainActor
struct SearchLocationAndMapView: View {
  @Query var locations: [Location]
  @Environment(\.openURL) var openURL
  @State var position: MapCameraPosition = .userLocation(fallback: .automatic)
  @State var task: Task<Void, Never>?
  @State var isPresentedRequestLocationPermissionAlert = false
  @State var isPresentedSheet = true
  @State var presentationDetent: PresentationDetent = Constants.presentationDetents.first!
  @State var selectedLocation: Location?
  @State var selectedLocationID: Location.ID?

  var bottomLocationButtonPadding: CGFloat {
    // 😏 Manual Set
    switch presentationDetent {
    case Constants.presentationDetents[0]:
      return 310
    case Constants.presentationDetents[1]:
      return 110
    case Constants.presentationDetents[2]:
      return 310
    default:
      fatalError()
    }
  }
  
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
    .overlay(alignment: .bottomTrailing) {
      Button {
        let request: AsyncLocationManager = .init()
        let locationAuthorization = request.getAuthorizationStatus()

        switch locationAuthorization {
        case .authorizedAlways, .authorizedWhenInUse:
          position = .userLocation(fallback: .automatic)
        case .notDetermined:
          Task { await request.requestPermission(with: .whenInUsage) }
        case .denied:
          isPresentedRequestLocationPermissionAlert.toggle()
        case .restricted:
          break
        @unknown default:
          fatalError()
        }
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
      .padding(.bottom, bottomLocationButtonPadding)
      .alert(
        Text("Permission", bundle: .module),
        isPresented: $isPresentedRequestLocationPermissionAlert
      ) {
        Button {
          let url = URL(string: UIApplication.openSettingsURLString)!
          openURL(url)
          isPresentedSheet = true
        } label: {
          Text("Open", bundle: .module)
        }
        Button(role: .cancel) {
          isPresentedSheet = true
        } label: {
          Text("Cancel", bundle: .module)
        }
      } message: {
        Text("GettingLocationRequiresPermissionAndOpenSettings", bundle: .module)
      }
    }
    .sheet(isPresented: $isPresentedSheet) {
      // TODO Remove NavigationStack (iOS 17 Bug)
      // https://github.com/feedback-assistant/reports/issues/471
      NavigationStack {
        LocationsView(selectedLocation: $selectedLocation)
      }
      .interactiveDismissDisabled()
      .presentationBackgroundInteraction(.enabled)
      .presentationDragIndicator(.visible)
      .presentationDetents(Set(Constants.presentationDetents), selection: $presentationDetent)
    }
    .animation(.spring, value: bottomLocationButtonPadding)
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
