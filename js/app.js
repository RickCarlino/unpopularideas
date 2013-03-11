
$(document).ready(function ($) {
    console.log('App loading...');
    Idea = Backbone.Model.extend({
        idAttribute: "_id",
        defaults: function () {
            return {
                title: "none set",
                url: '/ideas'
            };
        },
        initialize: function () {
            if (!this.get("title")) {
                this.set({
                    "title": this.defaults().title
                });
            }
            this.set({
                "url": this.defaults().url
            });
        },
        urlRoot: '/ideas'
    });

    // InputView = Backbone.View.extend({

    //     initialize: function () {
    //         this.template = _.template($('#idea-create').html());
    //     },
    //     events: {
    //         "keypress .inputBox"  : "newIdea",
    //     },
    //     newIdea: function(e) {
    //         if (e.keyCode == 13) {
    //             var newIdea = new Idea({title: $('.inputBox').val()});
    //             newIdea.save();
    //             $('.inputBox').val('');
    //             }
    //     },
    //     render: function () {
    //         $(this.el).html(this.template);
    //         return this;
    //     }
    // });

    IdeaView = Backbone.View.extend({
        tagtitle: 'li',
        initialize: function () {
            //Javascript is dumb...
            _.bindAll(this, 'render', 'remove');
            // implemented so that it will refresh when the model changes...
            this.model.bind('change', this.render);
            this.model.bind('destroy', this.remove);
            this.template = _.template($('#idea-template').html());
        },
        events:{
            'click .destroy' : 'clear',
            'dblclick .title'   : 'edit',
            'keypress .editBox'  : 'updateIdea'
        },
        clear: function(){
            console.log('Destroyed');
            this.model.destroy();
        },

        edit: function(){
            //a global? What?
            oldTitle = this.model.get('title');
            this.$el.find('.title').html(_.template('<input class="editBox" type="text" value="<%= oldTitle %>">'));
            this.$el.find('input').focus();

        },
        updateIdea: function(e){
                if (e.keyCode == 13) {
                this.model.set('title', $('.editBox').val());
                this.model.save();
                }
        },
        render: function () {
            var renderedContent = this.template(this.model.toJSON());
            $(this.el).html(renderedContent);
            //Return 'this' so that method chaining is possible
            return this;
        }
    });


    Ideas = Backbone.Collection.extend({
        model: Idea,
        url: '/ideas'
    });

    IdeasView = Backbone.View.extend({
        initialize: function () {
            _.bindAll(this, 'render');
            this.template = _.template($('#ideas-template').html());
            this.collection.bind('reset', this.render);
        },
        render: function () {
            var $ideas, collection;
            $(this.el).html(this.template);
            //using this.$() scopes it to the particular DOM element
            $ideas = this.$('.ideas');
            this.collection.each(function (idea) {
                var ideaItem = new IdeaView({
                    model: idea,
                    collection: collection
                });
                $ideas.append(ideaItem.render().el);
            });
            return this;
        },
        events: {
            "keypress .inputBox"  : "newIdea"
        },
        newIdea: function(e) {
            if (e.keyCode == 13) {
                var newIdea = new Idea({title: $('.inputBox').val()});
                newIdea.save();
                this.collection.add(newIdea);
                $('.inputBox').val('');
                ideas.reset();
                ideas.fetch();
                }
        }
    });


    UnpopularIdeas = Backbone.Router.extend({
        routes: {
            '': 'home'
        },
        initialize: function () {
            ideas = new Ideas;
            ideas.fetch();
            this.stream = new IdeasView({
                collection: ideas
            });
        },
        home: function () {
            $('#container').append(this.stream.render().el);
        }
    });

    window.App = new UnpopularIdeas;
    Backbone.history.start();

});