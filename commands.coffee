Commands = {}
Commands["/say"] = (argument) -> Meteor.call("say", argument, (error, result) -> )
Commands["/yell"] = (argument) -> Meteor.call("yell", argument, (error, result) -> )
Commands["/y"] = Commands["/yell"] #alias command for yell

share.Commands = Commands
