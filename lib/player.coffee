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
            @selectedObserver = selectedCursor.observeChanges(
                added: (id, fields) =>
                    if fields.profile isnt undefined and fields.profile.selected isnt undefined
                        character = Characters.findOne({_id: fields.profile.selected})
                        @_populateData(character)
                    else
                        console.log "fields.profile or fields.profile.selected is undefined in added callback for @selectedObserver"

                changed: (id, fields) =>
                    if fields.profile isnt undefined and fields.profile.selected isnt undefined
                        character = Characters.findOne({_id: fields.profile.selected})
                        @_populateData(character)
                    else
                        console.log "fields.profile or fields.profile.selected is undefined in changed callback for @selectedObserver"
            )

    _populateData: (data) ->
        console.log "populating data for Player class with: " + EJSON.stringify(data)
        for key, value of data
            @[key] = value

    tick: () =>
        super

    


share.Player = Player
