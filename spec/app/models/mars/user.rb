# encoding: utf-8
module Mars
  class User
    include Mongoid::Document
    include Streama::Actor

    field :full_name

    def followers
      self.class.all
    end

  end

end
