#**Event listeners for both the Sign In and Create Account forms.**
#  
#Sign In Form's Event Listener
#-----------------------------
Template.sign_in_body.events({
    'submit #sign-in-form' : (e, t) ->
        e.preventDefault()
        email = t.find('#accountEmail').value
        password = t.find('#accountPassword').value

        #To Do: Trim and validate input. 
        Meteor.loginWithPassword(email, password, (err) ->
            if err
                #TODO: Properly handle error.... don't just ignore them!
            else
                #TODO: Handle login success.
        )

        return false
})

#Create Account Form's Event Listener
#------------------------------------
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
            $('#accountError').html("<p>Passwords do not match. Please reconfirm your password</p>")
            $('#accountError').css("visibility", "visible")
            $('#password_group').addClass('has-error')
            $('#password_confirm_group').addClass('has-error')
        else
            Accounts.createUser({email: email, password}, (err) ->
                if err
                    #TODO: Properly handle error... don't just ignore them!
                    if err.error is 403
                        $('#accountError').html("<p>That account already exists!</p>")
                        $('#accountError').css("visibility", "visible")
                        $('#email_group').addClass('has-error')
                else
                    #TODO: Ideally we would display a success message rather than silently sending the user back to the previous page.
                    window.history.back()
            )
})
