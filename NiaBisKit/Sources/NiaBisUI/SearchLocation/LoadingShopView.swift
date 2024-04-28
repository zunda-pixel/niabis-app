import MapKit
import NiaBisData
import SwiftUI
import NiaBisClient

struct LoadingShopView: View {
  let completion: MKLocalSearchCompletion
  @State var location: Location?
  @Environment(\.modelContext) var modelContext
  @Environment(\.locale) var locale

  func search() async {
    let request = MKLocalSearch.Request(completion: completion)
    let search = MKLocalSearch(request: request)

    do {
      async let mapItem = try await search.start().mapItems.first
      
      let client = NiaBisClient(
        token: Constants.niabisAPIToken,
        locale: locale
      )
      async let locationInfomation = try await client.location(name: completion.title)

      guard let mapItem = try await mapItem else {
        throw AbortError.notFount
      }

      let location = try await Location(
        completion: completion,
        mapItem: mapItem,
        information: locationInfomation
      )
      modelContext.insert(location)
      self.location = location
    } catch {
      print(error)
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
  fileprivate convenience init(
    completion: MKLocalSearchCompletion,
    mapItem: MKMapItem,
    information: LocationInformation
  ) {
    self.init(
      id: .init(),
      name: mapItem.name ?? mapItem.placemark.title ?? completion.title,
      content: information.description,
      createdDate: .now,
      updatedDate: nil,
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
      tags: information.cuisines.map(\.localizedName).map { .init(item: $0) },
      photoIDs: information.photoIDs.map { .init(item: $0) }
    )
  }
}
