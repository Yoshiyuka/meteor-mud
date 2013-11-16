# #character.coffee
# Provides event listeners and helper functions for the Character Selection and Character Info pages.

# ###Character Selection List
# Lists all characters currently associated with user's account. Provides character creation option. 
# - - -

# Helper: **characters(void)** - returns all character documents belonging to user (determined by the Characters publish method) to iterate over in template.
Template.list.characters = () -> 
    return Characters.find()

# **Event Listener**
Template.list.events(
    # * 'click' event listener monitoring for clicks on any row of the character list.
    'click #characters tr' : (e, t) ->
        id = $(e.currentTarget).attr("data-id")
        Meteor.call("selectCharacter", id, (error, result) -> )
        Router.go('character', {id: id}, {replaceState: false})

    # * 'click' event listener monitoring for clicks on the character creation row. Sets created character's id as currently selected on successful creation.
    'click #createCharacter' : (e, t) ->
        name = t.find('.form-control')
        if $(name).val() isnt undefined
            Meteor.call("createCharacter", $(name).val(), (error, result) -> 
                if error?
                    alert error.error + "\n" + error.reason
                else
                    Meteor.call("selectCharacter", result, (error, result) ->
                    )
            )
    )

Template.list.charactersLessThan = (maxCharacters) ->
    numCharacters = Characters.find().count()
    if numCharacters < maxCharacters
        return true 
    return false

# ###Character Info
# Provides UI for viewing individual character's stats and skills.      
# - - -

# **Event Listener**
Template.character.events(
    # * 'click' event listener to override default behavior of link clicking on this page. This is to prevent anchor tags from being added to the URL when an item is clicked.
    'click' : (e, t) ->
        e.preventDefault()
)

# Helper: **character(void)** - gets a single character document for the currently selected character id. 
Template.character.character = () ->
    id = Session.get("characterId")
    return Characters.findOne({_id: id})

# Helper: **getHealthRatio(void)** - returns the character's current and max health in the form of a string such as '10/100'.
Template.character.getHealthRatio = () ->
    id = Session.get("characterId")
    character = Characters.findOne({_id: id})
    
    return character.health + "/" + character.maxHealth

# Helper: **getHealthPercentage(void)** - returns the character's current health as a percentage of character's max health.
Template.character.getHealthPercentage = () ->
    id = Session.get("characterId")
    character = Characters.findOne({_id: id})
    currentHealth = character.health
    maxHealth = character.maxHealth

    result = (currentHealth/maxHealth) * 100
    return result

# Helper: **getManaRatio(void)** - returns the character's current and max mana in the form of a string such as '10/100'.
Template.character.getManaRatio = () ->
    id = Session.get("characterId")
    character = Characters.findOne({_id: id})

    return character.mana + "/" + character.maxMana

# Helper: **getManaPercentage(void)** - returns the character's current mana as a percentage of character's max mana.
Template.character.getManaPercentage = () ->
    id = Session.get("characterId")
    character = Characters.findOne({_id: id})
    currentMana = character.mana
    maxMana = character.maxMana

    result = (currentMana/maxMana) * 100
    return result

# Helper: **skillType(void)** - iterates over all skills in the selected character document and reduces them into an array of unique skill types.
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

# Helper: **listSkillType(String)** - creates a skill category header for the provided skill type. HTML fragment is rendered directly into the page.
Template.character.listSkillType = (type) ->
    result = "<div class='panel-heading list-heading'>" +
             "<a href='#" + type + "' data-toggle='collapse' data-parent='#accordian'>" + type + "</a>" + 
             "</div>" + 
             "<div id='" + type + "' class='list-group collapse in'>"

    return result

# Helper: **skills(String)** - populates skill category with all skills matching the category type. Returns a single string of HTML fragments to be rendered directly into the page.
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

