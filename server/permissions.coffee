Meteor.publish("regions", (currentRoom) ->
    if not currentRoom?
        this.error new Meteor.Error(950, "argument to publish is null")
    else
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
        regionName = Rooms.findOne({name: roomName}).region

    if not regionName?
        this.error(new Meteor.Error(990, "Malformed or invalid region. Unable to subscribe to messages."))
        return #early out
        
    #broadcastTo: global -> all players will receive these messages in published data
    #broadcastTo: regionName -> only players in specified region will receive these messages in published data
    #broadcastTo: roomName -> only players in specified room will receive these messages in published data
    return Messages.find({timestamp: {$gt: timestamp}, broadcastTo: {$in: [ "global", regionName, roomName ] }, ignore: {$ne: this.userId}})
)

Meteor.publish("characters", ()->
    user = Meteor.users.findOne(this.userId)
    if user?
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
    
        player = Characters.findOne({owner: this.userId})
        if player? 
            #Find the region so we can index into the dictionary of room objects.
            region = Regions.findOne({rooms: {$in: [player.currentRoom]}})
            currentRoom = Rooms.findOne({name: player.currentRoom})
            targetRoom = Rooms.findOne({name: destination})

        if region? and currentRoom? and targetRoom?
            currentIndex = share.World.Regions[region._id].rooms[currentRoom._id]
            targetIndex = share.World.Regions[region._id].rooms[targetRoom._id]

            validMove = currentIndex.validMove(destination)
            if validMove
                #these should be character commands. ie. player.leave(room), player.enter(destination)
                targetIndex.enter()
                currentIndex.leave()
               
                time = share.World.Time()
                #return time of execution on success
                return time
            else
                console.log "Can't move to " + destination + " from " + currentRoom
        else
            console.log region + " " + currentRoom + " " + targetRoom
      
    moveTo: (direction) ->
        check(direction, String)

        player = Characters.findOne({owner: this.userId})
        if player?
            room = Rooms.findOne({name: player.currentRoom})

        if room? 
            directions = {}
            directions["north"] = room.north
            directions["south"]= room.south
            directions["east"] = room.east
            directions["west"] = room.west

        if not (direction of directions)
            console.log "direction not valid"
            return #early out
        else if directions[direction]?
            time = undefined
            Meteor.call("enterRoom", directions[direction], (error, result) ->  
                console.log result + " is the time in async callback"
                time = result)
            console.log "returned time: " + time
            #return time of execution on success
            return time
        else
            console.log "Dead End. Can't move to null location."

    print: () ->
        player = Characters.findOne({owner: this.userId})
        region = Regions.findOne({rooms: {$in: [player.currentRoom]}})
        currentRoom = Rooms.findOne({name: player.currentRoom})

        currentIndex = share.World.Regions[region._id].rooms[currentRoom._id]
        currentIndex.print()

    say: (argument) -> 
        check(argument, String)
        
        player = Characters.findOne({owner: this.userId})
        if not player?
            console.log("no player")
        else
            if player.currentRoom isnt undefined
                Messages.insert({text: player.name + " says: " + argument, broadcastTo: player.currentRoom, sender: this.userId, timestamp: share.World.Time()})
    
    yell: (argument) ->
        check(argument, String)

        player = Characters.findOne({owner: this.userId})
        if not player?
            console.log("no player")
        else if player.currentRoom isnt undefined
            region = Regions.findOne({'rooms': {$in: [player.currentRoom]}}).name
            if region isnt undefined
                Messages.insert({text: player.name + " yells: " + argument, broadcastTo: region, sender: this.userId, timestamp: share.World.Time()})
            else
                console.log("unable to broadcast yell to region: " + region)
    createCharacter: (name) ->
        if Characters.findOne({name: name}) isnt undefined
            console.log name + " already exists. Bailing early."
            return

        Characters.insert({name: name, skills: [], level: 1, vitality: 1, strength: 1, dexterity: 1, charisma: 1, intelligence: 1, luck: 1, health: 100, maxHealth: 100, mana: 100, maxMana: 100, played: 0, owner: this.userId})
#--------------------------------------------------------------------------------------------------------------------------------#
# Temporary Meteor methods to update character data to see character UI update in real-time rather than wait on Mongo shell.     #
#--------------------------------------------------------------------------------------------------------------------------------#
    setHealth: (argument) ->
        player = Characters.findOne({owner: this.userId})
        Characters.update({_id: player._id}, {$set: {health: argument}})

    setMana: (argument) ->
        player = Characters.findOne({owner: this.userId})
        Characters.update({_id: player._id}, {$set: {mana: argument}})


)
