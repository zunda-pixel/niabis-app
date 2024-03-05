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
      .padding(.bottom, 100)
      .alert("Permission", isPresented: $isPresentedRequestLocationPermissionAlert) {
        Button("Open") {
          let url = URL(string: UIApplication.openSettingsURLString)!
          openURL(url)
          isPresentedSheet = true
        }
        Button(role: .cancel) {
          isPresentedSheet = true
        } label: {
          Text("Cancel")
        }
      } message: {
        Text("Getting location requires permission")
        Text("Open Settings to get permission")
      }
    }
    .sheet(isPresented: $isPresentedSheet) {
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
