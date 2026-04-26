local selfProp = {}
function selfProp:returnFunctionWithIdentity(func, this)
    assert(func, "Function is missing")
    assert(this, "this is missing")
    return function(...) return func(this, ...) end
end
return selfProp