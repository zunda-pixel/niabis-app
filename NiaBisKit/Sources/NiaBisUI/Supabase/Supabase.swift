import Supabase

let supabase = SupabaseClient(
  supabaseURL: SecureEnv.supabaseProjectUrl,
  supabaseKey: SecureEnv.supabasePublicApiKey,
  options: .init(
    auth: .init(
      storage: KeychainLocalStorage(
        service: Constants.bundleIdentifier,
        accessGroup: "\(Constants.appIdentifierPrefix).\(Constants.appGroup)"
      )
    )
  )
)
