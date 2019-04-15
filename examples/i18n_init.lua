dofile("../i18n.lua")

i18n.register_locale(1, "DE", "Deutsch")
i18n.register_locale(2, "EN", "English")

i18n.set_default_locale(i18n.locale.EN)

i18n.load_file("locale_de.lua", i18n.locale.DE)
i18n.load_file("locale_en.lua", i18n.locale.EN)