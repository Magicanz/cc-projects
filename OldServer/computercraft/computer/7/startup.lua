shell.run("containerChecker")
local modem = peripheral.find("modem")
modem.transmit(8969, 0, {"WARNING", "PROG OFF", os.time("local"), "Container checker off!", "A container checker has been turned off. Was this deliberate or is it due to a crash?", {gps.locate(3)}})
