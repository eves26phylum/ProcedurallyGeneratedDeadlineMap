local robloxAdapter = {}
function robloxAdapter:newInstance(...)
    return Instance.new(...)
end
function robloxAdapter:setProperty(property, key, value)
    property[key] = value
end
function robloxAdapter:findFirstChild(target, ...)
    return target:FindFirstChild(...)
end
function robloxAdapter:destroy(target)
    return target:Destroy()
end
return robloxAdapter