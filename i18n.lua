local function read_only(index, call, tostring)
    return setmetatable({}, {
        __newindex = function() end,
        __index = index,
        __call = call,
        __tostring = tostring,
        __metatable = false
    })
end

local function join(values, delimiter)
    local str = ""

    for _, v in ipairs(values) do
        str = str .. delimiter .. v
    end

    return string.sub(str, string.len(delimiter) + 1)
end

local function copy_itable(tbl, append_value)
    local copy = {}

    for i, v in ipairs(tbl) do
        table.insert(copy, v)
    end

    if append_value then
        table.insert(copy, append_value)
    end

    return copy
end

local function create_unpresent_key_table(key_path)
    local key_path_str = join(key_path, ".")

    return read_only(
        function(tbl, requested_key)
            return create_unpresent_key_table(copy_itable(key_path, requested_key))
        end,
        nil,
        function()
            return key_path_str
        end
    )
end

local translations = {}
local config = {
    default_locale = nil,
    context_locale = nil,
    fallback_function = function(locale, requested_key_path)
        local result = nil
        local default_locale = i18n.get_default_locale()
    
        -- fallback should always look into the default locale and never in the context locale
        -- we're most likely already here because the lookup via context locale failed
        -- also, we only look into the default locale translations if this locale is not the default locale
        -- if locale == config.default_locale : copy == tbl
        if default_locale and locale ~= default_locale then
            local temp = translations[default_locale]
            local key_path_resolved = true
            
            for _, key in ipairs(requested_key_path) do
                if temp and type(temp) == "table" then
                    temp = temp[key]
                else
                    key_path_resolved = false
                    break
                end
            end
    
            if key_path_resolved then
                result = temp
            end
        end

        if not result then
            result = create_unpresent_key_table(requested_key_path)
        end
    
        return result
    end,
    locales = {},
    locales_by_id = {},
    locales_by_short_name = {},
    locales_by_name = {}
}

i18n = {}
i18n.locale = read_only(
    function(tbl, k)
        local t = type(k)
        if t == "number" then
            return config.locales_by_id[k] or i18n.locale()
        elseif t == "string" then
            return config.locales_by_short_name[k] or config.locales_by_name[k] or i18n.locale()
        else
            return i18n.locale()
        end
    end,
    function()
        return i18n.get_context_locale() or i18n.get_default_locale()
    end
)
i18n.locales = read_only(config.locales)

function i18n.get(locale)
    if not locale then
        locale = i18n.locale()

        if not locale then
            error("no locale given and neither a context nor a default locale set")
        end
    end

    return translations[locale]
end

function i18n.get_default_locale()
    return config.default_locale
end

function i18n.set_default_locale(locale)
    config.default_locale = locale
end

function i18n.get_context_locale()
    return config.context_locale
end

function i18n.with_locale(locale, fnc)
    local prev = config.context_locale

    config.context_locale = locale
    fnc(i18n.get())
    config.context_locale = prev
end

function i18n.set_fallback_function(fnc)
    config.fallback_function = fnc
end

function i18n.register_locale(id, short_name, name)
    -- check if a locale by any of the given parameters is already registered
    if config.locales_by_id[id] then
        local l = config.locales_by_id[id]
        error(string.format("locale with id %d already registered (%d %s %s)", l.id, l.id, l.short_name, l.name))
    elseif config.locales_by_short_name[short_name] then
        local l = config.locales_by_short_name[short_name]
        error(string.format("locale with short name %s already registered (%d %s %s)", l.short_name, l.id, l.short_name, l.name))
    elseif config.locales_by_name[name] then
        local l = config.locales_by_name[name]
        error(string.format("locale with name %s already registered (%d %s %s)", l.name, l.id, l.short_name, l.name))
    end
    
    local locale = read_only({
        id = id,
        short_name = short_name,
        name = name
    })

    table.insert(config.locales, locale)
    config.locales_by_id[id] = locale
    config.locales_by_short_name[short_name] = locale
    config.locales_by_name[name] = locale
end

function i18n.load_file(file, locale)
    local function build(value, key_path)
        if type(value) == "table" then
            local copy = {}

            for k, v in pairs(value) do
                copy[k] = build(v, copy_itable(key_path, k))
            end

            value = read_only(function(tbl, requested_key)
                local result = copy[requested_key]

                if not result then
                    result = config.fallback_function(locale, copy_itable(key_path, requested_key))
                end

                return result
            end)
        end

        return value
    end

    translations[locale] = build(dofile(file), {})
end

i18n = read_only(i18n)