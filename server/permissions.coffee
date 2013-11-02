Meteor.publish("regions", () ->
    player = Characters.findOne({owner: this.userId})
    if not player?
        this.error(new Meteor.Error(930, "No characters owned by user."))
    else
        #console.log(player.currentRoom)
        return Regions.find({'rooms.name': {$in: [player.currentRoom]}})
)

Meteor.publish("messages", (currentRoom, timestamp) ->
    if not currentRoom?
        this.error(new Meteor.Error(950, "argument to publish is null"))
    else
        region = Regions.findOne({'rooms.name': {$in: [currentRoom]}}).name

    if not region? 
        this.error(new Meteor.Error(990, "Malformed or invalid region. Unable to subscribe to messages."))
        return #early out

    #console.log("broadcasting messages to: " + broadcast)
        
    #broadcastTo: global -> all players will receive these messages in published data
    #broadcastTo: regionName -> only players in specified region will receive these messages in published data
    #broadcastTo: roomName -> only players in specified room will receive these messages in published data
    return Messages.find({timestamp: {$gt: timestamp}, broadcastTo: {$in: [ "global", region, currentRoom ] }})
)

Meteor.publish("characters", ()->
    user = Meteor.users.findOne(this.userId)
    #console.log(this.userId)
    if user?
        #console.log("return characters")
        return Characters.find({owner: this.userId})
    else
        this.error(new Meteor.Error(920, "User is unknown! Can't return character data."))
)

#Regions.allow({
#    update: (userId, doc, fieldNames, modifier) ->
#        return true
#})

Messages.allow({
    insert: (userId, doc) -> 
        return true
})

Characters.allow({
    insert: (userId, doc) ->
        return (userId and doc.owner is userId)

    remove: (userId, doc) ->
        return (userId and doc.owner is userId)
})
Characters.deny({
    update: (userId, doc, fieldNames, modifier) -> 
        return true #must deny all client side updates of character. Do updates server-side.
})

#Insert/Update/Remove Methods to keep specific database actions server-side only.
Meteor.methods(
    enterRoom: (destination) -> 
        check(destination, String)

        #room = share.Room

        #return room.enter(destination)

    say: (argument) -> 
        check(argument, String)
        
        player = Characters.findOne({owner: this.userId})
        if not player?
            console.log("no player")
        else
            if player.currentRoom isnt undefined
                Messages.insert({text: player.name + " says: " + argument, broadcastTo: player.currentRoom, sender: this.userId, timestamp: new Date().getTime()})
    
    yell: (argument) ->
        check(argument, String)

        player = Characters.findOne({owner: this.userId})
        if not player?
            console.log("no player")
        else if player.currentRoom isnt undefined
            region = Regions.findOne({'rooms.name': player.currentRoom}).name
            if region isnt undefined
                Messages.insert({text: player.name + " yells: " + argument, broadcastTo: region, sender: this.userId, timestamp: new Date().getTime()})
            else
                console.log("unable to broadcast yell to region: " + region)
)
