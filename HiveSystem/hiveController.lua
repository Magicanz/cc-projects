UpdateUrl = "https://raw.githubusercontent.com/Magicanz/cc-projects/refs/heads/main/HiveSystem/hiveController.lua"

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

local function setupHive()
    redstone.setOutput("back", true)
    sleep(1)
    redstone.setOutput("back", false)

    rednet.broadcast("BLD", "PROT_HIVE")
    local id, message = rednet.receive("PROT_HIVE_R", 1)
    if id then return false end

    rednet.broadcast("INS", "PROT_HIVE_UPGR")
    local id, message = rednet.receive("PROT_HIVE_UPGR_R", 2)
    if id then return false end

    rednet.broadcast("FILL", "PROT_HIVE")
    local id, message = rednet.receive("PROT_HIVE_R", 1)
    if id then return false end
end

local function remHive()
    rednet.broadcast("EMP", "PROT_HIVE")
    local id, message = rednet.receive("PROT_HIVE_R", 1)
    if id then return false end

    rednet.broadcast("EXT", "PROT_HIVE_UPGR")
    local id, message = rednet.receive("PROT_HIVE_UPGR_R", 2)
    if id then return false end

    rednet.broadcast("DST", "PROT_HIVE")
    local id, message = rednet.receive("PROT_HIVE_R", 1)
    if id then return false end

    redstone.setOutput("back", true)
    sleep(1)
    redstone.setOutput("back", false)
end

local function main ()
    rednet.open("left")
    while true do
        local input = read()
        if input == "in" then
            setupHive()
        elseif input == "out" then
            remHive()
        elseif string.sub(input, 1, 6) == "update" then
            local link = "" 
            if string.len(msg) >= 7 then
                link = string.sub(msg, 8)
            end
            local response = updateCode(link)
            if not response then
                print("Error with Update")
            else
                os.reboot()
            end
        elseif input == "updateall" then
            rednet.broadcast("UPDATE", "PROT_HIVE")
            rednet.broadcast("UPDATE", "PROT_HIVE_UPGR")
            local response = updateCode("")
            if not response then
                print("Error with Update")
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