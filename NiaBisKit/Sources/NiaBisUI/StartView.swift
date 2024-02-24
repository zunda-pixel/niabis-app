import SwiftUI

struct StartView: View {
  @Environment(NavigationRouter.self) var router
  
  var body: some View {
    List {
      Button("Sign In") {
        router.routes.append(.signIn)
      }
      
      Button("Sign Up") {
        router.routes.append(.signUp)
      }
    }
  }
}

#Preview {
  StartView()
    .environment(NavigationRouter())
}
