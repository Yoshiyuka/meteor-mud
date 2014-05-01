#TODO: REFACTOR THESE INTO APPROPRIATE AREAS OF CODE SO CLIENTS ARENT SUBSCRIBING TO UNNEEDED DATA AT THE WRONG TIMES
#
# All of the collections which the project uses. Each collection can be thought of as a MySQL 'table'. 
# These collections are available to both server and client code unless noted otherwise.

# **client-side collection** (no sync to server) for player-only messages
@LocalMessages = new Meteor.Collection(null) 
@Regions = new Meteor.Collection("regions") #each region in-game contains a series of rooms
@Rooms = new Meteor.Collection("rooms")
# Item template definitions for use in generating new items during the game's lifecycle.
@Items = new Meteor.Collection("items")
# Contains all shared chat. Each message is assigned a room id to filter messages by room
@Messages = new Meteor.Collection("messages") 
# All player characters
@Characters = new Meteor.Collection("characters")
# Inventories of each entity with an Inventory component.
@Inventory = new Meteor.Collection("inventory")
