if Meteor.isClient
    Template.model_edit.onCreated ->
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'model_fields', Router.current().params.model_slug
        @autorun -> Meteor.subscribe 'model_from_slug', Router.current().params.model_slug


    Template.model_view.onCreated ->
        @autorun -> Meteor.subscribe 'model_from_slug', Router.current().params.model_slug
        @autorun -> Meteor.subscribe 'model_fields', Router.current().params.model_slug
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id

    # Template.model_edit.events
    #     'click #delete_model': ->
    #         if confirm 'Confirm delete doc'
    #             Docs.remove @_id
    #             Router.go "/m/model"

    Template.field_edit.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000


    Template.field_edit.helpers
        is_ref: -> @field_type in ['single_doc', 'multi_doc','children']
        is_user_ref: -> @field_type in ['single_user', 'multi_user']

    Template.model_doc_edit.onCreated ->
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'model_fields', Router.current().params.model_slug
        @autorun -> Meteor.subscribe 'model_from_slug', Router.current().params.model_slug


    Template.model_doc_view.onCreated ->
        @autorun -> Meteor.subscribe 'model_from_slug', Router.current().params.model_slug
        @autorun -> Meteor.subscribe 'model_fields', Router.current().params.model_slug
        # console.log Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'upvoters', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'downvoters', Router.current().params.doc_id

    Template.model_doc_edit.events
        'click #delete_doc': ->
            if confirm 'Confirm delete doc'
                Docs.remove @_id
                Router.go "/m/#{@model}"

    Template.model_doc_view.events
        'click .back_to_model': ->
            Session.set 'loading', true
            Meteor.call 'set_facets', @model, ->
                Session.set 'loading', false
            Router.go "/m/#{@model}"


if Meteor.isServer
    Meteor.publish 'upvoters', (doc_id)->
        doc = Docs.findOne doc_id
        if doc.upvoter_ids
            Meteor.users.find _id:$in:doc.upvoter_ids
    Meteor.publish 'downvoters', (doc_id)->
        doc = Docs.findOne doc_id
        if doc.downvoter_ids
            Meteor.users.find _id:$in:doc.downvoter_ids
