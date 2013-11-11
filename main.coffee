if Meteor.isServer
    share.World = {}
    share.World.Regions = {}
    share.World.Time = () -> new Date().getTime()

    #cursor returned is not limited by publish method. This returns ALL regions in collection.
    regions = Regions.find()
    regions.observeChanges
        added: (id, fields) ->
            console.log "added: " + fields.name
            region = new share.Region(fields)
            share.World.Regions[id] = region
        changed: (id, fields) ->
            console.log EJSON.stringify(fields)

if Meteor.isClient
    share.World = {}
    share.World.Time = () -> new Date().getTime()
    Deps.autorun(()->
        Meteor.subscribe("characters", {
            onError: (err) -> 
                console.log(err.error + " " + err.reason)
        })

        player = Characters.findOne({owner: Meteor.userId()})
        if player?
            Meteor.subscribe("regions", player.currentRoom, {
                onError: (err) -> console.log(err.error + " " + err.reason)
                onReady: () ->
                    region = Regions.findOne({rooms: {$in: [player.currentRoom]}})
                    Meteor.subscribe("rooms", region.name, {onError: (err) -> console.log(err.error + " " + err.reason)})
            })

            # TODO: Replace client-side session time to server-side session time to prevent players from setting
            # custom sessionStart times to retrieve messages from the past.
            console.log player.currentRoom + " is the current room"
            Meteor.subscribe("messages", player.currentRoom, Session.get("sessionStart"), {
                onError: (err) -> 
                    console.log "it seems we have an error"
                onReady: () ->
                    #console.log "messages are ready for: " + player.currentRoom
            })
    )
    ### HELPER FUNCTION ###
    okcancel_events = (selector) ->
        return 'keyup ' +selector+', keydown '+selector+', focusout '+selector

    make_okcancel_handler = (options) ->
        ok = options.ok or ()->
        cancel = options.cancel or ()->

        return (evt) ->
            if evt.type is "keydown" and evt.which is 27
                cancel.call(this, evt)
            else if evt.type is "keyup" and evt.which is 13
                value = String(evt.target.value or "")

                if value
                    ok.call(this, value, evt)
                else
                    cancel.call(this, evt)

    ### BEGIN ROUTER LOGIC ###

    Router.map ->
        @route 'home', path: '/'
        @route 'world', path: '/world', controller: @WorldController
        @route 'character_list', path: '/characters', controller: @CharacterListController
        @route 'character', path: '/characters/:id', controller: @CharacterController, data: {}
        @route 'create_account', path: '/create_account'
        @route 'notfound', path: '*'
    
    class @WorldController extends RouteController
        before: () ->
            if not Meteor.user()
                this.render('sign_in')
                this.stop()
        action: () ->
            this.render()

    class @CharacterListController extends RouteController
        before: () ->
            if not Meteor.user()
                this.render('sign_in')
                this.stop()
        action: () ->
            this.render()

    class @CharacterController extends RouteController
        before: () ->
            if not Meteor.user()
                this.render('sign_in')
                this.stop()
            Session.set("characterId", this.params.id)
        action: () =>
            #console.log this.params.id + " is supposed to be id"
            this.render('character',{id: this.params.id})

    #Template.rooms.helpers(
    #    rooms: -> rooms
    #)
    ### BEGIN TEMPLATE LOGIC ###
    # Template.entry.events = {}

    #Template.entry.events[okcancel_events('#messageBox')] = make_okcancel_handler({
    #    ok: (text, event) ->
    #        nameEntry = $("#name").val()
    #        if nameEntry
    #            ts = Date.now() / 1000
    #            Messages.insert({name: nameEntry, message: text, time: ts})
    #            event.target.value = ""
    #})
if Meteor.isServer
    test = new share.Enemy({name: "Mogdor", hp: 100})
    test.setCooldown(1)
    tick = setInterval(()->
        test.tick()
        clearInterval(this)
    , 1000)
