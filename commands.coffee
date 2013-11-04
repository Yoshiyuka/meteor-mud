Commands = {}
Commands["/say"] = (argument) -> Meteor.call("say", argument, (error, result) -> )
Commands["/yell"] = (argument) -> Meteor.call("yell", argument, (error, result) -> )
Commands["/y"] = Commands["/yell"] #alias command for yell
Commands["/go"] = (argument)  -> Meteor.call("enterRoom", argument, (error, result) -> )
#cardinal direction alias commands
Commands["/north"] = () -> Meteor.call("moveTo", "north", (error, result) -> )
Commands["/south"] = () ->  Meteor.call("moveTo", "south", (error, result) -> )
Commands["/east"] = () ->  Meteor.call("moveTo", "east", (error, result) -> )
Commands["/west"] = () ->  Meteor.call("moveTo", "west", (error, result) -> )

share.Commands = Commands
