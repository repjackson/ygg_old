Meteor.methods
    set_alpha_facets: ()->
        alpha = Docs.findOne
            model:'alpha'
            _author_id:Meteor.userId()
        # console.log 'model', model

        Docs.update alpha._id,
            $set:facets:[
                {
                    key:'_keys'
                    filters:[]
                    res:[]
                }
            ]
        # Docs.update alpha._id,
        #     $addToSet:
        #         facets: {
        #             title:field.title
        #             icon:field.icon
        #             key:field.key
        #             rank:field.rank
        #             filters:[]
        #             res:[]
                    # }
        Meteor.call 'fa', alpha._id


    fa: (alpha_id)->
        # console.log 'running fa', alpha_id
        alpha = Docs.findOne alpha_id
        # console.log alpha
        # console.log model
        built_query = {}
        unless alpha.facets
            Docs.update alpha_id,
            $set:
                facets: [
                    {
                        key:'_keys'
                        filters:[]
                        res:[]
                    }
                ]

        for facet in alpha.facets
            # console.log 'this facet', facet.key
            if facet.filters.length > 0
                built_query["#{facet.key}"] = $all: facet.filters

        total = Docs.find(built_query).count()
        # console.log 'built query', built_query

        # response
        for facet in alpha.facets
            values = []
            local_return = []

            agg_res = Meteor.call 'alpha_agg', built_query, facet.key
            # agg_res = Meteor.call 'agg', built_query, facet.key

            if agg_res
                Docs.update { _id:alpha._id, 'facets.key':facet.key},
                    { $set: 'facets.$.res': agg_res }

        modifier =
            {
                fields:_id:1
                limit:10
                sort:_timestamp:-1
            }

        # results_cursor =
        #     Docs.find( built_query, modifier )

        results_cursor = Docs.find built_query, modifier


        # if total is 1
        #     result_ids = results_cursor.fetch()
        # else
        #     result_ids = []
        result_ids = results_cursor.fetch()

        # console.log 'result ids', result_ids
        # console.log 'alpha', alpha
        # console.log Meteor.userId()

        Docs.update {_id:alpha._id},
            {$set:
                total: total
                result_ids:result_ids
            }, ->
        return true


        # alpha = Docs.findOne alpha_id
        # console.log 'alpha', alpha

    alpha_agg: (query, key)->
        limit=100
        # console.log 'agg query', query
        # console.log 'agg key', key
        # console.log 'agg collection', collection
        options = { explain:false }
        pipe =  [
            { $match: query }
            { $project: "#{key}": 1 }
            { $unwind: "$#{key}" }
            { $group: _id: "$#{key}", count: $sum: 1 }
            { $sort: count: -1, _id: 1 }
            { $limit: limit }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        if pipe
            agg = global['Docs'].rawCollection().aggregate(pipe,options)
            # else
            res = {}
            # console.log 'res', res
            if agg
                agg.toArray()
        else
            return null
