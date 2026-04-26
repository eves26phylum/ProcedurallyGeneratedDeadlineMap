local deadlineAdapter = {}
function deadlineAdapter:newInstance(...)
    return create_instance(...)
end
function deadlineAdapter:setProperty(property, key, value)
    property[key] = value
end
function deadlineAdapter:findFirstChild(target, ...)
    return target.find_first_child(...)
end
function deadlineAdapter:destroy(target)
    return target.destroy()
end
return deadlineAdapter