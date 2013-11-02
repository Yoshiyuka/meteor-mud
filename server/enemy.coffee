class Enemy
    constructor: (@name) ->
        @hp = 100

    tick: () ->
        #perform actions on tick if cooldown allows
        console.log @name + " thought of doing something." + @name + "'s health is: " + @hp

share.Enemy = Enemy
