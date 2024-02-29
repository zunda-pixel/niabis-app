import SwiftUI
import MapKit

struct SearchLocationView: View {
  @State var viewModel = SearchLocationViewModel()
  @State var selectedCompletion: MKLocalSearchCompletion?
  
  var body: some View {
    List {
      TextField("Search Location", text: $viewModel.query)
      
      ForEach(viewModel.results) { completion in
        Button {
          selectedCompletion = completion
        } label: {
          Label {
            VStack(alignment: .leading) {
              Text(completion.title)
              Text(completion.subtitle)
                .foregroundStyle(.secondary)
                .font(.callout)
            }
          } icon: {
            Image(systemName: "fork.knife")
          }
        }
      }
    }
    .overlay {
      if viewModel.results.isEmpty {
        ContentUnavailableView("Search Location", systemImage: "fork.knife")
      }
    }
    .sheet(item: $selectedCompletion) { completion in
      LoadingShopView(completion: completion)
    }
  }
}

extension MKLocalSearchCompletion: Identifiable {
  public var id: String { self.title + self.subtitle }
}

#Preview {
  NavigationStack {
    SearchLocationView()
  }
  .previewModelContainer()
  .environment(ErrorController())
}
