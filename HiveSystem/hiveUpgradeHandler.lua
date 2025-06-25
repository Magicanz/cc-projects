UpdateUrl = "https://raw.githubusercontent.com/Magicanz/cc-projects/refs/heads/main/HiveSystem/hiveUpgradeHandler.lua"

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

local function insertUpgrades ()
    for i=1,4 do
        turtle.select(i)
        turtle.dropDown()
    end
end

local function extractUpgrades ()
    for i=1,4 do
        turtle.select(i) 
        turtle.suckDown()
    end
end

local function main ()
    rednet.open("right")

    while true do
        local id, msg = rednet.receive("PROT_HIVE_UPGR")

        if msg == "INS" then
            insertUpgrades()
        elseif msg == "EXT" then
            extractUpgrades()
        elseif string.sub(msg, 1, 6) == "UPDATE" then
            local link = "" 
            if string.len(msg) >= 7 then
                link = string.sub(msg, 8)
            end
            local response = updateCode(link)
            if not response then
                print("UPDATE ERR")
                rednet.send(id, "UPDATE_ERR", "PROT_HIVE_UPGR_R")
            else
                os.reboot()
            end
        end
    end
end

local success, errorMsg = pcall(main)

if not success then
    print("ERROR, CRASH!")
    print(errorMsg)
    sleep(60)
    updateCode("")
    os.reboot()
end