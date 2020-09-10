# Dynamican
Dynamican is a flexible gem which introduces permissions on rails applications. It is very customizable because it stores all the rules inside the database and can be added to multiple models: for example you can add permissions to your Role and User models. With a couple of overrides you can also add permissions to both Role and User and allow user to use its roles permissions.

## Installation
Inside your Gemfile put

    gem 'dynamican'

and run `bundle install`, then you can launch the following command.

    rails g dynamican_migration

This command will generate a migration file in your project, which you can run with

    rails db:migrate

In each model you want to have the feature, just put the following.

    include Dynamican::Model

### Using a model permissions on another model

I wanted to have the possibility to assign permissions both directly to my User model and my Role model, so that if the User had one permission and one of its Roles had another, the User could benefit from both. So i included the feature into both models and then decorated my User model like following.

    module Decorators
      module Models
        module User
          module DynamicanOverrides
            def self.prepended(base)
              base.class_eval do
                has_many :user_permissions, class_name: 'Dynamican::Permission', as: :permittable, inverse_of: :permittable, foreign_key: :permittable_id
                has_many :role_permissions, through: :roles, class_name: 'Dynamican::Permission', source: :permissions
              end
            end

            def permissions
              Dynamican::Permission.where(id: user_permissions.ids + role_permissions.ids)
            end

            ::User.prepend self
          end
        end
      end
    end

I personally have put this in `app/decorators/models/user/dynamican_overrides.rb` (rails needs to load the folder of course); you can make it work as you please but i recommend to keep it separate from the original User model.

## Usage

Now the hard part: the real configuration.

Create one `Dynamican::Action` for each action you need. For example i created CRUD permissions.

    a1 = Dynamican::Action.create(name: 'create')
    a2 = Dynamican::Action.create(name: 'read')
    a3 = Dynamican::Action.create(name: 'update')
    a4 = Dynamican::Action.create(name: 'delete')

Then create one `Dynamican::Item` for each resource you want your permittables to have permissions to act on. This is not mandatory for every permission though: you can also set a permission to do a general action, like `login`. Right now i'm trying to setup permissions for my permittable (Role model) to act on Order model.

    i1 = Dynamican::Item.create(name: 'Order')

NOTE: conventionally, the name should be PascalCase, so there is a `before_validation` hook that classifies the name you are setting.

Create one `Dynamican::Permission` for each action you want your `role` instance to have permissions for.

    p1 = Dynamican::Permission.create(action: a1, items: [i1], permittable: role)
    p2 = Dynamican::Permission.create(action: a2, items: [i1], permittable: role)
    p3 = Dynamican::Permission.create(action: a3, items: [i1], permittable: role)
    p4 = Dynamican::Permission.create(action: a4, items: [i1], permittable: role)

Now your Role is considered able to create, read, update and destroy orders; you can evaluate permissions with `can?` method.

    role.can? :create, :order

    # true

    role.can? :else, :order

    # false

You can pass as second argument (the item) a symbol, a string, the class itself and also the instance (instances are required for condition evaluations).
If you pass an array of these elements, permissions for all single element will be evaluated. The `can?` method will return true only if permissions to all items are evaluated positively.
You can also create custom permissions which don't need an item, (item is not required for permission creation). Let's say you want to give permission to a certain `user` to dance.

    action_dance = Dynamican::Action.create(name: 'dance')
    p5 = Dynamican::Permission.create(action: action_dance, permittable: user)

Call the `can?` method without any second argument

    user.can? :dance

    # true


### Conditions

You can link a `Dynamican::Permission` to as many conditions as you want. A permission having at least one condition linked to is considered conditional (Permission class have `conditional` and `unconditional` scopes)

Conditions are created like this.

    permission.conditions.create(statement: '@user.orders.count < 5')
    permission.conditions.create(statement: '@item.field.present?')

You can store in conditions statements whatever conditions you like in plain ruby and the string will be evaulated. Inside the statements, object have to be called as instance variables. These instance variables indeed need to be present and can be declared in a few ways.

1. The model name of the instance you called `can?` from, like the user, will be defined automatically based both on a fixed name and on model name, so if you call `user.can?` you will have `@subject` variable (this is fixed) and `@user` variable defined because user is of class `User` (namespaces get cut out, so `Something::User` still turne into `@user`).
2. The same thing happens with the item: it will be defined both as `@item` and as the name of its class, so if you call `user.can? :read, @order` you will have `@item` and `@order` variable defined containing your `@order` object.
3. You can pass as third argument an hash of objects like this `user.can? :read, @order, time: Time.zone.now, whatever: @you_want` and you will have `@time` and `@whatever` variables defined.

WARNING: since the condition statement gets evaluated, i recommend not to allow anyone except project developers to create conditions, in order to prevent malicious code from being executed.

If one `Dynamican::Permission` is linked to many conditions, the model will be allowed to make that action only if all conditions are true. If you want to set alternative conditions, you should store the `or` conditions inside the same condition statement, like this:

    condition.statement = '@user.nice? || @user.polite?'

### Permission scopes

You can apply the scope `for_action(action_name)` to Permission to find permissions bound to a specific action.
There is a `for_item(item_name)` scope, which turns to string and then classifies automatically the argument to match it with the classified item name. The scope filters all Permission records that have an item with the specified name in its items list.
There is also a `without_item` scope to filter records that are not linked to any item.
As mentioned before, you can also use `conditional` and `unconditional` scopes to find objects with or without any condition attached.
