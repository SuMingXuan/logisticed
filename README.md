# Logisticed

[中文文档](README.zh-cn.md)

Easily record the operation time and operator for each record's status change.
## Installation

Add this line to your application's Gemfile:

```ruby
gem 'logisticed'
```

Then, from your Rails app directory, create the `logistics` table:
```bash
$ rake logisticed_migration:install:migrations
$ rails db:migrate
```
## Usage

You only need to tell logisticed which field to listen to and when it is changed to what value.

It will provide you with several methods like `active_at`, `active_by`, `archived_at`, `archived_by`, giving you the recent operation history for a specific status.

```ruby
class Page < ActiveRecord::Base
  logisticed :status, values: [:active, :archived]
end
```

If you've defined an `enum` type field in the model, you can directly add logisticed below the enum definition. It will automatically listen to all values of the enum. 

```ruby
class Page < ActiveRecord::Base
  enum status: [:draft, :active, :archived]
  logisticed :status
end
```

At the same time, logisticed supports the `only` and `except` parameters.

```ruby
class Page < ActiveRecord::Base
  enum status: [:draft, :active, :archived]
  logisticed :status, only: [:active, :archived]
end
```


Now you can listen to all the information about operators and operation time.

```ruby
class PagesController < ApplicationController
  def create
    current_user # => #<User name: 'sss'>
    @page = Page.first # => #<Page status: 'draft'>
    @page.active!
    @page.active_at # => 2021-01-22 17:15:13 +0800
    @page.active_by # => #<User name: 'sss'>
  end
end
```

You can use `@page.logistics` to get all change processes for the record, or use `@page.active_logistics` to get all change processes when the status becomes active.

In addition, you can use `as_user` to specify a user as an operator.

```ruby
class PagesController < ApplicationController
  def create
    current_user # => #<User name: 'sss'>
    user = User.last # => #<User name: 'smx'>
    Logisticed::Logistic.as_user(user) do
      @page = Page.first # => #<Page status: 'draft'>
      @page.active!
      @page.active_at # => 2021-01-22 17:15:13 +0800
      @page.active_by # => #<User name: 'smx'>
    end
  end
end
```
# setting

```ruby
# config/initializers/logisticed.rb

Logisticed.config do |config|
  config.current_user_method                = :authenticated_user
  # if your table primary_key type is uuid
  config.logisticed_source_id_column_type   = :uuid
  config.logisticed_operator_id_column_type = :uuid
end
```