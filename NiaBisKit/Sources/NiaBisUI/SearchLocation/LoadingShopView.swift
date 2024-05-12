import MapKit
import NiaBisData
import SwiftUI
import NiaBisClient
import SystemNotification

struct LoadingShopView: View {
  let completion: MKLocalSearchCompletion
  var location: Location
  @Environment(\.modelContext) var modelContext
  @Environment(\.locale) var locale
  @StateObject var toast = SystemNotificationContext()
  @State var imageURLs: [URL] = []

  init(
    completion: MKLocalSearchCompletion,
    location: Location
  ) {
    self.completion = completion
    self.location = location
  }

  func search() async {
    let request = MKLocalSearch.Request(completion: completion)
    let search = MKLocalSearch(request: request)

    do {
      guard let mapItem = try await search.start().mapItems.first else {
        throw AbortError.notFount
      }
      
      let client = NiaBisClient(
        token: SecretConstants.niabisAPIToken,
        locale: locale
      )
      let locationInfomation = try await client.location(name: completion.title)

      location.update(
        completion: completion,
        mapItem: mapItem,
        information: locationInfomation
      )

      imageURLs = locationInfomation.imageURLs
    } catch {
      toast.presentMessage(
        .error(
          text: "Failed to load a Location"
        )
      )
    }
  }

  var body: some View {
    LocationDetailView(location: location, isNew: true, imageURLs: imageURLs)
      .systemNotification(toast)
      .systemNotificationConfiguration(.standardToast)
      .task {
        await search()
      }
  }
}

extension Location {
  func update(
    completion: MKLocalSearchCompletion,
    mapItem: MKMapItem,
    information: LocationInformation
  ) {
    name = mapItem.name ?? mapItem.placemark.title ?? completion.title
    content = information.description
    //createdDate = .now
    updatedDate = nil
    latitude = mapItem.placemark.coordinate.latitude
    longitude = mapItem.placemark.coordinate.longitude
    postalCode = mapItem.placemark.postalAddress?.postalCode
    country = mapItem.placemark.postalAddress?.country
    state = mapItem.placemark.postalAddress?.state
    city = mapItem.placemark.postalAddress?.city
    subAdministrativeArea = mapItem.placemark.postalAddress?.subAdministrativeArea
    subLocality = mapItem.placemark.postalAddress?.subLocality
    street = mapItem.placemark.postalAddress?.street
    phoneNumber = mapItem.phoneNumber
    url = mapItem.url
    // budget = nil
    tags = information.cuisines.map(\.localizedName).map { .init(item: $0) }
    //photoIDs = []
  }
}
