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

## Step 5: Define a default locale
```lua
i18n.set_default_locale(i18n.locale.EN)
```

## Step 6: Load your locale files
```lua
i18n.load_file("locale_de.lua", i18n.locale.DE)
i18n.load_file("locale_en.lua", i18n.locale.EN)
```

## Step 7: Use your locale
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

## More
```lua
-- get the default locale
i18n.get_default_locale()

-- get the current context locale (only set during the execution of a i18n.with_locale function)
i18n.get_context_locale()

-- get the current active locale (context_locale if set, else default_locale)
i18n.locale()

--[[
if you try to access a key which is not defined in the requested locale
the library tries to find the requested key in the default locale (if youre not already using the default locale)
]]
i18n.get(i18n.locale.DE).SOME_KEY_THAT_IS_ONLY_DEFINED_IN_EN

--[[
if you try to access a key which is neither defined in the request locale
nor in the default locale, the requested key will be returned
]]
print(i18n.get().SOME_KEY_THAT_IS_NOT_DEFINED)-- prints "SOME_KEY_THAT_IS_NOT_DEFINED"

-- you can define that behaviour by setting a fallback function
i18n.set_fallback_function(function(locale, requested_key_path)
    -- locale is the current locale
    -- requested_key_path is a table containing the path which you tried to access

    return "Your fallback value"
end)
```