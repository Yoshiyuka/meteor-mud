Commands = {}

Commands["/say"] = (argument) -> say(argument)
Commands["/yell"] = (argument) -> yell(argument)
Commands["/y"] = Commands["/yell"] #alias command for yell

Commands["/go"] = (argument)  -> Meteor.call("enterRoom", argument, (error, result) -> Session.set("sessionStart", share.World.Time() ))
Commands["/north"] = () ->
    Meteor.call("moveTo", "north", (error, result) ->  Session.set("sessionStart", result))
Commands["/south"] = () -> 
    Meteor.call("moveTo", "south", (error, result) ->  Session.set("sessionStart", result))
Commands["/east"] = () ->  
    Meteor.call("moveTo", "east", (error, result) ->  Session.set("sessionStart", result) )
Commands["/west"] = () ->  
    Meteor.call("moveTo", "west", (error, result) ->   Session.set("sessionStart", result))
#alias commands for cardinal direction movement
Commands["/n"] = Commands["/north"]
Commands["/s"] = Commands["/south"]
Commands["/e"] = Commands["/east"]
Commands["/w"] = Commands["/west"]
Commands["/look"] = () ->
    #will want to generate a description on the fly later on
    character = Characters.findOne({owner: Meteor.userId(), selected: 1})
    if character isnt undefined
        room = Rooms.findOne({name: character.currentRoom})

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
Commands["/inspect"] = (argument) ->
    check(argument, String)
    console.log argument

say = (argument) -> 
    check(argument, String)
    
    player = Characters.findOne({owner: Meteor.userId(), selected: 1})
    if not player?
        console.log("no player")
    else
        if player.currentRoom isnt undefined
            Messages.insert({text: player.name + " says: " + argument, broadcastTo: player.currentRoom, sender: Meteor.userId(), timestamp: share.World.Time()})

yell = (argument) ->
    check(argument, String)

    player = Characters.findOne({owner: Meteor.userId(), selected: 1})
    if not player?
        console.log("no player")
    else if player.currentRoom isnt undefined
        region = Regions.findOne({'rooms': {$in: [player.currentRoom]}}).name
        if region isnt undefined
            Messages.insert({text: player.name + " yells: " + argument, broadcastTo: region, sender: Meteor.userId(), timestamp: share.World.Time()})
        else
            console.log("unable to broadcast yell to region: " + region)

share.Commands = Commands
