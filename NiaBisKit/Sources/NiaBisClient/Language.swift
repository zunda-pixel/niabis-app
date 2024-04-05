import Foundation

public enum Language: String, Codable, Sendable, Hashable, CaseIterable {
  case arabic = "ar"
  case chinese = "zh"
  case chineseTraditional = "zh_TW"
  case danish = "da"
  case dutch = "nl"
  case englishAustralia = "en_AU"
  case englishCanada = "en_CA"
  case englishHongKong = "en_HK"
  case englishIndia = "en_IN"
  case englishIreland = "en_IE"
  case englishMalaysia = "en_MY"
  case englishNewZealand = "en_NZ"
  case englishPhilippines = "en_PH"
  case englishSingapore = "en_SG"
  case englishSouthAfrica = "en_ZA"
  case englishUnitedKingdom = "en_UK"
  case english = "en"
  case french = "fr"
  case frenchBelgium = "fr_BE"
  case frenchCanada = "fr_CA"
  case frenchSwitzerland = "fr_CH"
  case germanAustria = "de_AT"
  case german = "de"
  case greek = "el"
  case hebrew = "iw"
  case indonesian = "in"
  case italian = "it"
  case italianSwitzerland = "it_CH"
  case japanese = "ja"
  case korean = "ko"
  case norwegian = "no"
  case portuguesePortugal = "pt_PT"
  case portuguese = "pt"
  case russian = "ru"
  case spanishArgentina = "es_AR"
  case spanishColombia = "es_CO"
  case spanishMexico = "es_MX"
  case spanishPeru = "es_PE"
  case spanish = "es"
  case spanishVenezuela = "es_VE"
  case spanishChile = "es_CL"
  case swedish = "sv"
  case thai = "th"
  case turkish = "tr"
  case vietnamese = "vi"
  
  public init?(locale: Locale) {
    switch locale.identifier {
    case "pa_Arab_PK", "ar_YE", "ar_EG", "ar_SA", "ar_SD", "ar_LY", "ar_OM", "ar_MA", "uz_Arab_AF", "ar_TN", "ar_JO", "ar_KW", "pa_Arab", "ar_QA", "ar_LB", "ar_IQ", "uz_Arab", "ar_BH", "ar", "ar_AE", "ar_DZ", "ar_SY": self = .arabic
    case "zh_Hant_HK", "zh_Hans_SG", "zh_Hans_HK", "zh_Hans", "zh", "zh_Hans_CN", "zh_Hant", "zh_Hant_MO", "zh_Hans_MO": self = .chinese
    case "zh_Hant_TW": self = .chineseTraditional
    case "da", "da_DK": self = .danish
    case "nl", "nl_NL", "nl_BE": self = .dutch
    case "en_MT", "en_MU", "en_PK", "en_UM", "en_GU", "en_US_POSIX", "en_NA", "en_BW", "en_AS", "en_BZ", "en_JM", "en_US", "en", "en_ZW", "en_TT", "en_MH", "en_GB", "en_BE", "en_MP", "en_VI": self = .english
    case "en_AU": self = .englishAustralia
    case "en_CA": self = .englishCanada
    case "en_HK": self = .englishHongKong
    case "en_IN": self = .englishIndia
    case "en_IE": self = .englishIndia
    case "en_NZ": self = .englishNewZealand
    case "en_PH": self = .englishPhilippines
    case "en_SG": self = .englishSingapore
    case "en_ZA": self = .englishSouthAfrica
    case "fr_GP", "fr_GQ", "fr_RW", "fr_TD", "fr_KM", "fr_TG", "fr_LU", "fr_FR", "fr_NE", "fr_DJ", "fr_MC", "fr_CD", "fr_CF", "fr_RE", "fr_MF", "fr_CG", "fr_MG", "fr_GA", "fr_SN", "fr_CI", "fr", "fr_BF", "fr_ML", "fr_CM", "fr_BI", "fr_BJ", "fr_MQ", "fr_BL", "fr_GN": self = .french
    case "fr_BE": self = .frenchBelgium
    case "fr_CA": self = .frenchCanada
    case "fr_CH": self = .frenchSwitzerland
    case "gsw_CH", "de_LU", "de", "de_DE", "de_CH", "gsw", "de_BE", "de_LI": self = .german
    case "de_AT": self = .germanAustria
    case "el_GR", "el_CY", "el": self = .greek
    case "he", "he_IL": self = .hebrew
    case "id", "id_ID": self = .indonesian
    case "it_IT", "it": self = .italian
    case "it_CH": self = .italianSwitzerland
    case "ja_JP", "ja": self = .japanese
    case "ko_KR", "ko": self = .korean
    case "nb", "nn", "nb_NO", "nn_NO": self = .norwegian
    case "pt_PT": self = .portuguesePortugal
    case "pt_BR", "pt_MZ", "pt_GW", "pt": self = .portuguese
    case "ru_MD", "ru_UA", "ru_RU", "ru": self = .russian
    case "es_HN", "es_PA", "es_SV", "es_CR", "es_BO", "es_EC", "es_GQ", "es_GT", "es_419", "es", "es_PR", "es_US", "es_NI", "es_ES", "es_PY", "es_UY", "es_DO": self = .spanish
    case "es_AR": self = .spanishArgentina
    case "es_CO": self = .spanishColombia
    case "es_MX": self = .spanishMexico
    case "es_PE": self = .spanishPeru
    case "es_VE": self = .spanishVenezuela
    case "es_CL": self = .spanishChile
    case "sv", "sv_FI", "sv_SE": self = .swedish
    case "th_TH", "th": self = .thai
    case "tr", "tr_TR": self = .turkish
    case "vi_VN", "vi": self = .vietnamese
    default:
      if let language = Language(rawValue: locale.identifier) {
        self = language
      } else {
        return nil
      }
    }
  }
}
