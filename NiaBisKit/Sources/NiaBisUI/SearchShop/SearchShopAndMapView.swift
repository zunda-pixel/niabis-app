import NiaBisData
import SwiftUI
import SwiftData
import MapKit
import CoreLocationUI
import AsyncLocationKit

@MainActor
struct SearchShopAndMapView: View {
  @State var state: ViewState = .init()

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

  var body: some View {
    Map(position: $state.position)
      .edgesIgnoringSafeArea(.all)
      .overlay(alignment: .topTrailing) {
        locationButton
      }
      .sheet(isPresented: .constant(true)) {
        SearchShopView()
          .interactiveDismissDisabled()
          .presentationDetents([.fraction(0.1), .fraction(0.3), .large])
          .presentationBackgroundInteraction(.enabled)
      }
  }
}

#Preview {
  SearchShopAndMapView()
}
