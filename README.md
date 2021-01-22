# Logisticed
轻松记录每条记录状态变更时的操作时间以及操作人
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

你只需要告诉 `logisticed` 需要监听什么字段， 并且被修改为什么值的时候就行了。

```ruby
class Page < ActiveRecord::Base
  logisticed :status, values: [:active, :archived]
end

他将会为你提供 `active_at`、 `active_by`、 `archived_at`、 `archived_by` 这几个方法，为你提供某个状态最近的操作历史
```

如果在 model 中定义了枚举类型的字段，也可以在定义枚举的下面直接添加 `logisticed`，他会自动为你监听枚举的所有值，同时 logisticed 支持 `only` 和 `except` 这两个参数

```ruby
class Page < ActiveRecord::Base
  enum status: [:draft, :active, :archived]
  logisticed :status, only: [:active, :archived]
end
```

现在就已经可以监听所有的操作人和操作时间等信息了
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

当然你也可以使用 `@page.logistics` 得到 @page 这条记录的所有变更流程，也可以使用 `@page.active_logistics` 得到状态变为 active 的所有变更流程

除此之外你也可以使用 `as_user` 制定某个用户成为操作人员

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