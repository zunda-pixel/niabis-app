import SwiftUI

struct SettingsView: View {
  @Environment(\.openURL) var openURL

  var body: some View {
    NavigationStack {
      List {
        Section {
          NavigationLink {
            LicensesView()
          } label: {
            Label(
              String(localized: "Licenses", bundle: .module),
              systemImage: "licenseplate"
            )
          }
        }
        
        Section(String(localized: "Links", bundle: .module)) {
          Button {
            openURL(URL(string: "https://niabis.com/privacypolicy")!)
          } label: {
            Label(
              String(localized: "Privacy Policy", bundle: .module),
              systemImage: "hand.raised"
            )
          }
          .foregroundStyle(.foreground)
          
          Button {
            openURL(URL(string: "https://niabis.com/terms")!)
          } label: {
            Label(
              String(localized: "Terms", bundle: .module),
              systemImage: "book.pages"
            )
          }
          .foregroundStyle(.foreground)
        }
        .headerProminence(.increased)
      }
      .navigationTitle(Text("Settings", bundle: .module))
    }
  }
}

#Preview {
  SettingsView()
}
