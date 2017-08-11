
# frozen_string_literal: true

module Icinga2

  # namespace for usergroup handling
  module Usergroups

    # add a usergroup
    #
    # @param [Hash] params
    # @option params [String] :user_group usergroup to create
    # @option params [String] :display_name the displayed name
    #
    # @example
    #   @icinga.add_usergroup(name: 'foo', display_name: 'FOO')
    #
    # @return [Hash] result
    #
    def add_usergroup( params = {} )

      user_group     = params.dig(:user_group)
      display_name = params.dig(:display_name)

      if( user_group.nil? )
        return {
          status: 404,
          message: 'missing usergroup name'
        }
      end

      payload = {
        'attrs' => {
          'display_name' => display_name
        }
      }

      Network.put(
        url: format( '%s/objects/usergroups/%s', @icinga_api_url_base, user_group ),
        headers: @headers,
        options: @options,
        payload: payload
      )
    end

    # delete a usergroup
    #
    # @param [Hash] params
    # @option params [String] :user_group usergroup to delete
    #
    # @example
    #   @icinga.delete_usergroup(name: 'foo')
    #
    # @return [Hash] result
    #
    def delete_usergroup( params = {} )

      user_group = params.dig(:user_group)

      if( user_group.nil? )
        return {
          status: 404,
          message: 'missing usergroup name'
        }
      end

      Network.delete(
        url: format( '%s/objects/usergroups/%s?cascade=1', @icinga_api_url_base, user_group ),
        headers: @headers,
        options: @options
      )
    end

    # returns all usersgroups
    #
    # @param [Hash] params
    # @option params [String] :user_group ('') optional for a single usergroup
    #
    # @example to get all users
    #    @icinga.usergroups
    #
    # @example to get one user
    #    @icinga.usergroups(user_group: 'icingaadmins')
    #
    # @return [Hash] returns a hash with all usergroups
    #
    def usergroups( params = {} )

      user_group = params.dig(:user_group)

      url =
      if( user_group.nil? )
        format( '%s/objects/usergroups'   , @icinga_api_url_base )
      else
        format( '%s/objects/usergroups/%s', @icinga_api_url_base, user_group )
      end

      data = Network.api_data(
        url: url,
        headers: @headers,
        options: @options
      )

      return data.dig('results') if( data.dig(:status).nil? )

      nil
    end

    # returns true if the usergroup exists
    #
    # @param [String] name the name of the usergroups
    #
    # @example
    #    @icinga.exists_usergroup?('icingaadmins')
    #
    # @return [Bool] returns true if the usergroup exists
    #
    def exists_usergroup?( name )

      result = usergroups( name: name )
      result = JSON.parse( result ) if  result.is_a?( String )

      return true if  !result.nil? && result.is_a?(Array)

      false
    end

  end
end
