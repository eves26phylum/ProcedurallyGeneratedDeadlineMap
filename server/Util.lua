local Object = {}

function Object:assign(a, b, optionalFunc)
    assert(a, "A is missing")
    assert(b, "B is missing")
    for index, value in b do
        if optionalFunc then
            optionalFunc(a, index, value)
            continue
        end
        a[index] = value
    end
end

return Object