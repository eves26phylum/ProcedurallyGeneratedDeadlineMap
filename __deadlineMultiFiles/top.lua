local modules = {}
local cached = {}
function import(key)
    local value = cached[key] or modules[key]()
    cached[key] = value
    return value
end
function assert(condition, message)
    if not condition then
        error(message or `{_VERSION} assertion error`)
    end
end