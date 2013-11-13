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

    Meteor.subscribe("characters", {
        onError: (err) ->
            console.log err.error + " " + err.reason
        onReady: () ->
            selectedCharacterId = Meteor.user().profile.selected
            character = Characters.findOne({_id: selectedCharacterId})

            if character isnt undefined
                share.World.Player = new share.Player(character)
    })
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
        @route 'home', path: '/', action: () -> setNavigationPill(this.path)
        @route 'world', path: '/world', controller: @WorldController
        @route 'character_list', path: '/characters', controller: @CharacterListController
        @route 'character', path: '/characters/:id', controller: @CharacterController, data: {}
        @route 'characterCreation', path: '/character_creation', controller: @CharacterCreationController,
        @route 'create_account', path: '/create_account'
        @route 'notfound', path: '*'
    
    class @WorldController extends RouteController
        before: () ->
            if not Meteor.user()
                this.render('sign_in')
                this.stop()
            else if Characters.findOne({owner: Meteor.userId()}) is undefined
                this.render('character_list')
                this.stop()

        action: () ->
            path = this.path
            setNavigationPill(path)

            this.render()

    class @CharacterListController extends RouteController
        before: () ->
            if not Meteor.user()
                this.render('sign_in')
                this.stop()
        action: () ->
            path = this.path
            setNavigationPill(path)

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

    class @CharacterCreationController extends RouteController
        before: () ->
            if not Meteor.user()
                this.render('sign_in')
                this.stop()
        action: () =>
            this.render()


    setNavigationPill = (path) ->
        switch path
            when '/world'
                pill = $("#nav-world")
            when '/characters'
                pill = $('#nav-character')
            when '/'
                pill = $('#nav-home')

        li = $(pill).parent()
        $(li).siblings().removeClass("active")
        $(li).addClass("active")

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
    test = new share.Enemy({_id: "fake", name: "Mogdor", hp: 100, currentRoom: "Central Area of the Marsh"})
    test.setCooldown(1)
    #tick = Meteor.setInterval(() =>
    #   console.log "alright" 
    # , 2000)
