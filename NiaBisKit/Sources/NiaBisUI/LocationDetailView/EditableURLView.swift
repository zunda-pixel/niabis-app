import SwiftUI

struct EditableURLView: View {
  @Environment(\.openURL) var openURL
  @Binding var url: URL?
  @Binding var editMode: EditMode
  @State var urlString: String = ""
  @FocusState var focusTextField: Bool?
  
  var body: some View {
    VStack(alignment: .leading) {
      Text("Web Site")
        .foregroundStyle(.secondary)
      if editMode.isEditing {
        TextField("Web Site", text: $urlString, axis: .horizontal)
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
        Button("Add Web Site") {
          if let url = UIPasteboard.general.url {
            self.url = url
          } else {
            self.urlString = self.url?.absoluteString ?? ""
            self.focusTextField = true
          }
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
          Button("Edit") { editMode = editMode == .active ? .inactive : .active}
        }
      }
    }
  }
}

#Preview {
  Preview()
}
