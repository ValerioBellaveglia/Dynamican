# Dynamican
Dynamican is a flexible gem to introduce permissions on rails applications. It is very customizable because it stores all the rules inside the database and can be added to multiple models: for example you can add permissions to your Role model or to users. With a couple of overrides you can also add permissions to both Role and User and use role permissions through user.

## Installation
Inside your Gemfile put

    gem 'dynamican'

then run `bundle install`

Once you have the gem, open the source code and look for migrations folder. You need to create in your project those migrations and run them. Obviously if you already have the gem installed and you are only updating, you only need to create the migrations for the later versions of the gem.

In each model you want to have the feature, just put

    include Dynamican::Model

Create `config/dynamican.yml` file and compile it as follows for each of the models you included the code above into (let's say for instance you included Dynamican::Model into User and Role models)

    associations:
      role:
        class_name: 'Role'
      user:
        class_name: 'User'

### Using permissions on one model through another model

I wanted to have the possibility to assign permissions both directly to my User model and my Role model, so that if the User had one permission and one of its Role had another, the User could benefit from both. So i assigned the feature (as explained above) to both models and then decorated my User model like this

    module Decorators
      module Models
        module User
          module DynamicanOverrides
            def self.prepended(base)
              base.class_eval do
                has_many :user_permission_connectors, class_name: 'Dynamican::PermissionConnector'
                has_many :user_permissions, class_name: 'Dynamican::Permission', through: :user_permission_connectors, source: :permission
                has_many :role_permissions, through: :roles, class_name: 'Dynamican::Permission', source: :permissions
              end
            end

            def permission_connectors
              Dynamican::PermissionConnector.where(id: user_permission_connectors.ids + roles.map(&:permission_connectors).flatten.map(&:id))
            end

            def permissions
              Dynamican::Permission.where(id: user_permissions.ids + role_permissions.ids)
            end

            ::User.prepend self
          end
        end
      end
    end

I personally have put this in `app/decorators/models/user/dynamican_overrides.rb` (you need to load the folder if you don't already have it) but you can make it work as you please. I recommend to keep it separate from the original User model though.

## Usage

Now the hard part: the real configuration.

Create one `Dynamican::Permission` for each pair of action-object you need. For example i created CRUD permissions for my models. Let's say, for instance, you have the Order model.

    p1 = Dynamican::Permission.create(action: 'create', object_name: 'order')
    p2 = Dynamican::Permission.create(action: 'read', object_name: 'order')
    p3 = Dynamican::Permission.create(action: 'update', object_name: 'order')
    p4 = Dynamican::Permission.create(action: 'delete', object_name: 'order')

To assign one of these permissions to your Role or User, you need to create a `Dynamican::PermissionConnector` like this

    user.permission_connectors.create(permission: p1)

Or simply

    user.permissions << p1

Now your user is considered able to create orders and you can check the permissions:

    user.can? :create, :order
    # Returns true

    user.can? :read, :order
    # Returns false

You can pass as second argument (the object) a symbol, a string, the class itself and also the instance (instances are used for condition evaluations).
You can also pass an array of these elements and permissions for all elements will be evaluated. The `can?` method will return true only if all permissions are evaluated positively.
You can also create custom permissions which don't need an object, simply leaving the `object_name` empty. Let's say you want to give permission to a certain user to dance

    p5 = Dynamican::Permission.create(action: 'dance')

    user.permissions << p5

Call the `can?` method without any second argument

    user.can? :dance

    # Returns true


## Conditions

You can link a `Dynamican::PermissionConnector` to as many conditions as you want.

Conditions are created like this

    permission_connector.conditions.create(statement: '@user.orders.count < 5')
    permission_connector.conditions.create(statement: '@object.field.present?')

You can store in conditions statements whatever conditions you like in plain ruby and the string will be evaulated. Inside the statements, object have to be called as instance variables. These instance variables need to be present and can be declared as follows:

1. The model name of the instance you called `can?` from, like the user, will be defined automatically based on model name so if you call `user.can?` you will have `@user` variable defined.
2. The object you pass as second argument (which should match the `object_name` of your permission) will be defined as `@object`, so if you call `user.can? :read, @order` you will have `@object` variable defined containing your `@order`.
3. You can pass as third argument an hash of objects like this `user.can? :read, @order, time: Time.zone.now, whatever: @you_want` and you will have `@time` and `@whatever` variables defined.

WARNING: since the condition statement gets evaluated, i recommend not to allow anyone except project developers to create conditions to prevent malicious code from being executed.

If one `Dynamican::PermissionConnector` is linked to many conditions, the model will be allowed to make that action only if all conditions are true. If you want to set alternative conditions, you should store the or conditions inside the same statement, like this:

    condition.statement = '@user.nice? || @user.polite?'
