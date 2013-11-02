if Meteor.isClient
    #isLoggedIn = () -> 
    #    if Meteor.userId()?
    #        return true
    #    return false

    #Template.world.isLoggedIn = isLoggedIn
    #Template.character.isLoggedIn = isLoggedIn

    Meteor.startup(() ->
        #if not Meteor.userId()?
        #    $('.mustSignIn').attr('href', () -> 
        #        return '#sign-in'
        #    ).attr('data-toggle', 'modal').attr('data-target', '#sign-in')
    )

    Template.sign_in_body.events({
        'submit #sign-in-form' : (e, t) ->
            e.preventDefault()
            email = t.find('#accountEmail').value
            password = t.find('#accountPassword').value

            #trim and validate fields.......
            Meteor.loginWithPassword(email, password, (err) ->
                if err
                    #error handling, please. Who, where, why, what?
                else
                    #what do on success? 
            )

            return false
    })

    Template.create_account_body.events({
        'click #create-account-form' : (e) ->
            $('#accountError').css("visibility", "hidden")
            $('.form-group').removeClass('has-error')

        'submit #create-account-form' : (e, t) ->
            e.preventDefault()
            email = t.find('#accountEmail').value
            password = t.find('#accountPassword').value
            confirmPassword = t.find('#accountPasswordConfirm').value

            if confirmPassword isnt password
                #$('#passwordConfirmError').show()
                $('#accountError').html("<p>Passwords do not match. Please reconfirm your password</p>")
                $('#accountError').css("visibility", "visible")
                $('#password_group').addClass('has-error')
                $('#password_confirm_group').addClass('has-error')
            else
                Accounts.createUser({email: email, password}, (err) ->
                    if err
                        #reason = "Unspecified error"
                        if err.error is 403
                            #reason = "\nAccount already exists."
                            $('#accountError').html("<p>That account already exists!</p>")
                            $('#accountError').css("visibility", "visible")
                            $('#email_group').addClass('has-error')
                        #alert('There has been an issue creating your account!' + reason)
                    else
                        #alert('Congratulations! Your account has been successfully created. Please sign in with your account credentials.')
                        window.history.back()
                )
    })
