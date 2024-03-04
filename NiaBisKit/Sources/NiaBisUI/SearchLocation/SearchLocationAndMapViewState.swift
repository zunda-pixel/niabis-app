import AsyncLocationKit
import MapKit
import SwiftUI

extension SearchLocationAndMapView {
  @Observable
  final class ViewState {
    var position: MapCameraPosition
    var currentLocation: CLLocation? {
      didSet {
        guard let coordinate = self.currentLocation?.coordinate else { return }
        self.position = .region(
          .init(
            center: coordinate,
            latitudinalMeters: 1000,
            longitudinalMeters: 1000
          ))
      }
    }

    var error: Error?

    @ObservationIgnored
    let manager: AsyncLocationManager

    @MainActor
    init() {
      self.manager = .init()
      self.position = .region(
        .init(
          center: .init(latitude: 13.1, longitude: 80.3),
          latitudinalMeters: 1000,
          longitudinalMeters: 1000
        ))
    }

    func setCurrentLocation() async {
      do {
        guard let event: LocationUpdateEvent = try await manager.requestLocation() else { return }
        switch event {
        case .didUpdateLocations(let locations):
          self.currentLocation = locations.last
        case .didFailWith(let error):
          self.error = error
        case .didPaused, .didResume:
          break
        }
      } catch {
        self.error = error
      }
    }
  }
}
