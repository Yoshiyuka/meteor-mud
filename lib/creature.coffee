# #Creature
# - - -
# Base class that Players, NPCs, and Enemies are derived from. Represents a creature entity in the game world. 
class Creature
    constructor: (options) ->
        for key,option of options
            @[key] = option
        @cooldown = 0

    tick: () =>
        #decrease cooldown if not 0. Action will be performed on next tick.
        if @cooldown > 0
            console.log "decreasing cooldown timer"
            @cooldown--
            return

        console.log @name + " thought of doing something."

    setCooldown: (value) ->
        @cooldown = value

# ###Communication Methods: 

# **say(String)** - allows the creature to send a message to the current room it is in.

    say: (message) ->
        if @currentRoom  isnt undefined
            # * Inserts the document into the client-side minimongo database which is then attempted to sync with the server database.
            Messages.insert({text: @name + " says: " + message, broadcastTo: @currentRoom, sender: @owner, timestamp: share.World.Time()})
        else
            console.log @_id + ": Can't say to room as currentRoom is undefined. Value: " + @currentRoom

# **yell(String)** - allows the creature to send a message to all rooms in the current region that it is in.
    yell: (message) ->
        if @currentRoom isnt undefined
            region = Rooms.findOne({name: @currentRoom}).region
            
            if region isnt undefined
                # * Inserts the document into the client-side minimongo database which is then attempted to sync with the server database.
                Messages.insert({text: @name + " yells: " + message, broadcastTo: region, sender: @owner, timestamp: share.World.Time()})
            else
                console.log @_id + ": Can't yell to region as region is undefined. Value: " + region
        else
            console.log @_id + ": Can't yell to region as currentRoom is undefined. Value: " + @currentRoom

        
# **Make the Creature class available to all .coffee files in the project.**
share.Creature = Creature
