#-------------------------------------------------------------------------------------------------------------------------------#
# A Room is the smallest building block of a Region. Connects to up to 4 other Rooms (North/South/East/West).                   # 
# Connect one of these directions to a Portal room type to provide a wider range of rooms to jump to.                           #
#-------------------------------------------------------------------------------------------------------------------------------#
class Room
    constructor: (room_document) ->
        #copy room_document fields to Room instance properties
        for key, value of room_document
            @[key] = value

        console.log "new room created: " + @.name + "!"
    
    enter: () ->
        player = getPlayer()
        if player?
            # Regions.update({'rooms.name': destination}, {$addToSet: {'rooms.$.players': {name: player.name}}})
            #Messages.insert({text: player.name + " has entered the room.", broadcastTo: destination, sender: Meteor.userId(), timestamp: new Date().getTime()})
            #Characters.update({owner: Meteor.userId()}, {$set: {currentRoom: destination}})
            #Messages.insert({text: player.name + " has left the room.", broadcastTo: previousRoom, sender: player._id, timestamp: new Date().getTime()})
            console.log @name + " has called enter()"


    leave: () ->
        console.log @name + " has called leave()"

    validMove: (destination) ->
        return true

    print: () ->
        console.log EJSON.stringify(@)
    changed: (fields) ->
        #update old properties with new from changed fields.
        for key, value of fields
            console.log "OLD: "
            console.log @[key]
            @[key] = value
            console.log "NEW: "
            console.log @[key]

    getPlayer = () ->
        player = Characters.findOne({owner: Meteor.userId()})
        if player? 
            return player
        else
            console.log new Meteor.Error(930, "No characters owned by user.")

#-------------------------------------------------------------------------------------------------------------------------------#
# A Portal is a Room that has more than 4 possible exits (North/West/South/East) and can exit into any other room               #
# (even to itself)                                                                                                              #
#-------------------------------------------------------------------------------------------------------------------------------#
class Portal extends Room
    constructor: (portal_document) ->
        console.log "portal created"

    enter: (destination) ->
        console.log "entering " + destination + " via portal!"
        super destination

#-------------------------------------------------------------------------------------------------------------------------------#
# A Region is the (current) largest abstraction of the world. It is composed of a series of Rooms. Controls World macro-effects #
# Such as Weather, Factions, Currency, Language, etc. across all contained Rooms. Rooms can override these values.              #
#-------------------------------------------------------------------------------------------------------------------------------#
class Region
    constructor: (region_document) ->
        if region_document.name?
            @name = region_document.name
            @roomCursor = Rooms.find({region: @name})
            @rooms = {}
            @roomObserver = @roomCursor.observeChanges(
                added: (id, fields) =>
                    console.log @name + " has added a new room: " + fields.name
                    if fields.type is "portal"
                        room = new Portal(fields)
                    else
                        room = new Room(fields)

                    @rooms[id] = room

                changed: (id, fields) =>
                    console.log @name + " had updated room: " + EJSON.stringify(fields)
                    @rooms[id].changed(fields)
            )

share.Region = Region
