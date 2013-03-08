
$(document).ready(function ($) {
    console.log('App loading...');
    Idea = Backbone.Model.extend({
        defaults: function () {
            return {
                title: "none set",
                url: function () {
                    return ('/ideas');
                }
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
        }
    });


    IdeaView = Backbone.View.extend({
        tagName: 'li',
        initialize: function () {
            //Javascript is dumb...
            _.bindAll(this, 'render');
            // implemented so that it will refresh when the model changes...
            this.model.bind('change', this.render);
            this.template = _.template($('#idea-template').html());
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