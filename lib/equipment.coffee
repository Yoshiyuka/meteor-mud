# #Equipment
# - - -
# Represents items which an entity has equipped.
class Equipment
    # **constructor(Object, Number)** - initialize the Equipment class with default values.
    # - parent: the object this component is attached to
    constructor: (@parent) ->
        console.log "equipment created."
        @slots = {
            "left earring": undefined
            "right earring": undefined
            "helm": undefined
            "shoulders": undefined
            "chest": undefined
            "shirt": undefined
            "legs": undefined
            "boots": undefined
            "gloves": undefined
            "left ring": undefined
            "right ring": undefined
        }

        @validSlots = []
        for key, value of @slots
            @validSlots.push(key)

    #might not be needed...
    size: () -> super

    # (Number) **count(void)** - returns number of equipped items.
    count: () ->
        result = 0
        for key, value of @slots
            if value?
                result++
        return result

    # **equip(Object, String)** - attempts to equip the item in the specified slot.
    equip: (item, slot) ->
        #check(item, Object)
        #check(slot, String)
        console.log "Starting Equip Method"
        if not @slots[slot]?
            console.log "Attempting to equip #{item.name} in #{slot}..."
            if item.slot? and @validSlots.indexOf(slot) > -1
                @slots[slot] = item
                console.log "Successfully equipped: #{item.name} in #{slot}"
        else
            console.log "Equipment slot: #{slot} is already occupied by #{@slots[slot]}"

    # **unequip(String)** - attempts to unequip an item from the specified equipment slot.
    unequip: (slot) ->


# **Make the Equipment class available to all .coffee files in the project.**
share.Equipment = Equipment
