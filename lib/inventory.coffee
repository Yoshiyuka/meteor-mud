# #Inventory
# - - -
# **Holds an array of item documents fetched from the mongodb Items collection.
# Also provides methods for adding, removing, and iterating through the item array.**
class Inventory
    # **constructor(Object, Number)** - initialize the Inventory class with default values.  
    # - parent: the object this component is attached to.  
    # - container_size: maximum number of items the inventory can hold.
    constructor: (@parent, @container_size) ->
        console.log "inventory created"
        #Array of item ids indexing into the Items collection. Used as a base to generate variations of each item.
        #@item_templates = []
        # Object containing generated item documents. **Key: String, Value: Object**
        @items = {}

    # (Number) **size(void)** - returns maximum inventory size.
    size: () ->  return @container_size

    # (Number) **count(void)** - returns number of items currently in the inventory.
    # While looping across items and tallying them up ensures returning actual size, it would be more efficient (in the future)
    # to simply add/subtract from a count variable when inventory is modified and return that value.
    count: () ->
        result = 0
        for id, item of @items
            result += item.amount

        return result

    #region Add Item
    # (Number) **addItem(Object, Number)** - 
    # adds one (default) or more item documents to this Inventory instance. Returns item id on success, (void 0) on failure.
    addItem: (item, amount = 1) ->
        if @count() + amount < @size()
            if not @items[item._id]?
                @items[item._id] = item
                @items[item._id].amount = amount
            else if EJSON.equals(@items[item._id], item)
                @items[item._id].amount += amount
            else
                console.log "malformed object/object id"

            return item._id
        else
            console.log "INVENTORY LIMIT REACHED"
            return undefined
    #endregion

    #region Remove Item
    # **removeItem(String, Number)** - removes one (default) or more item documents (matching item_id) from this Inventory instance
    removeItem: (item_id, amount = 1) ->
        if @items[item_id]?
            @items[item_id].amount -= amount

            #remove item_id index in this.items if there are no more items matching item_id
            if @items[item_id].amount <= 0
                delete @items[item_id]
    #endregion
            
    # (Array) **getItem(String Number)** - returns one or more item documents (as an array)  
    getItem: (item_id, amount = 1) ->
            
    listItems: () ->
        #iterate through all items in inventory and return as string


# **Make the Inventory class available to all .coffee files in the project.**
share.Inventory = Inventory

#UNUSED ITEM TEMPLATE FUNCTIONS - INVENTORY SHOULD ONLY BE RESPONSIBLE FOR *ALREADY GENERATED* ITEMS! ITEM GENERATION SHOULD BE HANDLED ELSEWHERE.
    #**addItemTemplate(String)** - add the item_id to the item template array for use in looking up templates from the Items collection. 
    #addItemTemplate: (item_id) ->

    #**removeItemTemplate(String)** - remove the item_id from the item template array
    #removeItemTemplate: (item_id) ->
