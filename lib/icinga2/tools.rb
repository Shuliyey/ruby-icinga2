# encoding: UTF-8
# frozen_string_literal: false

# module
module Icinga2
  #
  module Tools
    #
    def object_has_been_checked?(object)
      object.dig('attrs', 'last_check').positive?
    end
  end
end
