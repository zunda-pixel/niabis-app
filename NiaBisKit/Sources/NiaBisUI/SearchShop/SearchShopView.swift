import SwiftUI
import MapKit

struct SearchShopView: View {
  @State var viewModel = SearchShopViewModel()
  @State var selectedCompletion: MKLocalSearchCompletion?
  
  var body: some View {
    List {
      TextField("Search Shop", text: $viewModel.query)
      
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
        ContentUnavailableView("Search Shop", systemImage: "fork.knife")
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
    SearchShopView()
  }
  .previewModelContainer()
  .environment(ErrorController())
}
