import SwiftUI
import Contacts
import NiaBisData
import SwiftData

struct ShopDetailView: View {
  @Environment(\.openURL) var openURL
  
  var shop: Shop
  
  var postalAddress: CNMutablePostalAddress {
    let postalAddress = CNMutablePostalAddress()
    shop.postalCode.map { postalAddress.postalCode = $0 }
    shop.state.map { postalAddress.state = $0 }
    shop.city.map { postalAddress.city = $0 }
    shop.subAdministrativeArea.map { postalAddress.subAdministrativeArea = $0 }
    shop.subLocality.map { postalAddress.subLocality = $0 }
    shop.street.map { postalAddress.street = $0 }
    
    return postalAddress
  }
  
  var formattedPostalAddress: String {
    let formatter = CNPostalAddressFormatter()
    let formattedAddress = formatter.string(from: postalAddress)
    return formattedAddress
  }
  
  var subAddress: String {
    var postalAddress: CNPostalAddress {
      let postalAddress = CNMutablePostalAddress()
      shop.state.map { postalAddress.state = $0 }
      shop.city.map { postalAddress.city = $0 }
      return postalAddress
    }
    
    let formatter = CNPostalAddressFormatter()
    let formattedAddress = formatter.string(from: postalAddress)
    
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
    List {
      Section {
        VStack(alignment: .leading) {
          HStack(alignment: .center) {
            Text(shop.name)
              .bold()
              .font(.title)
              .lineLimit(1)
              .frame(maxWidth: .infinity, alignment: .leading)

            ShareLink(item: URL(string: "https://google.com")!) {
              Image(systemName: "square.and.arrow.up.circle.fill")
                .bold()
                .font(.largeTitle)
                .tint(.secondary)
                .foregroundStyle(.secondary, .thickMaterial)
            }
          }

          Text(subAddress)
            .lineLimit(1)
        }
          .listRowBackground(Color.clear)
          .listRowSeparator(.hidden)

        scrollPhotosView
          .frame(height: 250)
          .listRowBackground(Color.clear)
      }
      
      Section {
        Text(shop.content)
          .lineLimit(5)
      } header: {
        Text("Information")
          .sectionHeader()
      }
      
      Section {
        if let phoneNumber = shop.phoneNumber {
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
        
        if let url = shop.url,
           let host = url.host() {
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
  }
}

private extension View {
  func sectionHeader() -> some View {
    return self
      .foregroundStyle(.foreground)
      .bold()
      .textCase(nil)
      .font(.title2)
  }
}


struct Preview: View {
  @Query var shops: [Shop]
  
  var body: some View {
    ShopDetailView(shop: shops.first!)
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
      for: Shop.self,
      configurations: .init(
        isStoredInMemoryOnly: true
      )
    )
    
    for i in (0..<10) {
      let shop = Shop(
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
      
      container.mainContext.insert(shop)
    }
    
    return self.modelContainer(container)
  }
}
