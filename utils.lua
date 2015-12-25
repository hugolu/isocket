#!/usr/local/bin/lua

-- stdio
function printf(s, ...)
  return io.write(s:format(...))
end

-- load config file
function load_file(file)
    conf = {}

    fp = io.open(file, "r")
    for line in fp:lines() do
        line = line:match( "%s*(.+)" )
        if line and line:sub( 1, 1 ) ~= "#" and line:sub( 1, 1 ) ~= ";" then
            option = line:match( "(%S+):" ):lower()
            value  = line:match( "%S*%s*(.*)" )
            conf[option] = value
        end
    end
    fp.close()

    return conf
end

-- file size
function fsize(file)
    local current = file:seek()      -- get current position
    local size = file:seek("end")    -- get file size
    file:seek("set", current)        -- restore position
    return size
end

-- dirname
function dirname(str)
    if str:match(".-/.-") then
        local name = string.gsub(str, "(.*/)(.*)", "%1")
        return name
    else
        return ''
    end
end

-- show array
function show_array(arr)
    io.write("[")
    for i,v in ipairs(arr) do
        if i > 1 then io.write(", ") end
        io.write("\"" .. v .. "\"")
    end
    io.write("]\n")
end

-- string split
function string:split( inSplitPattern, outResults )
    if not outResults then
        outResults = {}
    end
    local theStart = 1
    local theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
    while theSplitStart do
        table.insert( outResults, string.sub( self, theStart, theSplitStart-1 ) )
        theStart = theSplitEnd + 1
        theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
    end
    table.insert( outResults, string.sub( self, theStart ) )
    return outResults
end
