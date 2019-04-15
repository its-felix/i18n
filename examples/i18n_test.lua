dofile("i18n_init.lua")

print(i18n.get().GREET)
print(i18n.get(i18n.locale.DE).GREET)

i18n.with_locale(i18n.locale.DE, function()
    print(i18n.get().GREET)
    print(i18n.get(i18n.locale.EN).GREET)
    print(i18n.get().TEST)
    print(i18n.get().ONLY_IN_EN.TEST)
    print(i18n.get().ONLY_IN_EN.TEST2)
    print(i18n.get().UNCONFIGURED_KEY)
end)

print(i18n.get().GREET)