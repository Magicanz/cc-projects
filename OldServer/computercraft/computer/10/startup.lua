redstone.setOutput("back", true)

while true do 
    redstone.setOutput("back", false)
    sleep(0.15)
    redstone.setOutput("back", true)
    sleep(1140)
end
