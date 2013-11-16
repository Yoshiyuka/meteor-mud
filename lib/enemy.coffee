# #Enemy
# - - -
# **(extends the Creature class)**  
# All enemies are instanced from this class. Because it is stored in the /lib folder, the Enemy class is available to both server and client code.
class Enemy extends share.Creature
    #Set fields of class instance to those provided by options
    constructor: (options) ->
        for key, option of options
            console.log key + " | " + option
            @[key] = option
    # **tick(void):** an update function which handles decreasing cooldowns and executing queued actions if they are ready during the tick run.
    tick: () =>
        if @cooldown is 0
            @yell("WHY CAN'T I ATTACK YOU?!")
            @cooldown = 6
        else
            @say("I really want to hurt you...")
        #call Creature.tick() - might not actually want we want to do later on. This remains to be seen.
        super

# **Make this class available to all .coffee files in the project.**
share.Enemy = Enemy
