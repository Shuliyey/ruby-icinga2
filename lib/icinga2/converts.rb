
# frozen_string_literal: true

module Icinga2

  # many convert functions
  #
  #
  module Converts

    # convert a Icinga2 state into a human readable state
    #
    # @param [String, #read] state the Icinga2 State
    # @param [Bool, #read] is_host if this a Host or a Service Check
    #
    # @return [String, #read]
    def self.state_to_string( state, is_host = false )

      state =
      if( is_host == true )
        case state
        when 0
          'Up'
        when 1
          'Down'
        else
          'Undefined'
        end
      else
        case state
        when 0
          'OK'
        when 1
          'Warning'
        when 2
          'Critical'
        when 3
          'Unknown'
        else
          'Undefined'
        end
      end
      state
    end

    # convert a Icinga2 state into a named color
    #
    # @param [String, #read] state the Icinga2 State
    # @param [Bool, #read] is_host if this a Host or a Service Check
    #
    # @return [String, #read]
    def self.state_to_color( state, is_host = false )

      state =
      if( is_host == true )
        case state
        when 0
          'green'
        when 1
          'red'
        else
          'blue'
        end
      else
        case state
        when 0
          'green'
        when 1
          'yellow'
        when 2
          'red'
        when 3
          'purple'
        else
          'blue'
        end
      end
      state
    end

    # reformat a service check name
    #
    # @param [String, #read] name
    #
    # @return [String, #read]
    def self.format_service( name )
      service_map = name.split('!', 2)
      service_map.join( ' - ' )
    end

  end
end
