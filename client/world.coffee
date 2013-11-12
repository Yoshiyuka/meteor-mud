if Meteor.isClient
    #canvas resolution helper functions pulled from 
    #http://stackoverflow.com/questions/15661339/how-do-i-fix-blurry-text-in-my-html5-canvas
    PIXEL_RATIO =( () -> 
        ctx = document.createElement("canvas").getContext("2d")
        dpr = window.devicePixelRatio or 1
        bsr = ctx.webkitBackingStorePixelRatio or
              ctx.mozBackingStorePixelRatio or
              ctx.msBackingStorePixelRatio or
              ctx.oBackingStorePixelRatio or
              ctx.backingStorePixelRatio or 1
        return dpr/bsr
    )()

    createHiDPICanvas = (w, h, ratio) -> 
        if not ratio then ratio = PIXEL_RATIO
        can = document.createElement("canvas")
        can.width = w * ratio
        can.height = h * ratio
        can.style.width = w + "px"
        can.style.height = h + "px"
        can.getContext("2d").setTransform(ratio, 0, 0, ratio, 0, 0)
    
        return can
    #end helper functions

    Template.world.created = () -> 
        Session.set("game_output", new Array())
        Session.set("incoming", new Array())
        output = Session.get("game_output")

        Session.set("sessionStart", new Date().getTime())

        sessionStart = Session.get("sessionStart")

        serverMessages = Messages.find()
        clientMessages = LocalMessages.find()
        this.serverMessagesHandle = serverMessages.observeChanges({
            added: (id, message) ->
                incoming = Session.get("incoming")
                console.log("change detected: " + message.text)
                incoming.push(message.text)
                Session.set("incoming", incoming)
            #removed: (id) -> 
                #incoming = Session.get("incoming")
                #console.log("removed document: " + id)
                #incoming.pop()
                #Session.set("incoming", incoming)
        })

        this.clientMessagesHandle = clientMessages.observeChanges({
            added: (id, message) ->
                incoming = Session.get("incoming")
                console.log "local change detected: " + message.text
                incoming.push(message.text)
                Session.set("incoming", incoming)
        })

        this.autorun = undefined

    Template.world.destroyed = () ->
        this.serverMessagesHandle.stop()
        this.clientMessagesHandle.stop()
        this.autorun.stop()
        Session.set("game_putput", new Array())
        Session.set("incoming", new Array())

    Template.world.rendered= () ->
        canvas = createHiDPICanvas($('#input_area').outerWidth(), 420)
        $(canvas).attr("id", "game_window")
        $('#game_window').replaceWith(canvas)
    
        if this.autorun is undefined
            this.autorun = Deps.autorun(()->
                #    observeRegion()
                updateCanvas()
            )
        else
            #update the canvas once. This is for trying to revisit the page while still on it
            console.log("autorun already running. updating canvas once. rendered autorun")
            updateCanvas()

    Template.world.events({
        'click #submit' : (e, t) ->
            canvas = t.find('#game_window')
            input = $(t.find('#input_area'))
            #Messages.insert({text: input.val(), broadcastTo: "global", sender: Meteor.userId()})
            parseCommands(input.val())
    })

    parseCommands = (argument) ->
        check(argument, String)
       
        command = argument.substr(0, argument.indexOf(' '))
        parameters = argument.substr(argument.indexOf(' ') + 1)

        #check for one-word commands with no following spaces
        if command.length is 0
            console.log("command length is 0")
            command = parameters
            parameters = ""

        if command of share.Commands
            console.log("command: " + command + " parameters: " + parameters)
            share.Commands[command](parameters)
        else if command.charAt(0) isnt '/'
            #lack of / will be considered an implicit /say command
            console.log(command.charAt(0))
            share.Commands["/say"](command + " " + parameters)
        else
            #invalid commands beginning with / will be noted as such.
            console.log("Invalid command: " + command)


    clearCanvas = () ->
        canvas = $('#game_window')[0]
        context = canvas.getContext('2d')


        context.font = '10pt Arial'
        context.textBaseline = "top"
        context.clearRect(0, 0, canvas.width, canvas.height)

    updateCanvas = () ->
        canvas = $('#game_window')[0]
        context = canvas.getContext('2d')

        clearCanvas()
        
        output = Session.get("game_output")
        incoming = Session.get("incoming")

        maxWidth = canvas.width - 20
        lineHeight = 20 #20 pixel line height

        x = 10 #10 pixel padding on left
        y = 5  #5 pixel padding on top
        #end magic numbers. Clearly you didn't fix that crap.

        for i in [0..incoming.length-1] by 1
            wrapText(context, output, incoming[i], maxWidth)
        while output.length > 20
            output.shift()

        for i in [0..output.length-1] by 1
            y += lineHeight
            context.fillText(output[i], x, y)


    wrapText = (context, output, input, maxWidth) -> 
        words = input.split(' ')
        line = ''

        for i in [0..words.length-1] by 1
            tempLine = line + words[i] + ' '
            metrics = context.measureText(tempLine)
            testWidth = metrics.width

            if testWidth > maxWidth and i > 0
                output.push(line)
                line = words[i] + ' '
            else
                line = tempLine
        output.push(line)

   # observeRegion = () -> 
   #     player = Characters.findOne({owner: Meteor.userId()})
   #     if not player? 
   #         console.log "unable to find: " + Meteor.userId()
   #     else
   #         region = Regions.findOne({'rooms.name': {$in: [player.currentRoom]}})
   #     if not region? 
   #         console.log "unable to find region!"
   #     else 
   #         console.log "found region: " + region.name
