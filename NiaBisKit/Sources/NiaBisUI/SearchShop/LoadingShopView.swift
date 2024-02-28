import NiaBisData
import SwiftUI
import MapKit

struct LoadingShopView: View {
  let completion: MKLocalSearchCompletion
  @State var shop: Shop?
  @Environment(ErrorController.self) var errorController
  @Environment(\.modelContext) var modelContext
  
  func search() async {
    let request = MKLocalSearch.Request(completion: completion)
    let search = MKLocalSearch(request: request)
    do {
      guard let mapItem = try await search.start().mapItems.first else { throw FetchError.notFount }
      let shop = Shop(completion: completion, mapItem: mapItem)
      modelContext.insert(shop)
      self.shop = shop
    } catch {
      self.errorController.error = error
    }
  }
  
  var body: some View {
    if let shop {
      ShopDetailView(shop: shop)
    } else {
      VStack {
        Text(completion.title)
        Text(completion.subtitle)
      }
      .task {
        await search()
      }
    }
  }
}

private extension Shop {
  convenience init(completion: MKLocalSearchCompletion, mapItem: MKMapItem) {
    self.init(
      id: .init(),
      name: mapItem.name ?? mapItem.placemark.title ?? completion.title,
      content: "",
      createdAt: .now,
      updatedAt: nil,
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

