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
            Label("Licenses", systemImage: "licenseplate")
          }
        }
        
        Section("Links") {
          Button {
            openURL(URL(string: "https://niabis.com/privacypolicy")!)
          } label: {
            Label("Privacy Policy", systemImage: "hand.raised")
          }
          .foregroundStyle(.foreground)
          
          Button {
            openURL(URL(string: "https://niabis.com/terms")!)
          } label: {
            Label("Terms", systemImage: "book.pages")
          }
          .foregroundStyle(.foreground)
        }
        .headerProminence(.increased)
      }
      .navigationTitle("Settings")
    }
  }
}

#Preview {
  SettingsView()
}
