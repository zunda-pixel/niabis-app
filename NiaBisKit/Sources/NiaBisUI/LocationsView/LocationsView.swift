import SwiftUI
import Contacts
import NiaBisData
import SwiftData
import MapKit

enum LocationOrder: String, CaseIterable, Identifiable {
  case createdDate = "CreatedDate"
  case name = "Name"
  case address = "Address"
  
  var id: Self { self }
}

struct LocationsView: View {
  @FocusState var focusTextField: Bool?
  @Query var locations: [Location]
  private let addressFormatter = CNPostalAddressFormatter()
  @Binding var selectedLocation: Location?
  @Environment(\.modelContext) var modelContext
  @State var isPresentedSettings = false
  @State var isPresentedSearchLocation = false
  @State var query = ""
  @State var order: LocationOrder = .createdDate
  @State var selectedLocationPresentationDetent: PresentationDetent = Constants.presentationDetents[0]
  
  var filteredLocations: [Location] {
    guard !query.isEmpty else {
      return locations
    }
    
    return locations.filter {
      $0.name.contains(query)
      || addressFormatter.string(from: $0.postalAddress(style: .full)).contains(query)
    }
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
        HStack {
          TextField(
            String(localized: "Search Location", bundle: .module),
            text: $query, axis: .horizontal
          )
          .focused($focusTextField, equals: true)
          
          if focusTextField == true {
            Button {
              query = ""
              focusTextField = nil
            } label: {
              Text("Cancel", bundle: .module)
            }
          }
        }
      }
      Section {
        HStack {
          Spacer()
          Picker(
            String(localized: "Order", bundle: .module),
            selection: $order
          ) {
            ForEach(LocationOrder.allCases) { order in
              Text(String(localized: String.LocalizationValue(order.rawValue), bundle: .module))
                .tag(order)
            }
          }
          .labelsHidden()
          
          Button {
            isPresentedSearchLocation.toggle()
          } label: {
            Text("\(Image(systemName: "plus"))")
          }
          Button {
            isPresentedSettings.toggle()
          } label: {
            Text("\(Image(systemName: "gear"))")
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
            selectedLocationPresentationDetent = Constants.presentationDetents[0]
            selectedLocation = location
          }
          .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
              modelContext.delete(location)
            } label: {
              Label(
                String(localized: "Delete", bundle: .module),
                systemImage: "trash"
              )
            }
          }
        }
      }
    }
    #if !os(macOS)
    .listSectionSpacing(.compact)
    .sheet(item: $selectedLocation) { location in
      LocationDetailView(location: location, isNew: false, imageURLs: [])
        .presentationBackgroundInteraction(.enabled)
        .presentationDragIndicator(.visible)
        .presentationDetents(Set(Constants.presentationDetents), selection: $selectedLocationPresentationDetent)
    }
    #endif
    .sheet(isPresented: $isPresentedSettings) {
      SettingsView()
    }
    .sheet(isPresented: $isPresentedSearchLocation) {
      SearchLocationView()
        .presentationDetents(Set(Constants.presentationDetents), selection: $selectedLocationPresentationDetent)
    }
  }
}

extension MKLocalSearchCompletion: @retroactive Identifiable {
  public var id: String { self.title + self.subtitle }
}

#Preview {
  LocationsView(selectedLocation: .constant(nil))
    .previewModelContainer()
}
