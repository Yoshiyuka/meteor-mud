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

Meteor.publish("userData", () ->
    return Meteor.users.find({_id: this.userId}, {fields: {'selected': 1}})
)
#Regions.allow({
#    insert: (userId, doc) ->
#        return true
#    update: (userId, doc) ->
#        return true
#})
#Rooms.allow({
#    insert: (userId, doc) ->
#        return true
#    update: (userId, doc) ->
#        return true
#})
Messages.allow({
    insert: (userId, doc) -> 
        return userId and doc.sender is userId
})

Characters.allow({
    insert: (userId, doc) ->
        return (userId and doc.owner is userId)

    remove: (userId, doc) ->
        return (userId and doc.owner is userId)
})

Characters.deny({
    #deny updates by client. updates must be done through server-side code only.
    update: (userId, doc) ->
        return true
})

#Insert/Update/Remove Methods to keep specific database actions server-side only.
Meteor.methods(
    validateAndMove: (from, to) ->
        check(from, String)
        check(to, String)

        console.log this.userId
        console.log Meteor.user().profile.selected
        player = Characters.findOne({_id: Meteor.user().profile.selected})
        if player is undefined
            console.log "oh shit"
        if player?
            if from isnt player.currentRoom
                throw new Meteor.Error(6,"Server's view of player's current room does not match Client's view. This move is not valid.")
            
            region = Regions.findOne({rooms: {$in: [player.currentRoom]}})
            currentRoom = Rooms.findOne({name: from})
            targetRoom = Rooms.findOne({name: to})
            console.log to

            if region? and currentRoom? and targetRoom?
                currentIndex = share.World.Regions[region._id].rooms[currentRoom._id]
                targetIndex = share.World.Regions[region._id].rooms[targetRoom._id]

                if not currentIndex.validMove(to)
                    throw new Meteor.Error(7, "Destination: " + to + " doesn't seem to be connected to current room: " + from + ". This is an invalid move attempt.")
                else

                    targetIndex.enter()
                    currentIndex.leave()

                    time = share.World.Time()

                    return time
            else
                console.log EJSON.stringify(region) + " " + EJSON.stringify(currentRoom) + " " + EJSON.stringify(targetRoom)

    print: () ->
        player = Characters.findOne({owner: this.userId})
        region = Regions.findOne({rooms: {$in: [player.currentRoom]}})
        currentRoom = Rooms.findOne({name: player.currentRoom})

        currentIndex = share.World.Regions[region._id].rooms[currentRoom._id]
        currentIndex.print()


    createCharacter: (name) ->
        if Characters.findOne({name: name}) isnt undefined
            console.log name + " already exists. Bailing early."
            return

        Characters.insert({name: name, skills: [], level: 1, vitality: 1, strength: 1, dexterity: 1, charisma: 1, intelligence: 1, luck: 1, health: 100, maxHealth: 100, mana: 100, maxMana: 100, played: 0, owner: this.userId, currentRoom: "Central Area of the Marsh", selected: 0})

    selectCharacter: (id) ->
        check(id, String)
        Meteor.users.update({_id: this.userId}, {$set: {profile: {selected: id}}})


#--------------------------------------------------------------------------------------------------------------------------------#
# Temporary Meteor methods to update character data to see character UI update in real-time rather than wait on Mongo shell.     #
#--------------------------------------------------------------------------------------------------------------------------------#
    setHealth: (argument) ->
        player = Characters.findOne({owner: this.userId, selected: 1})
        Characters.update({_id: player._id}, {$set: {health: argument}})

    setMana: (argument) ->
        player = Characters.findOne({owner: this.userId, selected: 1})
        Characters.update({_id: player._id}, {$set: {mana: argument}})
)
