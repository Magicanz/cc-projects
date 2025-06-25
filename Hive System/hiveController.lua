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
        end
    end
end

main()