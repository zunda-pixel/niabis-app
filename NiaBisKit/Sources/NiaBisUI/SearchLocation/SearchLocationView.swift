import Contacts
import MapKit
import NiaBisData
import SwiftData
import SwiftUI

struct SearchLocationView: View {
  @State var viewState = ViewState()
  @FocusState var focusedSearchField: Bool?
  @Query var locations: [Location]
  private let addressFormatter = CNPostalAddressFormatter()
  @Binding var selectedLocation: Location?

  var body: some View {
    List {
      Section {
        HStack {
          TextField("Search Location", text: $viewState.query, axis: .horizontal)
            .focused($focusedSearchField, equals: true)

          Button(role: .cancel) {
            viewState.query = ""
            focusedSearchField = nil
          } label: {
            Text("Cancel")
          }
        }
      }

      if viewState.query.isEmpty && focusedSearchField != true {
        ForEach(locations) { location in
          Label {
            VStack(alignment: .leading) {
              Text(location.name)
                .lineLimit(1)
              let address = location.postalAddress(style: .medium)
              let formattedAddress = addressFormatter.string(from: address).split(
                whereSeparator: \.isNewline
              ).joined(separator: " ")
              Text(formattedAddress)
                .foregroundStyle(.secondary)
                .font(.callout)
                .lineLimit(1)
            }
          } icon: {
            Image(systemName: "fork.knife")
          }
          .containerShape(.rect)
          .contentShape(.rect)
          .onTapGesture {
            selectedLocation = location
          }
        }
      } else {
        ForEach(viewState.results) { completion in
          Label {
            VStack(alignment: .leading) {
              Text(completion.title)
                .lineLimit(1)

              Text(completion.subtitle)
                .foregroundStyle(.secondary)
                .font(.callout)
                .lineLimit(1)
            }
          } icon: {
            Image(systemName: "fork.knife")
          }
          .containerShape(.rect)
          .contentShape(.rect)
          .onTapGesture {
            viewState.selectedCompletion = completion
          }
        }
      }
    }
    .sheet(item: $viewState.selectedCompletion) { completion in
      LoadingShopView(completion: completion)
        .presentationDragIndicator(.visible)
    }
    .sheet(item: $selectedLocation) { location in
      LocationDetailView(location: location, isNew: false)
        .presentationBackgroundInteraction(.enabled)
        .presentationDragIndicator(.visible)
        .presentationDetents(Set(Constants.presentationDetents))
    }
  }
}

extension MKLocalSearchCompletion: Identifiable {
  public var id: String { self.title + self.subtitle }
}

#Preview {
  SearchLocationView(selectedLocation: .constant(nil))
    .previewModelContainer()
    .environment(ErrorController())
}
