class Enemy extends share.Creature
    constructor: (options) ->
        for key, option of options
            console.log key + " | " + option
            @[key] = option

    tick: () =>
        #perform actions on tick if cooldown allows
        #console.log @name + " thought of doing something." + @name + "'s health is: " + @hp
        if @cooldown is 0
            @yell("WHY CAN'T I ATTACK YOU?!")
            @cooldown = 6
        else
            @say("I really want to hurt you...")
        super


share.Enemy = Enemy
