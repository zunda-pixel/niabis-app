import SwiftUI
import Contacts
import NiaBisData
import SwiftData
import MapKit

enum LocationOrder: String, CaseIterable, Identifiable {
  case createdDate = "Created Date"
  case name = "Name"
  case address = "Address"
  
  var id: Self { self }
}

struct LocationsView: View {
  @Query var locations: [Location]
  private let addressFormatter = CNPostalAddressFormatter()
  @Binding var selectedLocation: Location?
  @Environment(\.modelContext) var modelContext
  @State var isPresentedSettings = false
  @State var isPresentedSearchLocation = false
  @State var query = ""
  @State var order: LocationOrder = .createdDate
  
  var filteredLocations: [Location] {
    guard !query.isEmpty else {
      return locations
    }
    
    return locations.filter { $0.name.contains(query) }
  }
  
  var sortedLocations: [Location] {
    filteredLocations.sorted {
      switch order {
      case .createdDate: return $0.createdDate < $1.createdDate
      case .name: return $0.name.localizedStandardCompare($1.name) == .orderedAscending
      case .address:
        let address0 = addressFormatter.string(from: $0.postalAddress(style: .full))
        let address1 = addressFormatter.string(from: $1.postalAddress(style: .full))
        return address0.localizedStandardCompare(address1) == .orderedAscending
      }
    }
  }
  
  var body: some View {
    List {
      Section {
        TextField("Search Location", text: $query, axis: .horizontal)
      }
      Section {
        HStack {
          Spacer()
          Picker("Order", selection: $order) {
            ForEach(LocationOrder.allCases) { order in
              Text(order.rawValue)
                .lineLimit(1)
                .tag(order)
            }
          }
          .labelsHidden()
          
          Button {
            isPresentedSearchLocation.toggle()
          } label: {
            Image(systemName: "plus.circle")
              .imageScale(.large)
          }
          Button {
            isPresentedSettings.toggle()
          } label: {
            Image(systemName: "gear.circle")
              .imageScale(.large)
          }
        }
        .listRowBackground(Color.clear)
        .buttonStyle(.bordered)
      }
      Section {
        ForEach(sortedLocations) { location in
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
