local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

function E:Dump(o)
    local cache, stack, output = {}, {}, {}
    local depth = 1
    local output_str = "{\n"

    while true do
        local size = 0
        for k, v in pairs(o) do
            size = size + 1
        end

        local cur_index = 1
        for k, v in pairs(o) do
            if (cache[o] == nil) or (cur_index >= cache[o]) then
                if (string.find(output_str, "}", output_str:len())) then
                    output_str = output_str .. ",\n"
                elseif not (string.find(output_str, "\n", output_str:len())) then
                    output_str = output_str .. "\n"
                end

                -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
                table.insert(output, output_str)
                output_str = ""

                local key
                if (type(k) == "number" or type(k) == "boolean") then
                    key = "[" .. tostring(k) .. "]"
                else
                    key = "['" .. tostring(k) .. "']"
                end

                if (type(v) == "number" or type(v) == "boolean") then
                    output_str = output_str .. string.rep("    ", depth) .. key .. " = " .. tostring(v)
                elseif (type(v) == "table") then
                    output_str = output_str .. string.rep("    ", depth) .. key .. " = {\n"
                    table.insert(stack, o)
                    table.insert(stack, v)
                    cache[o] = cur_index + 1
                    break
                else
                    output_str = output_str .. string.rep("    ", depth) .. key .. " = '" .. tostring(v) .. "'"
                end

                if (cur_index == size) then
                    output_str = output_str .. "\n" .. string.rep("    ", depth - 1) .. "}"
                else
                    output_str = output_str .. ","
                end
            else
                -- close the table
                if (cur_index == size) then
                    output_str = output_str .. "\n" .. string.rep("    ", depth - 1) .. "}"
                end
            end

            cur_index = cur_index + 1
        end

        if (size == 0) then
            output_str = output_str .. "\n" .. string.rep("    ", depth - 1) .. "}"
        end

        if (#stack > 0) then
            o = stack[#stack]
            stack[#stack] = nil
            depth = cache[o] == nil and depth + 1 or depth - 1
        else
            break
        end
    end

    -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
    table.insert(output, output_str)
    output_str = table.concat(output)

    return output_str
end

function E:CopyTable(currentTable, defaultTable)
    if type(currentTable) ~= "table" then
        currentTable = {}
    end

    if type(defaultTable) == "table" then
        for option, value in pairs(defaultTable) do
            if type(value) == "table" then
                value = self:CopyTable(currentTable[option], value)
            end

            currentTable[option] = value
        end
    end

    return currentTable
end

function E:IsEmpty(t)
    for _, _ in pairs(t) do
        return false
    end
    return true
end

function E:Tabulate(t, template)
    template = template or "%s %s\n"

    local ordered_keys = {}
    for k in pairs(t) do
        table.insert(ordered_keys, k)
    end

    local result = {}
    for i = 1, #ordered_keys do
        local k, v = ordered_keys[i], t[ordered_keys[i]]

        result[#result + 1] = template:format(k, v)
    end

    table.sort(result)

    return table.concat(result)
end

function E:TableToString(table)
    return "return" .. self:SerializeTable(table)
end

function E:StringToTable(str)
    local f = loadstring(str)
    return f()
end

function E:SerializeTable(val, name, skipnewlines, depth)
    skipnewlines = skipnewlines or false
    depth = depth or 0

    local tmp = string.rep(" ", depth)
    if name then
        if not string.match(name, "^[a-zA-z_][a-zA-Z0-9_]*$") then
            name = string.gsub(name, "'", "\\'")
            name = tonumber(name) and "[" .. name .. "]" or "['" .. name .. "']"
        end
        tmp = tmp .. name .. " = "
    end

    if type(val) == "table" then
        tmp = tmp .. "{" .. (not skipnewlines and "\n" or "")

        for k, v in pairs(val) do
            tmp = tmp .. self:SerializeTable(v, k, skipnewlines, depth + 1) .. "," .. (not skipnewlines and "\n" or "")
        end

        tmp = tmp .. string.rep(" ", depth) .. "}"
    elseif type(val) == "number" then
        tmp = tmp .. tostring(val)
    elseif type(val) == "string" then
        tmp = tmp .. string.format("%q", val)
    elseif type(val) == "boolean" then
        tmp = tmp .. (val and "true" or "false")
    else
        tmp = tmp .. '"[inserializeable datatype:' .. type(val) .. ']"'
    end

    return tmp
end
