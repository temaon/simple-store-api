# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(_user); end
end
