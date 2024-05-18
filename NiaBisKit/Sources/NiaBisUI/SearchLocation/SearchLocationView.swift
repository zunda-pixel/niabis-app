import Contacts
import MapKit
import NiaBisData
import SwiftData
import SwiftUI

struct SearchLocationView: View {
  @State var viewState = ViewState()
  @Environment(\.modelContext) var modelContext
  @Environment(\.dismiss) var dismiss
  @State var isPresentedSearchKeyboard = false
  
  var body: some View {
    NavigationStack {
      List {
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
            let location = Location(
              id: .init(),
              name: completion.title,
              content: completion.subtitle,
              createdDate: .now,
              tags: [],
              photoIDs: []
            )
            modelContext.insert(location)
            isPresentedSearchKeyboard = false
            viewState.selectedItem = .init(item: .init(completion: completion, location: location))
          }
        }
      }
      .sheet(item: $viewState.selectedItem) { item in
        LoadingShopView(completion: item.item.completion, location: item.item.location)
          .presentationDragIndicator(.visible)
      }
      .searchable(
        text: $viewState.query,
        isPresented: $isPresentedSearchKeyboard,
        prompt: Text("Search Location", bundle: .module)
      )
      .navigationTitle(Text("Search New Location", bundle: .module))
      .toolbar {
        #if os(macOS)
        let placement: ToolbarItemPlacement = .navigation
        #else
        let placement: ToolbarItemPlacement = .topBarTrailing
        #endif

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
    }
  }
}

#Preview {
  NavigationStack {
    SearchLocationView()
  }
  .previewModelContainer()
}
