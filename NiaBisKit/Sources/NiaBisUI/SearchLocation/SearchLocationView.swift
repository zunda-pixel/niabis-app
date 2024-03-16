import Contacts
import MapKit
import NiaBisData
import SwiftData
import SwiftUI

struct SearchLocationView: View {
  @State var viewState = ViewState()

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
            viewState.selectedCompletion = completion
          }
        }
      }
      .sheet(item: $viewState.selectedCompletion) { completion in
        LoadingShopView(completion: completion)
          .presentationDragIndicator(.visible)
      }
      .searchable(text: $viewState.query, prompt: "Search Location")
      .navigationTitle("Search Location")
    }
  }
}

#Preview {
  NavigationStack {
    SearchLocationView()
  }
  .previewModelContainer()
  .environment(ErrorController())
}
