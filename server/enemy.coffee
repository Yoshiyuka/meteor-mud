class Enemy extends share.Creature
    constructor: () ->
        super

    tick: () ->
        #perform actions on tick if cooldown allows
        console.log @name + " thought of doing something." + @name + "'s health is: " + @hp
        super

share.Enemy = Enemy
