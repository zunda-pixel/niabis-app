import Contacts
import NiaBisData
import SwiftData
import SwiftUI

struct LocationDetailView: View {
  @Environment(\.openURL) var openURL
  @Environment(\.modelContext) var modelContext
  @Environment(\.dismiss) var dismiss

  @State var isAdded = false

  var location: Location
  let isNew: Bool
  let formatter = CNPostalAddressFormatter()

  var formattedPostalAddress: String {
    let address = location.postalAddress(style: .full)
    let formattedAddress = formatter.string(from: address)
    return formattedAddress
  }

  var subAddress: String {
    let address = location.postalAddress(style: .short)
    let formattedAddress = formatter.string(from: address)
    let onelineAddress = formattedAddress.split(whereSeparator: \.isNewline).joined(separator: " ")
    return onelineAddress
  }

  var scrollPhotosView: some View {
    ScrollView(.horizontal) {
      LazyHStack {
        ForEach(0..<1) { _ in
          Image(systemName: "house")
            .resizable()
            .scaledToFit()
        }

        VStack {
          RoundedRectangle(cornerRadius: 15.0)
            .foregroundStyle(.thickMaterial)
            .aspectRatio(1, contentMode: .fit)
            .overlay {
              Button {

              } label: {
                VStack(spacing: 10) {
                  Image(systemName: "camera.fill")
                    .imageScale(.large)
                  Text("Add Photos")
                    .bold()
                }
              }
            }
          RoundedRectangle(cornerRadius: 15.0)
            .foregroundStyle(.thickMaterial)
            .aspectRatio(1, contentMode: .fit)
            .overlay {
              Button {

              } label: {
                VStack(spacing: 10) {
                  Image(systemName: "photo.on.rectangle")
                    .imageScale(.large)

                  Text("Other Photos")
                    .bold()
                }
              }
            }
        }
      }
    }
    .scrollIndicators(.hidden)
  }

  var body: some View {
    NavigationStack {
      List {
        Section {
          Text(subAddress)
            .lineLimit(1)
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)

          scrollPhotosView
            .frame(height: 200)
            .listRowBackground(Color.clear)
        }

        Section {
          Text(location.content)
            .lineLimit(5)
        } header: {
          Text("Information")
            .sectionHeader()
        }

        Section {
          if let phoneNumber = location.phoneNumber {
            VStack(alignment: .leading, spacing: 7) {
              Text("Phone Number")
                .foregroundStyle(.secondary)
              Button {
              } label: {
                Text(phoneNumber)
                  .lineLimit(1)
              }
            }
          } else {
            Button("Add Phone Number") {

            }
          }

          if let url = location.url,
            let host = url.host()
          {
            VStack(alignment: .leading) {
              Text("Web Site")
                .foregroundStyle(.secondary)

              Button {
                openURL(url)
              } label: {
                Text(host)
                  .lineLimit(1)
              }
            }
          } else {
            Button("Add Web Site") {

            }
          }

          VStack(alignment: .leading) {
            Text("Address")
              .foregroundStyle(.secondary)

            Text(formattedPostalAddress)
          }
        } header: {
          Text("Detail")
            .sectionHeader()
        }
      }
      .navigationTitle(location.name)
      .toolbar {
        #if os(macOS)
          let placement: ToolbarItemPlacement = .navigation
        #else
          let placement: ToolbarItemPlacement = .topBarTrailing
        #endif

        ToolbarItem(placement: placement) {
          if isNew {
            Button {
              isAdded.toggle()
            } label: {
              Label {
                Text(isAdded ? "Delete" : "Add")
              } icon: {
                Image(systemName: isAdded ? "trash.circle.fill" : "plus.circle.fill")
                  .foregroundStyle(.secondary, .thickMaterial)
              }
              .labelStyle(.iconOnly)
            }
            .tint(.secondary)
          } else {
            Menu("Detail", systemImage: "ellipsis.circle") {
              Button(role: .destructive) {
                modelContext.delete(location)
                dismiss()
              } label: {
                Label("Delete", systemImage: "trash")
              }
            }
            .tint(.secondary)
          }
        }
      }
    }
    .onDisappear {
      guard isNew && !isAdded else { return }
      modelContext.delete(location)
    }
  }
}

extension View {
  fileprivate func sectionHeader() -> some View {
    return
      self
      .foregroundStyle(.foreground)
      .bold()
      .textCase(nil)
      .font(.title2)
  }
}

struct Preview: View {
  @Query var locations: [Location]

  var body: some View {
    if let location = locations.first {
      LocationDetailView(location: location, isNew: false)
    }
  }
}

#Preview {
  Preview()
    .previewModelContainer()
}

extension View {
  @MainActor
  func previewModelContainer() -> some View {
    let container = try! ModelContainer(
      for: Location.self,
      configurations: .init(
        isStoredInMemoryOnly: true
      )
    )

    for i in (0..<10) {
      let location = Location(
        id: .init(),
        name: "Shop Name \(i)",
        content: """
          You should always try to avoid long sentences. Below are two examples, as well as some facts about long sentences in general. In 2005, Halton Borough Council put up a notice to tell the public about its plans to move a path from one place to another. Quite astonishingly, the notice was a 630 word sentence, which picked up one of our Golden Bull awards that year. Here is it in full.
          """,
        createdAt: .now,
        updatedAt: nil,
        postalCode: "\(i)\(i)\(i)-\(i)\(i)\(i)",
        country: "country",
        state: "state",
        city: "city",
        subAdministrativeArea: "area",
        subLocality: "locality",
        street: "street",
        phoneNumber: "81+ \(i)\(i)\(i)-\(i)\(i)\(i)-\(i)\(i)\(i)",
        url: .init(string: "https://niabis.com/\(i)"),
        budget: i * 100,
        starCount: i,
        tags: [],
        imageDatas: []
      )

      container.mainContext.insert(location)
    }

    return self.modelContainer(container)
  }
}
