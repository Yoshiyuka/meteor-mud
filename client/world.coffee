# canvas resolution helper functions pulled from 
# [here](http://stackoverflow.com/questions/15661339/how-do-i-fix-blurry-text-in-my-html5-canvas)
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

# World template's created callback method.  
# This method is called when an instance of the World template is first created.
Template.world.created = () -> 
    Session.set("game_output", new Array())
    Session.set("incoming", new Array())
    output = Session.get("game_output")

    Session.set("sessionStart", new Date().getTime())

    sessionStart = Session.get("sessionStart")

    # Set up observers for both server and client messages. Push new results into an array as a Session variable.
    serverMessages = Messages.find()
    clientMessages = LocalMessages.find()

    # * Observe server messages. These are messages from other players, enemies, and broadcast messages (server events)
    this.serverMessagesHandle = serverMessages.observeChanges({
        added: (id, message) ->
            incoming = Session.get("incoming")
            incoming.push(message.text)
            Session.set("incoming", incoming)
    })

    # * Observe client messages. These are messages only the player sees. Personal events starting with 'You' for instance. (You have entered ____)
    this.clientMessagesHandle = clientMessages.observeChanges({
        added: (id, message) ->
            incoming = Session.get("incoming")
            incoming.push(message.text)
            Session.set("incoming", incoming)
    })

    this.autorun = undefined

# World template's destroyed callback method.
# This method is called when an instance of the World template is destroyed. This typically happens on page unload.
Template.world.destroyed = () ->
    # * Stop our observers to prevent them from continuing to run and causing a memory leak.
    this.serverMessagesHandle.stop()
    this.clientMessagesHandle.stop()
    this.autorun.stop()
    Session.set("game_putput", new Array())
    Session.set("incoming", new Array())

# World template's rendered callback method.
# This method is called every time an instance of the World template is rendered. This happens once after the template is first drawn to the screen (after creation),
# when the page is refreshed, and when any reactive elements are updated/changed (triggering a re-render).
Template.world.rendered= () ->
    canvas = createHiDPICanvas($('#input_area').outerWidth(), 420)
    $(canvas).attr("id", "game_window")
    $('#game_window').replaceWith(canvas)

    if this.autorun is undefined
        this.autorun = Deps.autorun(()->
            updateCanvas()
        )
    else
        # Update the canvas once. This is for trying to revisit (not refresh) the page while still on it
        console.log("autorun already running. updating canvas once. rendered autorun")
        updateCanvas()

# World template's event listeners.
Template.world.events({
    # * 'click' event on submit button. Get user input from text input field and parse it.
    'click #submit' : (e, t) ->
            canvas = t.find('#game_window')
            input = $(t.find('#input_area'))
            parseCommands(input.val())
    # * 'keyup' and 'keydown' events for Enter key. Allows submitting input field without clicking on the submit button.
    'keyup #input_area, keydown #input_area' : (e, t) ->
        if e.type is "keyup" and e.which is 13
            value = String(e.target.value or "")

            if value
                parseCommands(value)
                e.target.value = ""
    })

# **parseCommands(String)** - Splits given string and checks if the beginning of the string matches any keys in the Commands array.  
# If string doesn't start with '/' then it defaults to the /say command.
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

# **clearCanvas(void)** - Helper function which clears the canvas when any new data needs to be drawn to it.
clearCanvas = () ->
    canvas = $('#game_window')[0]
    context = canvas.getContext('2d')


    context.font = '10pt Arial'
    context.textBaseline = "top"
    context.clearRect(0, 0, canvas.width, canvas.height)

# **updateCanvas(void)** - Canvas updater. Draws text to canvas and runs text to be drawn through a function to handle word-wrapping before being rendered to screen.
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

# **wrapText(Object, Array, Array, Number)** - Splits a string into multiple lines of text if the width of the string exceeds the width of the canvas it's being rendered to. 
# Each line break is simply added onto the output stack as if it were another input submitted.
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
