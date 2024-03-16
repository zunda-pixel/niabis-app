import SwiftUI
import Contacts
import NiaBisData
import SwiftData
import MapKit

struct LocationsView: View {
  @FocusState var focusedSearchField: Bool?
  @Query var locations: [Location]
  private let addressFormatter = CNPostalAddressFormatter()
  @Binding var selectedLocation: Location?
  @Environment(\.modelContext) var modelContext
  @State var isPresentedSettings = false
  @State var isPresentedSearchLocation = false
  @State var query = ""
  
  var filteredLocations: [Location] {
    guard !query.isEmpty else {
      return locations
    }
    
    return locations.filter { $0.name.contains(query) }
  }
  
  var body: some View {
    List {
      Section {
        TextField("Search Location", text: $query, axis: .horizontal)
          .focused($focusedSearchField, equals: true)
      }
      Section {
        HStack {
          Spacer()
          Button {
            isPresentedSearchLocation.toggle()
          } label: {
            Image(systemName: "plus.circle")
          }
          Button {
            isPresentedSettings.toggle()
          } label: {
            Image(systemName: "gear.circle")
          }
          Spacer()
        }
        .listRowBackground(Color.clear)
        .buttonStyle(.plain)

      }
      Section {
        ForEach(filteredLocations) { location in
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
          .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
              modelContext.delete(location)
            } label: {
              Label("Delete", systemImage: "trash")
            }
          }
        }
      }
    }
    .listSectionSpacing(.compact)
    .sheet(item: $selectedLocation) { location in
      LocationDetailView(location: location, isNew: false)
        .presentationBackgroundInteraction(.enabled)
        .presentationDragIndicator(.visible)
        .presentationDetents(Set(Constants.presentationDetents))
    }
    .sheet(isPresented: $isPresentedSettings) {
      SettingsView()
    }
    .sheet(isPresented: $isPresentedSearchLocation) {
      SearchLocationView()
    }
  }
}

extension MKLocalSearchCompletion: Identifiable {
  public var id: String { self.title + self.subtitle }
}

#Preview {
  LocationsView(selectedLocation: .constant(nil))
    .previewModelContainer()
    .environment(ErrorController())
}
