import Auth
import AuthenticationServices
import SwiftUI
import NiaBisData
import SystemNotification

struct SignInOrSignUpView: View {
  enum Mode {
    case signIn
    case signUp
  }

  let mode: Mode

  @Environment(\.webAuthenticationSession) var webAuthenticationSession
  @Environment(AuthController.self) var authController
  @Environment(\.openURL) var openURL
  @StateObject var toast = SystemNotificationContext()

  @State var email: String = ""
  @State var password: String = ""
  @State var isPresentedConfirmMail = false

  func login(provider: Provider) async {
    do {
      let signInURL = try supabase.auth.getOAuthSignInURL(
        provider: provider,
        redirectTo: Constants.redirectToURL
      )

      let urlWithToken = try await webAuthenticationSession.authenticate(
        using: signInURL,
        callback: .customScheme(Constants.redirectToURL.scheme!),
        preferredBrowserSession: .shared,
        additionalHeaderFields: [:]
      )

      try await supabase.auth.session(from: urlWithToken)
    } catch {
      toast.presentMessage(
        .error(
          text: "Failed to Login"
        )
      )
    }
  }

  func siginIn(with email: String, password: String) async {
    guard !email.isEmpty && !password.isEmpty else { return }

    do {
      let newSession = try await supabase.auth.signIn(
        email: email,
        password: password
      )

      authController.session = newSession
    } catch {
      toast.presentMessage(
        .error(
          text: "Failed to SingIn"
        )
      )
    }
  }

  func siginUp(with email: String, password: String) async {
    guard !email.isEmpty && !password.isEmpty else { return }

    do {
      try await supabase.auth.signUp(
        email: email,
        password: password,
        redirectTo: Constants.redirectToURL
      )

      isPresentedConfirmMail.toggle()
    } catch {
      toast.presentMessage(
        .error(
          text: "Failed to SignUp"
        )
      )
    }
  }

  func resendConfirmMail(email: String) async {
    do {
      try await supabase.auth.resend(email: email, type: .signup)
    } catch {
      toast.presentMessage(
        .error(
          text: "Failed to Resend Confirm Mail"
        )
      )
    }
  }

  func openMailApp() {
    let mailAppURL = URL(string: "message://")!
    openURL(mailAppURL)
  }

  func onOpenURLVerifySetSession(url: URL) async {
    do {
      let session = try await supabase.auth.session(from: url)
      authController.session = session
    } catch {
      toast.presentMessage(
        .error(
          text: "Failed to auth Login URL"
        )
      )
    }
  }

  var body: some View {
    Form {
      if let session = authController.session {
        Section {
          Text(session.user.email!)
        }
      }

      Section {
        TextField("Email", text: $email)
          .textContentType(.emailAddress)
          .autocorrectionDisabled()
          #if !os(macOS)
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
          #endif

        SecureField("Password", text: $password)
          .textContentType(mode == .signIn ? .password : .newPassword)
          .autocorrectionDisabled()
          #if !os(macOS)
            .textInputAutocapitalization(.never)
          #endif

        switch mode {
        case .signIn:
          Button("Sign In with Email") {
            Task(priority: .high) {
              await siginIn(with: email, password: password)
            }
          }
        case .signUp:
          Button("Sign up with Email") {
            Task(priority: .high) {
              await siginUp(with: email, password: password)
            }
          }
        }
      }

      if isPresentedConfirmMail {
        Button("Resend Mail") {
          Task(priority: .high) {
            await resendConfirmMail(email: email)
          }
        }
      }

      Button {
        Task(priority: .high) {
          await login(provider: .google)
        }
      } label: {
        Text("Sign in with Google")
      }
      .buttonBorderShape(.roundedRectangle)
    }
    .systemNotification(toast)
    .systemNotificationConfiguration(.standardToast)
    .formStyle(.grouped)
    .onSubmit(of: .text) {
      Task(priority: .high) {
        await siginIn(with: email, password: password)
      }
    }
    .alert("Confirm Mail", isPresented: $isPresentedConfirmMail) {
      Button("Open Mail") {
        openMailApp()
      }
    }
    .onOpenURL { url in
      Task(priority: .high) {
        await onOpenURLVerifySetSession(url: url)
      }
    }
  }
}

#Preview {
  SignInOrSignUpView(mode: .signIn)
    .environment(AuthController())
}
