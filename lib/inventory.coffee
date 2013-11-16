# #Inventory
# - - -
# **Holds an array of item documents fetched from the mongodb Items collection.
# Also provides methods for adding, removing, and iterating through the item array.**
class Inventory
    constructor: () ->
        console.log "inventory created"
        # Array of item ids indexing into the Items collection. Used as a base to generate variations of each item.
        @item_templates = []
        # Object containing generated item documents based off of templates in item_templates
        @items = {}

    # **addItem(String, Number)** - 
    # adds one (default) or more item documents (matching item_id) to this Inventory instance.
    addItem: (item_id, amount = 1) ->

    # **deleteItem(String, Number)** - removes one (default) or more item documents from this Inventory instance
    deleteItem: (item_id, amount = 1) ->
            
    # (Array) **getItem(String Number)** - returns one or more item documents (as an array)  
    getItem: (item_id, amount = 1) ->
            
    listItems: () ->
        #iterate through all items in inventory and return as string


share.Inventory = Inventory
