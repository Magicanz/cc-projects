function insertUpgrades ()
    for i=1,4 do
        turtle.select(i)
        turtle.dropDown()
    end
end

function extractUpgrades ()
    for i=1,4 do
        turtle.select(i) 
        turtle.suckDown()
    end
end

function main ()
    rednet.open("left")

    while true do
        local id, msg = rednet.receive("PROT_HIVE_UPGR")

        if msg == "INS" then
            insertUpgrades()
        elseif msg == "EXT" then
            extractUpgrades()
        end
    end
end

main()