# Usage
## Step 1: Load the lib
```lua
dofile("i18n.lua")
```

## Step 2: Create locale files
Locale files may contain any lua variables (most likely strings, but you're free to put functions, tables and more in there)
### locale_de.lua
```lua
return {
    GREET = "Hallo"
}
```

### locale_en.lua
```lua
return {
    GREET = "Hello"
}
```

## Step 3: Register your locales
```lua
i18n.register_locale(1, "DE", "Deutsch")
i18n.register_locale(2, "EN", "English")
```

## Step 4: Access your registered locales
```lua
-- via shortname
local locale = i18n.locale.DE

-- via name
locale = i18n.locale["Deutsch"]

-- via id
locale = i18n.locale[1]

-- list all locales
for _, locale in ipairs(i18n.locales) do
    print(locale.id, locale.short_name, locale.name)
end
```

## Step 5: Load your locale files
```lua
i18n.load_file("locale_de.lua", i18n.locale.DE)
i18n.load_file("locale_en.lua", i18n.locale.EN)
```

## Step 6: Use your locale
```lua
i18n.get()-- if no locale is given, returns the locale table for the default locale
i18n.get(i18n.locale.DE)-- pass any locale to access the locale table for that locale

i18n.with_locale(i18n.locale.DE, function(locale_tbl)
    -- locale_tbl is the locale table for the passed locale
    print(locale_tbl.GREET)-- prints "Hallo"
    print(i18n.get().GREET)-- prints "Hallo" -> the function is executed with a context locale
    print(i18n.get(i18n.locale.EN).GREET)-- prints "Hello" -> an explicit locale was given
end)
```