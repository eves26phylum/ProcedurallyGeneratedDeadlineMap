local Object = {}

function Object:assign(a, b, optionalFunc)
    assert(a, "A is missing")
    assert(b, "B is missing")
    local optionalFunc = optionalFunc or function(a, index, value) a[index] = value end
    for index, value in b do
        optionalFunc(a, index, value)
    end
end

return Object