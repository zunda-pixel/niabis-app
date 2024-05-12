import Contacts
import NiaBisClient
import NiaBisData
import SwiftData
import SwiftUI
import NukeUI
import PhotosUI
import Algorithms
import SwiftUIIntrospect
import SystemNotification

struct LocationDetailView: View {
  @Environment(\.openURL) var openURL
  @Environment(\.modelContext) var modelContext
  @Environment(\.dismiss) var dismiss
  @Environment(\.locale) var locale

  @StateObject var toast = SystemNotificationContext()
  @State var editMode: EditMode = .inactive
  @State var photos: [PhotosPickerItem] = []
  @State var isLoadingPhotos = false
  @State var textFieldURLString = ""
  @State var newTag = ""
  @State var isAdded = false

  var location: Location
  let isNew: Bool
  let imageURLs: [URL]

  var formattedPostalAddress: String {
    let address = location.postalAddress(style: .full)
    let formatter = CNPostalAddressFormatter()
    let formattedAddress = formatter.string(from: address)
    return formattedAddress
  }
  
  func loadPhotos(photos: [PhotosPickerItem]) async {
    isLoadingPhotos = true
    
    defer {
      isLoadingPhotos = false
    }
    
    var photoDatas: [Data] = []
    
    do {
      for photo in photos {
        let data = try await photo.loadTransferable(type: Data.self)!
        photoDatas.append(data)
      }
    } catch {
      toast.presentMessage(
        .error(
          text: "Failed to load Photos"
        )
      )
    }
    
    do {
      let client = NiaBisClient(
        token: SecretConstants.niabisAPIToken,
        locale: locale
      )
      let imageIDs = try await client.uploadImages(images: photoDatas.map { .data($0) })
      location.photoIDs.append(contentsOf: imageIDs.map { .init(item: $0) })
    } catch {
      toast.presentMessage(
        .error(
          text: "Failed to upload Photos"
        )
      )
    }
  }
  
