import MapKit
import NiaBisData
import SwiftUI

struct LoadingShopView: View {
  let completion: MKLocalSearchCompletion
  @State var location: Location?
  @Environment(ErrorController.self) var errorController
  @Environment(\.modelContext) var modelContext

  func search() async {
    let request = MKLocalSearch.Request(completion: completion)
    let search = MKLocalSearch(request: request)

    do {
      guard let mapItem = try await search.start().mapItems.first else {
        throw AbortError.notFount
      }

      let location = Location(completion: completion, mapItem: mapItem)
      modelContext.insert(location)
      self.location = location
    } catch {
      self.errorController.error = error
    }
  }

  var body: some View {
    if let location {
      LocationDetailView(location: location, isNew: true)
    } else {
      NavigationStack {
        VStack {
          Text(completion.title)
          Text(completion.subtitle)
        }
        .navigationTitle(completion.title)
      }
      .task {
        await search()
      }
    }
  }
}

extension Location {
  fileprivate convenience init(completion: MKLocalSearchCompletion, mapItem: MKMapItem) {
    self.init(
      id: .init(),
      name: mapItem.name ?? mapItem.placemark.title ?? completion.title,
      content: "",
      createdAt: .now,
      updatedAt: nil,
      latitude: mapItem.placemark.coordinate.latitude,
      longitude: mapItem.placemark.coordinate.longitude,
      postalCode: mapItem.placemark.postalAddress?.postalCode,
      country: mapItem.placemark.postalAddress?.country,
      state: mapItem.placemark.postalAddress?.state,
      city: mapItem.placemark.postalAddress?.city,
      subAdministrativeArea: mapItem.placemark.postalAddress?.subAdministrativeArea,
      subLocality: mapItem.placemark.postalAddress?.subLocality,
      street: mapItem.placemark.postalAddress?.street,
      phoneNumber: mapItem.phoneNumber,
      url: mapItem.url,
      budget: nil,
      starCount: 0,
      tags: [],
      imageDatas: []
    )
  }
}
