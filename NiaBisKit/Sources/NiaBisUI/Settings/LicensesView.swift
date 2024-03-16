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
              ShareLink(item: package.location)
            }
          }
        }
      }
    }
    .navigationTitle("Licenses")
  }
}

#Preview {
  NavigationStack {
    LicensesView()
  }
}
