# #permissions.coffee
# Controls client ability to access and modify server data.

# ###Publish Methods
# - - -

# Regions publisher. Only returns a cursor to a region which contains the room provided in the 'currentRoom' parameter.
Meteor.publish("regions", (currentRoom) ->
    if not currentRoom?
        this.error new Meteor.Error(950, "argument to publish is null")
    else
        return Regions.find({rooms: {$in: [currentRoom]}})
)

# Rooms publisher. Returns a cursor containing all rooms which are part of the region provided by the 'region' parameter.
Meteor.publish("rooms", (region) ->
    if not region? 
        this.error new Meteor.Error(990, "Malformed or invalid region.")
    else
        return Rooms.find({region: region})
)

# Messsages publisher. Returns a cursor containing all messages that are more recent than 'timestamp' 
# and which the broadcastTo value of the message is global or matches either the region or room that the player is in. 
Meteor.publish("messages", (roomName, timestamp) ->
    if not roomName?
        this.error(new Meteor.Error(950, "argument to publish is null"))
    else
        regionName = Rooms.findOne({name: roomName}).region

    if not regionName?
        this.error(new Meteor.Error(990, "Malformed or invalid region. Unable to subscribe to messages."))
        return #early out
        
    # ^ broadcastTo: global -> all players will receive these messages in published data
    # ^ broadcastTo: regionName -> only players in specified region will receive these messages in published data
    # ^ broadcastTo: roomName -> only players in specified room will receive these messages in published data
    return Messages.find({timestamp: {$gt: timestamp}, broadcastTo: {$in: [ "global", regionName, roomName ] }, ignore: {$ne: this.userId}})
)

# Characters publisher. Returns a cursor containing all character documents belonging to the logged in user. 
Meteor.publish("characters", (userId)->
    user = Meteor.users.findOne(userId)
    if user?
        return Characters.find({owner: userId})
    else
        this.error(new Meteor.Error(920, "User is undefined. Unable to return data."))
)

# Publish data for inventory for the client's currently selected character.
Meteor.publish("inventory", () ->
    if Meteor.user?
        selected = Meteor.user.profile.selected
        console.log "selected is #{selected}"
        return Inventory.find({owner: selected})
    else
        throw new Meteor.Error(920, "User is undefined. Unable to return data.")
)

Meteor.publish("userData", () ->
    return Meteor.users.find({_id: this.userId}, {fields: {'selected': 1}})
)

#region Allow/Deny Methods
# ###Allow/Deny Methods
# - - -

Accounts.onCreateUser((options, user) ->
    user.profile = {}
    user.profile.selected = undefined

    return user
)

# Allow settings for Messages collection.
Messages.allow({
    insert: (userId, doc) -> 
        return userId and doc.sender is userId
})

# Allow settings for Characters collection.
Characters.allow({
    insert: (userId, doc) ->
        return (userId and doc.owner is userId)

    remove: (userId, doc) ->
        return (userId and doc.owner is userId)
})

# Deny settings for Inventory collection.
Inventory.deny({
    insert: (userId, doc) ->
        return true
    update: (userId, doc) ->
        return true
    remove: (userId, doc) ->
        return true
    })
# Deny settings for Characters collection.
Characters.deny({
    # deny updates by client. **updates must be done through server-side code only.**
    update: (userId, doc) ->
        return true
})
#endregion

# ###Meteor.methods
# Server methods callable from the client through Meteor.call("method_name", parameters, callback)
# - - -

Meteor.methods(
#region Movement Methods
    # * **validateAndMove(String, String)** - attempts to move currently selected character from one room to another. Checks to see if the move is valid before performing the move.
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
                    # call Room.enter() and Room.leave() which not only updates the Rooms collection, but updates the Character collection as well.  
                    # This needs to be reconsidered and most definitely refactored. **Rooms should not be responsible for character data!**
                    targetIndex.enter()
                    currentIndex.leave()

                    time = share.World.Time()

                    return time
            else
                console.log EJSON.stringify(region) + " " + EJSON.stringify(currentRoom) + " " + EJSON.stringify(targetRoom)
#endregion

    # * **print(void)** - Triggers dumping of values to server log. Debug function for developer. 
    print: () ->
        player = Characters.findOne({owner: this.userId})
        region = Regions.findOne({rooms: {$in: [player.currentRoom]}})
        currentRoom = Rooms.findOne({name: player.currentRoom})

        currentIndex = share.World.Regions[region._id].rooms[currentRoom._id]
        currentIndex.print()

#region Character Methods
    # * **createCharacter(String)** - Creates a new character document in the Characters collection with some pre-determined values. 
    createCharacter: (name) ->
        check(name, String)
        if name.length < 3 or name.length > 16
            throw new Meteor.Error(8, "Invalid name length submitted to createCharacter method.")
        if not /^[A-Za-z]+$/.test(name)
            throw new Meteor.Error(9, "Name can only contain alphabetical characters.")
        if Characters.findOne({name: name}) isnt undefined
            throw new Meteor.Error(10, "Character already exists.")

        query = Characters.insert({name: name, skills: [], level: 1, vitality: 1, strength: 1, dexterity: 1, charisma: 1, intelligence: 1, luck: 1, health: 100, maxHealth: 100, mana: 100, maxMana: 100, played: 0, owner: this.userId, currentRoom: "Central Area of the Marsh", selected: 0})

        console.log query
        return query

    # * **selectCharacter(String)** - Sets the user's 'selected' field to the specified id. This triggers changes which observers watching this field will see. 
    # This will cause the observers to force updates on objects which depend on the data of the document matching the selected id.
    selectCharacter: (id) ->
        check(id, String)
        Meteor.users.update({_id: this.userId}, {$set: {profile: {selected: id}}})
#endregion
#
# Temporary Meteor methods to update character data to see character UI update in real-time rather than wait on Mongo shell.     
    setHealth: (argument) ->
        player = Characters.findOne({owner: this.userId, selected: 1})
        Characters.update({_id: player._id}, {$set: {health: argument}})

    setMana: (argument) ->
        player = Characters.findOne({owner: this.userId, selected: 1})
        Characters.update({_id: player._id}, {$set: {mana: argument}})
)
