class Player extends share.Creature
    constructor: () ->
        super
        if Meteor.isClient
            console.log "Player constructor has been called. Attempting to subscribe to relevant collections..."
            console.log @currentRoom
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

            Meteor.subscribe("messages", @currentRoom, Session.get("sessionStart"), {
                onError: (err) ->
                    console.log "it seems we have an error in Player.constructor"
                onReady: () =>
                    console.log "subscribing to messages for " + @currentRoom
            })

            selectedCursor = Meteor.users.find({_id: Meteor.userId()})
            playerCursor = undefined
            @selectedObserver = selectedCursor.observeChanges(
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


    _populateData: (data) =>
        for key, value of data
            @[key] = value

    moveTo: (direction) ->
        check(direction, String)

        if @currentRoom is undefined
            console.log "current room is undefined, somehow.... no valid moves from this location."
            return

        room = Rooms.findOne({name: @currentRoom})
        if room? and room[direction]?
            console.log direction + " appears to be a valid move. Attempting move..."
            time = undefined
            Meteor.call("validateAndMove", @currentRoom, room[direction], (error, result) ->
                if(error)
                    console.log error.err + " " + error.reason
                else
                    time = result
            )

            Session.set("sessionStart", time)
        else
            LocalMessages.insert({text: "That appears to be a dead end."})

    tick: () =>
        super

    


share.Player = Player
