if Meteor.isClient
    Router.route '/users', -> @render 'users'


    Template.users.onCreated ->
        # @autorun -> Meteor.subscribe('users')
        @autorun => Meteor.subscribe 'user_search', Session.get('username_query')


    Template.users.helpers
        users: ->
            username_query = Session.get('username_query')
            Meteor.users.find({
                username: {$regex:"#{username_query}", $options: 'i'}
                # healthclub_checkedin:$ne:true
                # roles:$in:['resident','owner']
                },{ limit:20 }).fetch()

    Template.users.events
        # 'click #add_user': ->
        #     id = Docs.insert model:'person'
        #     Router.go "/person/edit/#{id}"
        'keyup .username_search': (e,t)->
            username_query = $('.username_search').val()
            if e.which is 8
                if username_query.length is 0
                    Session.set 'username_query',null
                    Session.set 'checking_in',false
                else
                    Session.set 'username_query',username_query
            else
                Session.set 'username_query',username_query


if Meteor.isServer
    Meteor.publish 'users', ->
        Meteor.users.find()


    Meteor.publish 'user_search', (username)->
        Meteor.users.find({
            username: {$regex:"#{username}", $options: 'i'}
            },{ limit:20})
