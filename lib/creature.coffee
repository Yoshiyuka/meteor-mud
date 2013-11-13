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

    say: (message) ->
        if @currentRoom  isnt undefined
            Messages.insert({text: @name + " says: " + message, broadcastTo: @currentRoom, sender: @owner, timestamp: share.World.Time()})
        else
            console.log @_id + ": Can't say to room as currentRoom is undefined. Value: " + @currentRoom

    yell: (message) ->
        if @currentRoom isnt undefined
            region = Rooms.findOne({name: @currentRoom}).region
            
            if region isnt undefined
                Messages.insert({text: @name + " yells: " + message, broadcastTo: region, sender: @owner, timestamp: share.World.Time()})
            else
                console.log @_id + ": Can't yell to region as region is undefined. Value: " + region
        else
            console.log @_id + ": Can't yell to region as currentRoom is undefined. Value: " + @currentRoom

        

share.Creature = Creature
