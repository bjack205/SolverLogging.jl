
"""
    shiftswap!(a, inew, iold)

Move an entry in vector `iold`  to `inew`, shifting the other arguments.
"""
function shiftswap!(a::AbstractVector, inew, iold)
    if inew != iold
        v = a[iold]
        deleteat!(a, iold)
        insert!(a, inew, v)
    end
    return a
end

"""
    shiftidx!(idx, fid, inew)

For a vector of unique, consecutive indices `idx`, set the index of entry `fid` to the 
new index `inew`. Update the other entries, maintaining relative ordering, such that 
`idx` is still a vector of unique, consecutive integers. Runs in O(n).
"""
function shiftidx!(idx::AbstractVector{<:Integer}, fid::Integer, inew::Integer) 
    iold = idx[fid]
    ilo = min(iold,inew)
    ihi = max(iold,inew)
    s = -sign(inew - iold)
    for j = 1:length(idx)
        if ilo <= idx[j] <= ihi
            idx[j] += s
        end
    end
    idx[fid] = inew
    return idx
end


"""
    getwidth(fmt::String)

Get the width field from a C-style printf format string.
It looks for a set of numbers followed by a decimal or letter, but not preceded by a decimal 
or digit. Returns -1 if no width is found.
"""
function getwidth(fmt::String)::Int
    period = findlast(".", fmt)

    # search for a set of characters followed by a decimal or letter, but not 
    #   preceded by a decimal or digit
    regex = r"(?<![0-9|.])[0-9]+(?=[a-zA-Z|.])"
    inds = findfirst(regex, fmt)
    if !isnothing(inds)
        width = parse(Int, fmt[inds])
        if width == 0
            return -1
        else
            return width
        end
    else
        return -1
    end
end