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
        user = Meteor.user()
        if user?
            Meteor.subscribe("characters", user._id, {
                onError: (err) ->
                    console.log err.error + " " + err.reason
                onReady: () ->
               
            })
            selectedCharacterId = user.profile.selected
            character = Characters.findOne({_id: selectedCharacterId})

            if character?
                console.log "creating player...."
                share.World.Player = new share.Player(character)
    )

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

if Meteor.isServer
    test = new share.Enemy({_id: "fake", name: "Mogdor", hp: 100, currentRoom: "Central Area of the Marsh"})
    test.setCooldown(1)
    #tick = Meteor.setInterval(() =>
    #   console.log "alright" 
    # , 2000)
