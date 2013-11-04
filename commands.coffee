Commands = {}
Commands["/say"] = (argument) -> Meteor.call("say", argument, (error, result) -> )
Commands["/yell"] = (argument) -> Meteor.call("yell", argument, (error, result) -> )
Commands["/y"] = Commands["/yell"] #alias command for yell
Commands["/go"] = (argument)  -> Meteor.call("enterRoom", argument, (error, result) -> )
#cardinal direction alias commands
Commands["/north"] = () -> Commands["/go"]("north")
Commands["/south"] = () -> Commands["/go"]("south")
Commands["/east"] = () -> Commands["/go"]("east")
Commands["/west"] = () -> Commands["/go"]("west")

share.Commands = Commands
