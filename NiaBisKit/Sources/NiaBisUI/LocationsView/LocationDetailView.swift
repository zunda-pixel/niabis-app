import Contacts
import NiaBisData
import SwiftData
import SwiftUI
import NukeUI
import PhotosUI

struct LocationDetailView: View {
  @Environment(\.openURL) var openURL
  @Environment(\.modelContext) var modelContext
  @Environment(\.dismiss) var dismiss

  @State var editMode: EditMode = .inactive
  @State var photos: [PhotosPickerItem] = []
  @State var isLoadingPhotos = false
  @State var textFieldURLString = ""
  
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
  
  func loadPhotos(photos: [PhotosPickerItem]) async {
    isLoadingPhotos = true
    
    defer {
      isLoadingPhotos = false
    }
    
    var photoDatas: [Data] = []
    
    for photo in photos {
      do {
        let data = try await photo.loadTransferable(type: Data.self)!
        photoDatas.append(data)
      } catch {
        print(error)
      }
    }
    
    location.photoDatas.append(contentsOf: photoDatas)
  }

  @MainActor
  var scrollPhotosView: some View {
    ScrollView(.horizontal) {
      LazyHStack {
        ForEach(location.photoURLs, id: \.absoluteString) { photoURL in
          LazyImage(url: photoURL) { state in
            switch state.result {
            case .success(let result):
              #if os(macOS)
              Image(nsImage: result.image)
                .resizable()
              #else
              Image(uiImage: result.image)
                .resizable()
                .scaledToFit()
              #endif
            case .failure(_):
              Image(systemName: "photo")
                .resizable()
                .scaledToFit()
                .overlay {
                  Image(systemName: "xmark")
                    .resizable()
                    .foregroundStyle(.red)
                }
            case .none:
              ProgressView(
                value: state.progress.fraction,
                total: Float(state.progress.total)
              ) {
                Image(systemName: "photo")
                  .resizable()
                  .scaledToFit()
              }
            }
          }
        }
        
        ForEach(location.photoDatas, id: \.self) { photoData in
          Image(uiImage: .init(data: photoData)!)
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

          if !location.photoURLs.isEmpty || !location.photoDatas.isEmpty {
            scrollPhotosView
              .frame(height: 200)
              .listRowBackground(Color.clear)
          }
        }

        Section("Information") {
          if editMode.isEditing {
            TextField(
              "Input Information",
              text: .init(get: { location.content }, set: { location.content = $0 }),
              axis: .vertical
            )
          } else {
            Text(location.content.isEmpty ? "Empty Infomation" : location.content)
              .lineLimit(5)
          }
        }
        .headerProminence(.increased)

        Section("Detail") {
          if let phoneNumber = location.phoneNumber {
            VStack(alignment: .leading, spacing: 7) {
              Text("Phone Number")
                .foregroundStyle(.secondary)
              
              if editMode.isEditing {
                TextField("Phone Number", text: .init(get: { phoneNumber }, set: { location.phoneNumber = $0 }))
              } else {
                Button {
                  let url = URL(string: "tel://\(phoneNumber)")!
                  openURL(url)
                } label: {
                  Text(phoneNumber)
                    .lineLimit(1)
                }
              }
            }
          } else {
            Button("Add Phone Number") {
              if let phoneNumber = UIPasteboard.general.string {
                location.phoneNumber = phoneNumber
                return
              } else {
                location.phoneNumber = ""
              }
            }
          }

          EditableURLView(
            url: .init(get: { location.url }, set: { location.url = $0 }),
            editMode: $editMode
          )

          if !editMode.isEditing {
            VStack(alignment: .leading) {
              Text("Address")
                .foregroundStyle(.secondary)
              
              Text(formattedPostalAddress)
            }
          }
        }
        .headerProminence(.increased)
        
        if editMode.isEditing {
          Section("Address") {
            TextField("Postal Code", text: .init(get: { location.postalCode ?? ""}, set: { location.postalCode = $0 }))

            TextField("Country", text: .init(get: { location.country ?? ""}, set: { location.country = $0 }))
            TextField("State", text: .init(get: { location.state ?? ""}, set: { location.state = $0 }))

            TextField("Sub Administrative Area", text: .init(get: { location.subAdministrativeArea ?? ""}, set: { location.subAdministrativeArea = $0 }))
            TextField("City", text: .init(get: { location.city ?? ""}, set: { location.city = $0 }))
            TextField("Sub Locality", text: .init(get: { location.subLocality ?? ""}, set: { location.subLocality = $0 }))
            TextField("Street", text: .init(get: { location.street ?? ""}, set: { location.street = $0 }))
          }
          .headerProminence(.increased)
        }
        
        if location.photoURLs.isEmpty {
          Section {
            PhotosPicker(
              "Add Photos",
              selection: $photos,
              maxSelectionCount: 0,
              selectionBehavior: .ordered,
              matching: .images,
              preferredItemEncoding: .automatic
            )
            .disabled(isLoadingPhotos)
            .onChange(of: photos) { _, newValue in
              Task {
                await loadPhotos(photos: newValue)
              }
            }
          }
        }
      }
      .navigationTitle(location.name)
      .toolbar {
        if isNew {
          #if os(macOS)
          let placement: ToolbarItemPlacement = .navigation
          #else
          let placement: ToolbarItemPlacement = .topBarLeading
          #endif
          
          ToolbarItem(placement: placement) {
            Button("Cancel", role: .cancel) {
              modelContext.delete(location)
              dismiss()
            }
          }
        }
        
        #if os(macOS)
        let placement: ToolbarItemPlacement = .navigation
        #else
        let placement: ToolbarItemPlacement = .topBarTrailing
        #endif

        ToolbarItem(placement: placement) {
          if self.editMode.isEditing {
            Button {
              editMode = editMode == .active ? .inactive : .active
            } label: {
              Text(editMode.isEditing ? "Done" : "Edit")
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
              
              Button {
                editMode = editMode == .active ? .inactive : .active
              } label: {
                Label(editMode.isEditing ? "Done" : "Edit", systemImage: "pencil.circle")
              }
            }
            .tint(.secondary)
          }
        }
      }
    }
  }
}

private struct Preview: View {
  @Query var locations: [Location]

  var body: some View {
    if let location = locations.first {
      LocationDetailView(location: location, isNew: true)
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
        createdDate: .now,
        updatedDate: nil,
        postalCode: "\(i)\(i)\(i)-\(i)\(i)\(i)",
        country: "country",
        state: "state",
        city: "city",
        subAdministrativeArea: "area",
        subLocality: "locality",
        street: "street",
        phoneNumber: "81+ \(i)\(i)\(i)-\(i)\(i)\(i)-\(i)\(i)\(i)",
        url: nil,//.init(string: "https://niabis.com/\(i)"),
        budget: i * 100,
        starCount: i,
        tags: [],
        photoURLs: [
          .init(string: "https://ebimaru.com/img/home/keyvisual/Ph_1_PC.jpg?220511")!
        ],
        photoDatas: []
      )

      container.mainContext.insert(location)
    }

    return self.modelContainer(container)
  }
}
