Meteor.publish("regions", (currentRoom) ->
    if not currentRoom?
        this.error new Meteor.Error(950, "argument to publish is null")
    else
        #console.log(player.currentRoom)
        return Regions.find({rooms: {$in: [currentRoom]}})
)

Meteor.publish("rooms", (region) ->
    if not region? 
        this.error new Meteor.Error(990, "Malformed or invalid region.")
    else
        return Rooms.find({region: region})
)

Meteor.publish("messages", (roomName, timestamp) ->
    if not roomName?
        this.error(new Meteor.Error(950, "argument to publish is null"))
    else
        regionName = Regions.findOne({rooms: {$in: [roomName]}}).name

    if not regionName? 
        this.error(new Meteor.Error(990, "Malformed or invalid region. Unable to subscribe to messages."))
        return #early out
        
    #broadcastTo: global -> all players will receive these messages in published data
    #broadcastTo: regionName -> only players in specified region will receive these messages in published data
    #broadcastTo: roomName -> only players in specified room will receive these messages in published data
    return Messages.find({timestamp: {$gt: timestamp}, broadcastTo: {$in: [ "global", regionName, roomName ] }})
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
