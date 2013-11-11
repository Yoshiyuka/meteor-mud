Template.list.characters = () -> 
    return Characters.find()

Template.list.events(
    'click tr' : (e, t) ->
        id = $(e.currentTarget).attr("data-id")
        Router.go('character', {id: id}, {replaceState: true})
)

Template.character.created = () ->
    #return Characters.findOne({_id: id})
    #console.log Session.get("characterId")
#
#Template.character.events(
#    'click .list-heading': (e, t) ->
#        header = t.find($(e.target).attr("href"))
#        $(header).collapse('show')

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

Template.character.listSkills = () ->
    id = Session.get("characterId")
    character = Characters.findOne({_id: id})

    skillTypes = {}
    fragments = [] #HTML fragments printed out in-order.
    for skill in character.skills
        #first time seeing this skill type. Create header and append skill to group.
        if skillTypes[skill.type] is undefined
            skillTypes[skill.type] = []
            skillTypes[skill.type].push(skill)
        else
            skillTypes[skill.type].push(skill)

    for type, skills of skillTypes
        fragments.push(
            "<div class='panel-heading list-heading'>" +
            "<a href='#" + type + "' data-toggle='collapse' data-parent='#accordian'>" + type + "</a>" +
            "</div>" +
            "<div id='" + type + "' class='list-group collapse in'>"
        )
        for skill in skills
            fragments.push(
                "<a href='#' class='list-group-item'><span class='label label-warning pull-right'>" + skill.value + "/100</span>" + skill.name + "</a>"
            )
            console.log type + " | " + skill.name
        fragments.push(
            "</div>"
        )

    result = fragments.join("")
    return result
