import SwiftUI

struct LicensesView: View {
  var body: some View {
    List {
      ForEach(LicenseProvider.packages) { package in
        NavigationLink(package.name) {
          ScrollView {
            Text(package.license)
          }
          .navigationTitle(package.name)
          .toolbar {
            ToolbarItem {
              if case .remoteSourceControl(let location) = package.kind {
                ShareLink(item: location)
              }
            }
          }
        }
      }
    }
    .navigationTitle(Text("Licenses", bundle: .module))
  }
}

#Preview {
  NavigationStack {
    LicensesView()
  }
}
