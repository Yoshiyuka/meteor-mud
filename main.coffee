# ##Server-Side Code
# - - -
# **On start, set up the World as the server needs to see it to keep all players synced up properly.**
if Meteor.isServer
    # Server-wide World object shared across all CoffeeScript files.
    share.World = {}
    share.World.Regions = {}
    share.World.Time = () -> new Date().getTime()

    regions = Regions.find()
    #An observer which generates Region instances which represent the game world. Automatically updates when changes to the database are detected.
    regions.observeChanges
        added: (id, fields) ->
            console.log "added: " + fields.name
            region = new share.Region(fields)
            share.World.Regions[id] = region

# ##Client-Side Code
# - - -
# **On start, set up the World as the client needs to see it. Create an instance of the Player for the client. Initialize routes for handling page redirection.**
if Meteor.isClient
    # Client-wide World object shared across all CoffeeScript files
    share.World = {}
    # Set client time on startup. Used as a check against server time.
    share.World.Time = () -> new Date().getTime()
    
    # Automatically run these functions. Code will re-run when data it depends is detected as changed.
    Deps.autorun(()->
        user = Meteor.user()
        if user?
            #Get all of the characters belonging to the current user.
            Meteor.subscribe("characters", user._id, {
                onError: (err) ->
                    console.log err.error + " " + err.reason
                onReady: () ->
               
            })

            #Retrieve the character document for the currently selected character.
            selectedCharacterId = user.profile.selected
            character = Characters.findOne({_id: selectedCharacterId})

            if character?
                #If a character document has been found, create a new Player instance using the data from the retrieved document.
                share.World.Player = new share.Player(character)
    )

# ##Router Logic
# - - -
    Router.map ->
        @route 'home', path: '/', action: () -> setNavigationPill(this.path)
        @route 'world', path: '/world', controller: @WorldController
        @route 'character_list', path: '/characters', controller: @CharacterListController
        @route 'character', path: '/characters/:id', controller: @CharacterController, data: {}
        @route 'characterCreation', path: '/character_creation', controller: @CharacterCreationController,
        @route 'create_account', path: '/create_account'
        @route 'notfound', path: '*'
    
    # ###WorldController:
    # Route controller for the World page.
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

    # ###CharacterListController:
    # Route controller for the Characters page. This lists all characters (if any) in a table.
    class @CharacterListController extends RouteController
        before: () ->
            if not Meteor.user()
                this.render('sign_in')
                this.stop()
        action: () ->
            path = this.path
            setNavigationPill(path)

            this.render()
    # ###CharacterController:
    # Router controller for Character UI page. Displays stat and skill info for a specific character.
    class @CharacterController extends RouteController
        before: () ->
            if not Meteor.user()
                this.render('sign_in')
                this.stop()
            Session.set("characterId", this.params.id)
        action: () =>
            this.render('character',{id: this.params.id})

    #CharacterCreationController:** Router controller for Character Creation page. **THIS IS CURRENTLY NOT IN USE!**
    class @CharacterCreationController extends RouteController
        before: () ->
            if not Meteor.user()
                this.render('sign_in')
                this.stop()
        action: () =>
            this.render()

    # **setNavigationPill(String):**
    # Helper function to set the navigation menu's currently selected option when a route is visited.
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

#Spawn a test enemy in the server. REMOVE FROM CODE WHEN READY TO TEST ENEMY CREATION PER ROOM
if Meteor.isServer
    test = new share.Enemy({_id: "fake", name: "Mogdor", hp: 100, currentRoom: "Central Area of the Marsh"})
    test.setCooldown(1)
    #tick = Meteor.setInterval(() =>
        #console.log "alright" 
     #, 2000)
