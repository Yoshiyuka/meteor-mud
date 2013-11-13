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



    tick: () =>
        super

    


share.Player = Player
