import SwiftUI
import MapKit
import NiaBisData
import SwiftData
import Contacts

struct SearchLocationView: View {
  @State var viewState = SearchLocationView.ViewState()
  @FocusState var focusedSearchField: Bool?
  @Query var locations: [Location]
  private let addressFormatter = CNPostalAddressFormatter()

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
      
      if viewState.query.isEmpty &&  focusedSearchField != true {
        ForEach(locations) { location in
          Label {
            VStack(alignment: .leading) {
              Text(location.name)
                .lineLimit(1)
              let address = location.postalAddress(style: .medium)
              let formattedAddress = addressFormatter.string(from: address).split(whereSeparator: \.isNewline).joined(separator: " ")
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
            viewState.selectedLocation = location
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
    .sheet(item: $viewState.selectedLocation) { location in
      LocationDetailView(location: location, isNew: false)
        .presentationDragIndicator(.visible)
    }
  }
}

extension MKLocalSearchCompletion: Identifiable {
  public var id: String { self.title + self.subtitle }
}

#Preview {
  SearchLocationView()
  .previewModelContainer()
  .environment(ErrorController())
}
