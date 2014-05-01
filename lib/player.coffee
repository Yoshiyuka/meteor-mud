# #Player
# - - -
# **(extends the Creature class)**  
# Only one Player instance will exist per session for each client. Fields are populated based on data from the Characters collection in the mongo database.  
#Because it is stored in the /lib folder, the Player class is available to both server and client code.
class Player extends share.Creature
    #region Player Constructor
    constructor: () ->
        super
        # ###Client-Only Code:  
        # Only run the following code if the file is loaded client-side. Server will ignore this.
        if Meteor.isClient
            console.log "Player constructor has been called. Attempting to subscribe to relevant collections..."
            console.log @currentRoom

            @Inventory = new share.Inventory(this, 16)
            @Equipment = new share.Equipment(this)

            @Inventory.addItem({_id: 999, text: "test object"}, 4)
            console.log @Inventory.count()
            console.log @Equipment.count()
            @Equipment.equip({name: "test item", slot: "left_earring"}, "left earring")
            console.log @Equipment.count()
            @Equipment.equip({name: "other test item"}, "helm")
            console.log @Equipment.count()
            
            # *The instantiation of the Player class indicates that the client is signed in and has selected a character to play with. This means it's safe to subscribe to the world-related collections...*
            
            # Subscribe to the Regions collection. When the collection is ready, look up the current region the Player is in based on its current room and then subscribe to the Rooms collection.
            Meteor.subscribe("regions", @currentRoom, {
                onReady: () =>
                    region = Regions.findOne({rooms: {$in: [@currentRoom]}})
                    
                    Meteor.subscribe("rooms", region.name, {
                        onError: (err) -> 
                            console.log err.error + " " + err.reason
                        onReady: () ->
                            console.log "subscribing to rooms for " + region.name
                    })
            })

            # Subscribe to the Messages collection. sessionStart returns client's time to filter out old messages we weren't connected to the server to see.
            Meteor.subscribe("messages", @currentRoom, Session.get("sessionStart"), {
                onError: (err) ->
                    console.log "it seems we have an error in Player.constructor"
                onReady: () =>
                    console.log "subscribing to messages for " + @currentRoom
            })

            
            # Begin observing the user document matching the client's id. Any changes to the user document will trigger an appropriate observer event.
            selectedCursor = Meteor.users.find({_id: Meteor.userId()})
            playerCursor = undefined
            @selectedObserver = selectedCursor.observeChanges(
                # When the user document is first found, this will be triggered. An observer will be created to watch the character matching the selected character id. Any changes to the watched character data in the database will cause the client's Player class instance to be repopulated with the new document data.
                added: (id, fields) =>
                    if fields.profile isnt undefined and fields.profile.selected isnt undefined
                        character = Characters.findOne({_id: fields.profile.selected})
                        @_populateData(character)

                        playerCursor = Characters.find({_id: @_id, owner: @owner})
                        console.log @_id + " " + @owner
                        @playerObserver = playerCursor.observeChanges(
                            added: (id, fields) =>
                                @_populateData(fields)
                            changed: (id, fields) =>
                                @_populateData(fields)
                        )
                    else
                        console.log "fields.profile or fields.profile.selected is undefined in added callback for @selectedObserver"

                # #TODO:CHECK FOR EXISTANCE OF THE OBSERVER FIRST AT BEGINNING OF EVENT AND STOP IT BEFORE STARTING A NEW ONE! THIS IS A MEMORY LEAK THAT NEEDS TO BE ADDRESSED!!!

                # When the profile.selected field in the user document is altered, this 'changed' event will be triggered. This gets the data for the character matching the id in the profile.selected field and then creates an observer to watch the new character document. Any changes to that document will trigger a repopulation of this Player class instance's data. 
                changed: (id, fields) =>
                    if fields.profile isnt undefined and fields.profile.selected isnt undefined
                        character = Characters.findOne({_id: fields.profile.selected})
                        @_populateData(character)

                        if @playerObserver?
                            @playerObserver.stop()
                            playerCursor = Characters.find({_id: @_id, owner: @owner})
                            console.log @_id + " " + @owner
                            @playerObserver = playerCursor.observeChanges(
                                added: (id, fields) =>
                                    @_populateData(fields)
                                changed: (id, fields) =>
                                    @_populateData(fields)
                            )
                        else
                            console.log "playerObserver is invalid"
                    else
                        console.log "fields.profile or fields.profile.selected is undefined in changed callback for @selectedObserver"
            )
    #endregion

    # **_populateData(Object)** - Helper function which adds/sets the fields of the Player class instance of those provided by 'data'
    _populateData: (data) =>
        for key, value of data
            @[key] = value

#region Movement Code
    # **moveTo(String)** - 
    # Checks to make sure that the player is both in a valid room (should always be true) and that the direction the player wants to go towards exists in the current room (rooms must be attached). 
    moveTo: (direction) ->
        check(direction, String)

        if @currentRoom is undefined
            console.log "current room is undefined, somehow.... no valid moves from this location."
            return

        room = Rooms.findOne({name: @currentRoom})
        if room? and room[direction]?
            console.log direction + " appears to be a valid move. Attempting move..."
            time = undefined
            
            # **Send an asynchronous call to the server code so that the server can validate intentions and perform the database updates. We absolutely do not allow clients to modify the database directly.**
            Meteor.call("validateAndMove", @currentRoom, room[direction], (error, result) ->
                if(error)
                    console.log error.err + " " + error.reason
                else
                    time = result
            )

            Session.set("sessionStart", time)
        else
            LocalMessages.insert({text: "That appears to be a dead end."})
#endregion

    tick: () =>
        super

    

# **Make the Player class available to all CoffeeScript files.**
share.Player = Player
