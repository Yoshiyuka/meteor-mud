Template.list.characters = () -> 
    return Characters.find()

Template.list.events(
    'click tr' : (e, t) ->
        id = $(e.currentTarget).attr("data-id")
        Router.go('character', {id: id})
)

Template.character.character = (id) ->
    return Characters.findOne({_id: id})
