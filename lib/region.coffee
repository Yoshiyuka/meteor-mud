# ##Room
# - - -
# A Room is the smallest building block of a Region. Connects to up to 4 other Rooms (North/South/East/West). 
# Connect one of these directions to a Portal room type to provide a wider range of rooms to jump to.                           
class Room
    constructor: (room_document) ->
        #copy room_document fields to Room instance properties
        for key, value of room_document
            @[key] = value

        @npcs = {}
        @loot = {}

        console.log "new room created: " + @name + "!"
    
    enter: () ->
        player = getPlayer()
        if player?
            Rooms.update({name: @name}, {$addToSet: {players: player.name}})
            Characters.update({_id: player._id, owner: player.owner}, {$set: {currentRoom: @name}})

    leave: () ->
        player = getPlayer()
        if player?
            Rooms.update({name: @name}, {$pull: {players: player.name}})
            Messages.insert({text: player.name + " has left the room.", broadcastTo: @name, ignore: player.owner, sender: player.owner, timestamp: share.World.Time()})

    validMove: (destination) ->
        return true

    # **changed(Object)** - Update old properties with new from changed fields.
    changed: (fields) ->
        for key, value of fields
            console.log "OLD: "
            console.log @[key]
            @[key] = value
            console.log "NEW: "
            console.log @[key]

    # **tick(void)** - Update function. Reduces cooldown count and executues queued (if any) functions.
    tick: () ->
        #if max room item count isn't met, try spawning max_item_count-N items.
        if @items isnt undefined
            for item in @items
                @spawnEntity(item)

    spawnEntities = () ->

    # **spawnEntity(Object)** - Given an object, roll dice to see if we should add the object data to our loot array. 
    # **In the future this will actually do something useful and handle spawning of enemies, items, and things such as temporary doors.**
    spawnEntity: (entity) ->
        roll = Random.fraction() * 101
        if roll <= entity.spawnChance
            item = Items.findOne({name: entity.name})
            console.log "spawning: " + item.name + " in " + @name
            @loot[item._id] = item
        

    getPlayer = () ->
        player = Characters.findOne({_id: Meteor.user().profile.selected, owner: Meteor.userId()})
        if player? 
            return player
        else
            console.log new Meteor.Error(930, "No characters owned by user.")

# ##Portal
# - - -
# A Portal is a Room that has more than 4 possible exits (North/West/South/East) and can exit into any other room
# (even to itself)                                                                                                              
class Portal extends Room
    constructor: (portal_document) ->
        console.log "portal created"

    enter: (destination) ->
        console.log "entering " + destination + " via portal!"
        super destination

# ##Region
# - - -
# A Region is the (current) largest abstraction of the world. It is composed of a series of Rooms. Controls World macro-effects
# Such as Weather, Factions, Currency, Language, etc. across all contained Rooms. Rooms can override these values.              
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
                    @rooms[id].changed(fields)
            )

        # **World update loop. Fires region's tick method.
        # Each tick triggers the tick methods of every room in the region which, in turn, triggers the tick methods of all creatures, entities, etc. which are in each room.**
        Meteor.setInterval(
            () =>  #@tick()
        , 5000)

    # **tick(void)** - Region's update method. Triggers a cascade of ticks across all rooms and their entities.
    tick: () ->
        console.log "calling tick in region: " + @name
        for id,room of @rooms
            room.tick()

share.Region = Region
