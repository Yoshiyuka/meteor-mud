class Creature
    constructor: (@options) ->
        for key,option of options
            @[key] = option
        @cooldown = 0

    tick: () ->
        #decrease cooldown if not 0. Action will be performed on next tick.
        if @cooldown > 0
            console.log "decreasing cooldown timer"
            @cooldown--
            return

        console.log @name + " thought of doing something."

    setCooldown: (value) ->
        @cooldown = value
        

share.Creature = Creature
