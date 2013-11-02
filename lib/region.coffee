#ROOM DEFITION FOR USE BETWEEN CLIENT AND SERVER

class Room
    constructor: (name) ->
        @name = name
        
    enter: (destination) ->
        check(destination, String)

        player = getPlayer()
        if player?
            Regions.update({'rooms.name': destination}, {$addToSet: {'rooms.$.players': {name: player.name}}})
            Messages.insert({text: player.name + " has entered the room.", broadcastTo: destination, sender: Meteor.userId(), timestamp: new Date().getTime()})
            Characters.update({owner: Meteor.userId()}, {$set: {currentRoom: destination}})
            #Messages.insert({text: player.name + " has left the room.", broadcastTo: previousRoom, sender: player._id, timestamp: new Date().getTime()})
            return destination


    leave: () ->
        player = getPlayer()
        if player?
            console.log "player found in Room.leave()"

    getPlayer = () ->
        player = Characters.findOne({owner: Meteor.userId()})
        if player? 
            return player
        else
            console.log new Meteor.Error(930, "No characters owned by user.")

class Region
    constructor: (region_document) ->
        if region_document.name?
            @name = region_document.name
        if region_document.rooms?
            for room in region_document.rooms
                console.log room.name

share.Region = Region
