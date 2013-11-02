@Regions = new Meteor.Collection("regions") #each region in-game contains a series of rooms
@Items = new Meteor.Collection("items") #all item definitions within the game. 
@Messages = new Meteor.Collection("messages") #contains all chat. Each message is assigned a room id to filter messages by room
@Characters = new Meteor.Collection("characters") #all player characters
