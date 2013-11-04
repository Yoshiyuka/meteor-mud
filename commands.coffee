Commands = {}

Commands["/say"] = (argument) -> Meteor.call("say", argument, (error, result) -> )
Commands["/yell"] = (argument) -> Meteor.call("yell", argument, (error, result) -> )
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

share.Commands = Commands
