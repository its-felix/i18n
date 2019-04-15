dofile("i18n_init.lua")

for _, locale in ipairs(i18n.locales) do
    print(locale.id, locale.short_name, locale.name)
end