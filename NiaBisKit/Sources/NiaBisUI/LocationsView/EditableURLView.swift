import SwiftUI

struct EditableURLView: View {
  @Environment(\.openURL) var openURL
  @Binding var url: URL?
  @Binding var editMode: EditMode
  @State var urlString: String = ""
  @FocusState var focusTextField: Bool?
  
  var body: some View {
    VStack(alignment: .leading) {
      Text("Web Site", bundle: .module)
        .foregroundStyle(.secondary)
      if editMode.isEditing {
        TextField(
          String(localized: "Web Site", bundle: .module),
          text: $urlString,
          axis: .horizontal
        )
          .focused($focusTextField, equals: true)
          .onSubmit(of: .text) {
            if let url = URL(string: urlString) {
              self.url = url
            }
            editMode = .inactive
          }
      } else if let url {
        Button {
          openURL(url)
        } label: {
          Text(url.absoluteString)
            .lineLimit(1)
        }
      } else {
        Button {
          if let url = UIPasteboard.general.url {
            self.url = url
          } else {
            self.urlString = self.url?.absoluteString ?? ""
            self.focusTextField = true
          }
        } label: {
          Text("Add Web Site", bundle: .module)
        }
      }
    }
    .onChange(of: editMode.isEditing) { _, _ in
      self.urlString = self.url?.absoluteString ?? ""
    }
    .onChange(of: focusTextField) { _, newValue in
      if newValue != true {
        editMode = .inactive
      }
    }
    .onChange(of: urlString) { _, newValue in
      self.url = URL(string: newValue)
    }
  }
}

private struct Preview: View {
  @State var url: URL? = URL(string: "https://google.com")
  @State var editMode: EditMode = .inactive
  
  var body: some View {
    NavigationStack {
      List {
        EditableURLView(url: $url, editMode: $editMode)
      }
      .toolbar {
        ToolbarItem {
          Button {
            editMode = editMode == .active ? .inactive : .active
          } label: {
            Text("Edit", bundle: .module)
          }
        }
      }
    }
  }
}

#Preview {
  Preview()
}
