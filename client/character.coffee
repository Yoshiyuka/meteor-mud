Template.list.characters = () -> 
    return Characters.find()

Template.list.events(
    'click tr' : (e, t) ->
        id = $(e.currentTarget).attr("data-id")
        Router.go('character', {id: id})
)

Template.character.created = () ->
    #return Characters.findOne({_id: id})
    console.log Session.get("characterId")

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
