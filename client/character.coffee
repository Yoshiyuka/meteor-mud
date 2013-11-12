#--------------------------------------------------------------------------------------------------------------------------------#
# List template - Lists all characters currently associated with user's account. Provides character creation option.             #
#--------------------------------------------------------------------------------------------------------------------------------#
Template.list.characters = () -> 
    return Characters.find()

Template.list.events(
    'click #characters tr' : (e, t) ->
        id = $(e.currentTarget).attr("data-id")
        Router.go('character', {id: id}, {replaceState: false})

    'click #createCharacter' : (e, t) ->
        name = t.find('.form-control')
        if $(name).val() isnt undefined
            Meteor.call("createCharacter", $(name).val())
    )

Template.list.charactersLessThan = (maxCharacters) ->
    numCharacters = Characters.find().count()
    if numCharacters < maxCharacters
        return true 
    return false

#--------------------------------------------------------------------------------------------------------------------------------#
# Character template - Provides UI for viewing individual character's stats and skills.                                          #
#--------------------------------------------------------------------------------------------------------------------------------#
Template.character.created = () ->
Template.character.events(
    'click' : (e, t) ->
        e.preventDefault()
)
Template.character.character = () ->
    id = Session.get("characterId")
    return Characters.findOne({_id: id})

Template.character.getHealthRatio = () ->
    id = Session.get("characterId")
    character = Characters.findOne({_id: id})
    
    return character.health + "/" + character.maxHealth

Template.character.getHealthPercentage = () ->
    id = Session.get("characterId")
    character = Characters.findOne({_id: id})
    currentHealth = character.health
    maxHealth = character.maxHealth

    result = (currentHealth/maxHealth) * 100
    return result

Template.character.getManaRatio = () ->
    id = Session.get("characterId")
    character = Characters.findOne({_id: id})

    return character.mana + "/" + character.maxMana

Template.character.getManaPercentage = () ->
    id = Session.get("characterId")
    character = Characters.findOne({_id: id})
    currentMana = character.mana
    maxMana = character.maxMana

    result = (currentMana/maxMana) * 100
    return result

#--------------------------------------------------------------------------------------------------------------------------------#
# Skill listing helpers for character UI.                                                                                        #
#--------------------------------------------------------------------------------------------------------------------------------#
Template.character.skillType = () ->
    id = Session.get("characterId")
    character = Characters.findOne({_id: id})

    unique = {}
    skillTypes = []
    for skill in character.skills
        if unique[skill.type] is undefined
            skillTypes.push(skill)
            unique[skill.type] = 1

    return skillTypes

Template.character.listSkillType = (type) ->
    result = "<div class='panel-heading list-heading'>" +
             "<a href='#" + type + "' data-toggle='collapse' data-parent='#accordian'>" + type + "</a>" + 
             "</div>" + 
             "<div id='" + type + "' class='list-group collapse in'>"

    return result

Template.character.skills = (type) ->
    id = Session.get("characterId")
    character = Characters.findOne({_id: id})

    fragments = []
    for skill in character.skills
        if skill.type is type
            fragments.push(
                "<a href='#' class='list-group-item'><span class='label label-warning pull-right'>" + skill.value + "/100</span>" + skill.name + "</a>"
            )
    return fragments.join("")

