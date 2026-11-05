-- Marks a check that fails today because of a known bug in the addon.
-- While the bug is there the test shows as pending, with the reason. Once the bug is fixed the
-- check passes and the test fails, asking for the marker to be removed so it guards for real.
local Known = {}

local function firstLine(err)
    local text = type(err) == "table" and (err.message or tostring(err[1])) or tostring(err)
    return (tostring(text):match("[^\n]*"))
end

function Known.Issue(reason, check)
    -- busted puts `pending` in each spec file's environment, not in _G.
    local pending = getfenv(2).pending
    local ok, err = pcall(check)
    if ok then
        error("Fixed: '" .. reason .. "' passes now. Remove its Known.Issue wrapper so the test guards it.", 2)
    end
    pending("Known issue: " .. reason .. " (" .. firstLine(err) .. ")")
end

return Known
