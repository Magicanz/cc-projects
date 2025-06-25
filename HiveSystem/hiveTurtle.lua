Version = 2
UpdateUrl = "https://raw.githubusercontent.com/Magicanz/cc-projects/refs/heads/main/HiveSystem/hiveTurtle.lua"

local function updateCode(in_url)
    if in_url ~= "" then
        UpdateUrl = in_url
    end

    local response = http.get(UpdateUrl)
    if response then
        local updateText = response.readAll()
        response.close()
        
        -- Write the new content to startup.lua
        local file = fs.open("startup.lua", "w")
        file.write(updateText)
        file.close()
        return true
    else
        return false
    end
end

local function findItem(item_name, start)
    local sel = start
    turtle.select(start)
    local item = turtle.getItemDetail()
    
    while item == nil or item["name"] ~= item_name do
        repeat
            sel = (sel % 16) + 1
            turtle.select(sel)
            item = turtle.getItemDetail()
        until item ~= nil or sel == start
        
        if sel == start then
            return nil
        end
    end

    return sel
end
 
local function placeHive()
    local loc = findItem("productivebees:advanced_oak_beehive", 7)
    if loc == nil then return false end
    turtle.select(loc)
    return turtle.placeUp()
end

local function destroyHive ()
    turtle.select(1)
    return turtle.digUp()
end

local function fillHive ()
    for i=1,16 do
        turtle.select(i)
        turtle.dropUp()
        turtle.dropDown()
    end

    turtle.select(1)
    turtle.suckUp()

    if turtle.getItemCount() == 5 then
        return true
    end

    return false
end

local function emptyHive ()
    local loc = findItem("productivebees:sturdy_bee_cage", 1)
    if loc == nil then return false end
    turtle.select(loc)
    local count = turtle.getItemCount()
    if count ~= 5 then return false end

    turtle.dropUp()
    sleep(1)

    while turtle.suckUp() do end
    loc = findItem("productivebees:sturdy_bee_cage", 1)
    if loc == nil then return false end

    return true
end
 
local function main ()
    rednet.open("left")

    while true do
        local response
        local id, msg = rednet.receive("PROT_HIVE")

        if msg == "BLD" then
            response = placeHive()
            if not response then
                print("BLD ERR")
                rednet.send(id, "BLD_ERR", "PROT_HIVE_R")
            end
        elseif msg == "FILL" then
            response = fillHive()
            if not response then
                print("FILL ERR")
                rednet.send(id, "FILL_ERR", "PROT_HIVE_R")
            end
        elseif msg == "DST" then
            response = destroyHive()
            if not response then
                print("DST ERR")
                rednet.send(id, "DST_ERR", "PROT_HIVE_R")
            end
        elseif msg == "EMP" then
            response = emptyHive()
            if not response then
                print("EMP ERR")
                rednet.send(id, "EMP_ERR", "PROT_HIVE_R")
            end
        elseif string.sub(msg, 1, 6) == "UPDATE" then
            local link = "" 
            if string.len(msg) >= 7 then
                link = string.sub(msg, 8)
            end
            response = updateCode(link)
            if not response then
                print("UPDATE ERR")
                rednet.send(id, "UPDATE_ERR", "PROT_HIVE_R")
            else
                os.reboot()
            end
        else
            print("Received Malformed Message")
            print(msg)
        end
    end
end

print("Version ", Version)

local success, errorMsg = pcall(main)

if not success then
    print("ERROR, CRASH!")
    print(errorMsg)
    sleep(60)
    updateCode("")
    os.reboot()
end