  let currencyFormetter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    return formatter
  }()
  
  func openMap(name: String, address: String, coordinate: CLLocationCoordinate2D?) {
    var urlComponents = URLComponents(string: "https://maps.apple.com")!
    urlComponents.queryItems = [
      .init(name: "q", value: name),
      .init(name: "address", value: address),
    ]
    openURL(urlComponents.url!)
  }

  func imageView(url: URL) -> some View {
    LazyImage(url: url) { state in
      switch state.result {
      case .success(let result):
        #if os(macOS)
        Image(nsImage: result.image)
          .resizable()
        #else
        Image(uiImage: result.image)
          .resizable()
          .scaledToFit()
          .clipShape(.rect(cornerRadius: 10))
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
  
  @MainActor
  var scrollPhotosView: some View {
    ScrollView(.horizontal) {
      LazyHStack {
        if location.photoIDs.isEmpty {
          ForEach(imageURLs, id: \.self) { imageURL in
            imageView(url: imageURL)
          }
        }
        
        ForEach(location.photoIDs) { photoID in
          let url = URL(string: "https://imagedelivery.net/\(SecretConstants.cloudflareImagesAccountHashId)/\(photoID.item)/public")!
          imageView(url: url)
        }

        VStack {
          RoundedRectangle(cornerRadius: 15.0)
            .foregroundStyle(Color(uiColor: .systemGray5))
            .aspectRatio(1, contentMode: .fit)
            .overlay {
              Button {

              } label: {
                VStack(spacing: 10) {
                  Image(systemName: "camera.fill")
                    .imageScale(.large)
                  Text("Add Photos", bundle: .module)
                    .bold()
                }
              }
            }
          RoundedRectangle(cornerRadius: 15.0)
            .foregroundStyle(Color(uiColor: .systemGray5))
            .aspectRatio(1, contentMode: .fit)
            .overlay {
              Button {

              } label: {
                VStack(spacing: 10) {
                  Image(systemName: "photo.on.rectangle")
                    .imageScale(.large)

                  Text("Other Photos", bundle: .module)
                    .bold()
                }
              }
            }
        }
      }
    }
    .scrollIndicators(.hidden)
  }
  
  @ViewBuilder
  var actionsView: some View {
    HStack {
      if !formattedPostalAddress.isEmpty {
        Button {
          openMap(
            name: location.name,
            address: formattedPostalAddress,
            coordinate: location.coordinate
          )
        } label: {
          VStack {
            Image(systemName: "tram")
            Text("Way to", bundle: .module)
              .lineLimit(1)
          }
          .frame(maxWidth: .infinity)
        }
      }
      if let phoneNumber = location.phoneNumber {
        Button {
          let url = URL(string: "tel://\(phoneNumber)")!
          openURL(url)
        } label: {
          VStack {
            Text("\(Image(systemName: "phone.fill"))")
            Text("Call", bundle: .module)
              .lineLimit(1)
          }
          .frame(maxWidth: .infinity)
        }
      }
      if let url = location.url {
        Button {
          openURL(url)
        } label: {
          VStack {
            Text("\(Image(systemName: "safari.fill"))")
            Text("Web Site", bundle: .module)
              .lineLimit(1)
          }
          .frame(maxWidth: .infinity)
        }
      }
    }
    .buttonStyle(.bordered)
  }
  
  @ViewBuilder
  var detailSection: some View {
    Section(String(localized: "Detail", bundle: .module)) {
      if let phoneNumber = location.phoneNumber {
        VStack(alignment: .leading, spacing: 7) {
          Text("Phone Number", bundle: .module)
            .foregroundStyle(.secondary)
          
          if editMode.isEditing {
            TextField(
              String(localized: "Phone Number", bundle: .module),
              text: .init(get: { phoneNumber }, set: { location.phoneNumber = $0 })
            )
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
        Button {
          if let phoneNumber = UIPasteboard.general.string {
            location.phoneNumber = phoneNumber
            return
          } else {
            location.phoneNumber = ""
          }
        } label: {
          Text("Add Phone Number", bundle: .module)
        }
      }

      EditableURLView(
        url: .init(get: { location.url }, set: { location.url = $0 }),
        editMode: $editMode
      )

      if !editMode.isEditing {
        VStack(alignment: .leading) {
          Text("Address", bundle: .module)
            .foregroundStyle(.secondary)
          
          Text(formattedPostalAddress)
        }
      }
      
      if editMode.isEditing {
        TextField(
          String(localized: "Budget", bundle: .module),
          value: .init(get: { location.budget ?? 0 }, set: { location.budget = $0 }),
          formatter: currencyFormetter
        )
      }
    }
  }
  
  @ViewBuilder
  var editableAddressSection: some View {
    Section(String(localized: "Address", bundle: .module)) {
      TextField(
        String(localized: "Postal Code", bundle: .module),
        text: .init(get: { location.postalCode ?? ""}, set: { location.postalCode = $0 })
      )
      TextField(
        String(localized: "Country", bundle: .module),
        text: .init(get: { location.country ?? ""}, set: { location.country = $0 })
      )
      TextField(
        String(localized: "State", bundle: .module),
        text: .init(get: { location.state ?? ""}, set: { location.state = $0 })
      )
      TextField(
        String(localized: "Sub Administrative Area", bundle: .module),
        text: .init(get: { location.subAdministrativeArea ?? ""}, set: { location.subAdministrativeArea = $0 })
      )
      TextField(
        String(localized: "City", bundle: .module),
        text: .init(get: { location.city ?? ""}, set: { location.city = $0 })
      )
      TextField(
        String(localized: "Sub Locality", bundle: .module),
        text: .init(get: { location.subLocality ?? ""}, set: { location.subLocality = $0 })
      )
      TextField(
        String(localized: "Street", bundle: .module),
        text: .init(get: { location.street ?? ""}, set: { location.street = $0 })
      )
    }
  }
  
  @ViewBuilder
  var budgetAndTagsView: some View {
    VStack(spacing: 0) {
      Divider()
      HStack {
        if let budget = location.budget {
          VStack(alignment: .leading) {
            Text("Budget", bundle: .module)
              .foregroundStyle(.secondary)
              .bold()
            
            Text(currencyFormetter.string(from: budget as NSNumber)!)
              .padding(.vertical, 2.5)
          }
        }
        
        if location.budget != nil && !location.tags.isEmpty {
          Divider()
        }
        if !location.tags.isEmpty {
          VStack(alignment: .leading) {
            Text("Tags", bundle: .module)
              .foregroundStyle(.secondary)
              .bold()
            scrollTags
          }
        }
      }
      Divider()
    }
  }
  
  var scrollTags: some View {
    ScrollView(.horizontal) {
      HStack(spacing: 0) {
        ForEach(location.tags) { tag in
          HStack {
            Text(tag.item)
              .bold()
              .foregroundStyle(.secondary)
              .padding(.horizontal, 6)
              .background {
                RoundedRectangle(cornerRadius: 20)
                  .foregroundStyle(Color.orange.opacity(0.1))
              }
              .overlay(
                RoundedRectangle(cornerRadius: 20)
                  .stroke(Color.orange, lineWidth: 2)
              )
              .buttonStyle(.bordered)
              .padding(.horizontal, 3)
              .padding(.vertical, 2.5)
          }
        }
      }
    }
  }

  var body: some View {
    NavigationStack {
      List {
        Section {
          VStack {
            if isNew {
              HStack {
                Button (role: isAdded ? .destructive : nil) {
                  isAdded.toggle()
                } label: {
                  VStack {
                    Image(systemName: isAdded ? "trash" : "plus")
                    Text(isAdded ? "Delete" : "Add", bundle: .module)
                  }
                  .frame(maxWidth: .infinity)
                }
                Button (role: isAdded ? .destructive : nil) {
                  editMode = editMode == .active ? .inactive : .active
                } label: {
                  VStack {
                    Image(systemName: isAdded ? "checkmark" : "pencil")
                    Text(editMode.isEditing ? "Done" : "Edit", bundle: .module)
                  }
                  .frame(maxWidth: .infinity)
                }
              }
              .buttonStyle(.bordered)
            }
            
            if !formattedPostalAddress.isEmpty || location.phoneNumber != nil || location.url != nil {
              actionsView
            }
            
            if location.budget != nil || !location.tags.isEmpty {
              budgetAndTagsView
            }
            
            if !location.photoIDs.isEmpty || !imageURLs.isEmpty {
              scrollPhotosView
                .frame(height: 200)
            }
          }
          .listRowBackground(Color.clear)
        }

        Section(String(localized: "Information", bundle: .module)) {
          if editMode.isEditing {
            TextField(
              String(localized: "Input Information", bundle: .module),
              text: .init(get: { location.content }, set: { location.content = $0 }),
              axis: .vertical
            )
          } else {
            Text(location.content.isEmpty ? String(localized: "Empty Infomation", bundle: .module) : location.content)
              .lineLimit(5)
          }
        }
        .headerProminence(.increased)

        detailSection
          .headerProminence(.increased)
        
        if editMode.isEditing {
          Section(String(localized: "New Tag", bundle: .module)) {
            HStack {
              TextField(
                String(localized: "Add New Tag", bundle: .module),
                text: $newTag
              )
              Button {
                guard !newTag.isEmpty && !location.tags.map(\.item).contains(newTag) else { return }
                location.tags.append(.init(item: newTag))
                newTag = ""
              } label: {
                Text("Add", bundle: .module)
              }
            }
          }
          .headerProminence(.increased)

          if !location.tags.isEmpty {
            Section(String(localized: "Tags", bundle: .module)) {
              ForEach(location.tags) { tag in
                Text(tag.item)
                  .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                      location.tags.removeAll { $0.id == tag.id }
                    } label: {
                      Label(
                        String(localized: "Delete", bundle: .module),
                        systemImage: "trash"
                      )
                    }
                  }
              }
            }
            .headerProminence(.increased)
          }
          
          editableAddressSection
            .headerProminence(.increased)
        }
        
        if location.photoIDs.isEmpty {
          Section {
            PhotosPicker(
              String(localized: "Add Photos", bundle: .module),
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
      // TODO if SwiftUI supports custom headerTopPadding, remove this View Motifider
      .introspect(.list, on: .iOS(.v17)) { list in
        var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        configuration.headerMode = .supplementary
        configuration.headerTopPadding = 0
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        list.collectionViewLayout = layout
      }
      .listSectionSpacing(.custom(0))
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Text(location.name)
            .font(.title.bold())
        }

        #if os(macOS)
        let placement: ToolbarItemPlacement = .navigation
        #else
        let placement: ToolbarItemPlacement = .topBarTrailing
        #endif
        if !isNew && !self.editMode.isEditing {
          ToolbarItem(placement: placement) {
            Menu(
              String(localized: "Detail", bundle: .module),
              systemImage: "ellipsis.circle"
            ) {
              Button(role: .destructive) {
                modelContext.delete(location)
                dismiss()
              } label: {
                Label(String(localized: "Delete", bundle: .module), systemImage: "trash")
              }
              
              Button {
                editMode = editMode == .active ? .inactive : .active
              } label: {
                Label(
                  String(localized: editMode.isEditing ? "Done" : "Edit", bundle: .module),
                  systemImage: "pencil.circle"
                )
              }
            }
            .tint(.secondary)
          }
        }

        if !isNew && editMode.isEditing {
          ToolbarItem(placement: placement) {
            Button {
              editMode = .inactive
            } label: {
              Text("Done", bundle: .module)
            }
            .tint(.secondary)
          }
        }
        
        ToolbarItem(placement: placement) {
          Button {
            dismiss()
          } label: {
            Image(systemName: "xmark")
              .bold()
              .padding(6)
              .background(Color(uiColor: .systemGray5))
              .clipShape(.circle)
          }
          .tint(.secondary)
        }
      }
      .onDisappear {
        guard isNew && !isAdded else { return }
        modelContext.delete(location)
      }
    }
    .navigationTitle(location.name)
    .systemNotification(toast)
    .systemNotificationConfiguration(.standardToast)
  }
}

private struct Preview: View {
  @Query var locations: [Location]

  var body: some View {
    if let location = locations.first {
      LocationDetailView(location: location, isNew: false, imageURLs: [])
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

    for i in (0..<10).shuffled() {
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
        url: .init(string: "https://niabis.com/\(i)"),
        budget: i * 100 + 1238,
        tags: [
          .init(item: "wine"),
          .init(item: "ramen"),
          .init(item: "shrimp"),
        ],
        photoIDs: [
          .init(item: .init()),
        ]
      )

      container.mainContext.insert(location)
    }

    return self.modelContainer(container)
  }
}
