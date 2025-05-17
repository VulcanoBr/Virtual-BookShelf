
module LanguageHelper
  LANGUAGE_NAMES = {
    'en'    => 'Inglês',
    'pt-BR' => 'Português (Brasil)',
    'pt'    => 'Português',
    'es'    => 'Espanhol',
    'fr'    => 'Francês',
    'de'    => 'Alemão',
    'it'    => 'Italiano',
    'ja'    => 'Japones',
    'zh'    => 'Chines',
    'ru'    => 'Russo',
    'ko'    => 'Coreano',
    'ar'    => 'Árabe',
    'hi'    => 'Hindi',
    'nl'    => 'Holandês',
    'sv'    => 'Sueco',
    'pl'    => 'Polonês',
    'tr'    => 'Turco',
    'el'    => 'Grego',
    'he'    => 'Hebraico',
    'id'    => 'Indonésio',
    'ms'    => 'Malaio',
    'vi'    => 'Vietnamita',
    'th'    => 'Tailandês',
    'fi'    => 'Finlandês',
    'no'    => 'Norueguês',
    'da'    => 'Dinamarquês',
    'cs'    => 'Tcheco',
    'hu'    => 'Húngaro',
    'ro'    => 'Romeno',
    'oc'    => 'Occitano',
    'mi'    => 'Maori',
    ' '     => 'N/A',
    'und'   => 'Indefinido'
  }.freeze

  def display_language(language_code)
    LANGUAGE_NAMES[language_code] || language_code.titleize
  end
end
