Version = 1
UpdateUrl = "https://raw.githubusercontent.com/Magicanz/cc-projects/refs/heads/main/HiveSystem/hiveController.lua"

MN = peripheral.wrap("right")

NWSpatial = peripheral.wrap("ae2:spatial_io_port_3")
NWRedstone = peripheral.wrap("redstone_relay_0")

NESpatial = peripheral.wrap("ae2:spatial_io_port_4")
NERedstone = peripheral.wrap("redstone_relay_1")

SESpatial = peripheral.wrap("ae2:spatial_io_port_5")
SERedstone = peripheral.wrap("redstone_relay_2")

SWSpatial = peripheral.wrap("ae2:spatial_io_port_6")
SWRedstone = peripheral.wrap("redstone_relay_3")

BarrelRight = peripheral.wrap("minecraft:barrel_1")
BarrelLeft = peripheral.wrap("minecraft:barrel_2")

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

local function rebuildHives()
    rednet.broadcast("BLD", "PROT_HIVE")
    local id, message = rednet.receive("PROT_HIVE_R", 2)
    if id then return false end

    rednet.broadcast("INS", "PROT_HIVE_UPGR")
    local id, message = rednet.receive("PROT_HIVE_UPGR_R", 3)
    if id then return false end

    rednet.broadcast("FILL", "PROT_HIVE")
    local id, message = rednet.receive("PROT_HIVE_R", 2)
    if id then return false end
end

local function prepareHivesForRemoval()
    rednet.broadcast("EMP", "PROT_HIVE")
    local id, message = rednet.receive("PROT_HIVE_R", 2)
    if id then return false end

    rednet.broadcast("EXT", "PROT_HIVE_UPGR")
    local id, message = rednet.receive("PROT_HIVE_UPGR_R", 3)
    if id then return false end

    rednet.broadcast("DST", "PROT_HIVE")
    local id, message = rednet.receive("PROT_HIVE_R", 2)
    if id then return false end

end

local function drawRect (x, y, w_x, w_y, col)
    MN.setBackgroundColour(col)

    for i = 0, w_y do
        MN.setCursorPos(x, y + i) 
        MN.write(string.rep(" ", w_x))
    end
end

local function resetBg ()
    drawRect(3, 2, 21, 14, colors.lime)
    drawRect(56, 2, 21, 14, colors.red)
    drawRect(3, 37, 21, 14, colors.lightBlue)
    drawRect(56, 37, 21, 14, colors.magenta)

    drawRect(21, 15, 32, 24, colors.lightGray)
    drawRect(22, 16, 30, 22, colors.black)
end

local function main ()
    -- Monitor Size 79 x 52 ~ 3:2 aspect
    MN.setTextScale(0.5)
    MN.setBackgroundColour(colors.black)

    resetBg()
end

local function oldMain ()
    rednet.open("top")
    while true do
        local input = read()
        if input == "in" then
            setupHive()
        elseif input == "out" then
            remHive()
        elseif input == "updateall" then
            rednet.broadcast("UPDATE", "PROT_HIVE")
            rednet.broadcast("UPDATE", "PROT_HIVE_UPGR")
            local response = updateCode("")
            if not response then
                print("Error with Update")
            else
                os.reboot()
            end
        elseif string.sub(input, 1, 6) == "update" then
            local link = "" 
            if string.len(input) >= 7 then
                link = string.sub(input, 8)
            end
            local response = updateCode(link)
            if not response then
                print("Error with Update")
            else
                os.reboot()
            end
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