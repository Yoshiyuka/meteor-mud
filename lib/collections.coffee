#TODO: REFACTOR THESE INTO APPROPRIATE AREAS OF CODE SO CLIENTS ARENT SUBSCRIBING TO UNNEEDED DATA AT THE WRONG TIMES
#
@LocalMessages = new Meteor.Collection(null) #client-side collection (no sync to server) for player-only messages
@Regions = new Meteor.Collection("regions") #each region in-game contains a series of rooms
@Rooms = new Meteor.Collection("rooms")
@Items = new Meteor.Collection("items") #all item definitions within the game. 
@Messages = new Meteor.Collection("messages") #contains all chat. Each message is assigned a room id to filter messages by room
@Characters = new Meteor.Collection("characters") #all player characters
