import SwiftUI

public struct ContentView: View {
  @State var router = NavigationRouter()
  let authController = AuthController()
  let errorController = ErrorController()
  
  public init() {
    
  }
  
  @ViewBuilder
  var content: some View {
    if let session = authController.session {
      VStack {
        Text(session.user.id.uuidString)
      }
        .environment(\.session, session)
        .toolbar {
          ToolbarItem(placement: .topBarLeading) {
            Button("SignOut") {
              Task(priority: .high) {
                do {
                  try await supabase.auth.signOut()
                } catch {
                  errorController.error = error
                }
              }
            }
          }
        }
    } else {
      StartView()
    }
  }
  
  public var body: some View {
    NavigationStack(path: $router.routes) {
      content
        .navigationDestination(for: NavigationRouter.Item.self) { item in
          switch item {
          case .signIn:
            SignInOrSignUpView(mode: .signIn)
          case .signUp:
            SignInOrSignUpView(mode: .signUp)
          }
        }
        .navigationTitle("NiaBis")
    }
    .environment(router)
    .environment(authController)
    .environment(errorController)
  }
}

#Preview {
  ContentView()
}

