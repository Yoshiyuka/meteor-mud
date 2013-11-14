Commands = {}

Commands["/say"] = (argument) -> share.World.Player.say(argument)
Commands["/yell"] = (argument) -> share.World.Player.yell(argument)
Commands["/y"] = Commands["/yell"] #alias command for yell

Commands["/go"] = (argument)  -> Meteor.call("enterRoom", argument, (error, result) -> Session.set("sessionStart", share.World.Time() ))
Commands["/north"] = () -> share.World.Player.moveTo("north")
Commands["/south"] = () -> share.World.Player.moveTo("south")
Commands["/east"] = () ->  share.World.Player.moveTo("east")
Commands["/west"] = () ->  share.World.Player.moveTo("west")
#alias commands for cardinal direction movement
Commands["/n"] = Commands["/north"]
Commands["/s"] = Commands["/south"]
Commands["/e"] = Commands["/east"]
Commands["/w"] = Commands["/west"]
Commands["/look"] = () ->
    #will want to generate a description on the fly later on
    if share.World.Player isnt undefined
        room = Rooms.findOne({name: share.World.Player.currentRoom})
    else
        console.log "character is undefined...."

    if room isnt undefined
        directions = []
        if room.north isnt null
            directions.push("north")
        if room.south isnt null
            directions.push("south")
        if room.east isnt null
            directions.push("east")
        if room.west isnt null
            directions.push("west")
    
        exits = ""
        if directions.length < 2
            exits = "There is an exit to the " + directions.shift()
        else
            exits = "There are exits to the " + directions.shift()
            for i in [0..directions.length-1] by 1
                if _i is directions.length - 1
                    exits += ", and " + directions[i]
                else
                    exits+= ", " + directions[i]

        LocalMessages.insert({text: "You are currently in " + room.name + ". " + exits + "."})
    else
        console.log "room is undefined...."
        console.log character.currentRoom + " is value of character.currentRoom"
Commands["/inspect"] = (argument) ->
    check(argument, String)
    console.log argument

share.Commands = Commands
