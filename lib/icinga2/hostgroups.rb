
# frozen_string_literal: false

module Icinga2

  # namespace for hostgroup handling
  module Hostgroups

    # add a hostgroup
    #
    # @param [Hash] params
    # @option params [String] :host_group hostgroup to create
    # @option params [String] :display_name the displayed name
    #
    # @example
    #   @icinga.add_hostgroup(host_group: 'foo', display_name: 'FOO')
    #
    # @return [Hash] result
    #
    def add_hostgroup( params )

      raise ArgumentError.new('only Hash are allowed') unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing params') if( params.size.zero? )

      host_group   = params.dig(:host_group)
      display_name = params.dig(:display_name)

      raise ArgumentError.new('Missing host_group') if( host_group.nil? )
      raise ArgumentError.new('Missing display_name') if( display_name.nil? )

      put(
        url: format('%s/objects/hostgroups/%s', @icinga_api_url_base, host_group),
        headers: @headers,
        options: @options,
        payload: { 'attrs' => { 'display_name' => display_name } }
      )
    end

    # delete a hostgroup
    #
    # @param [Hash] params
    # @option params [String] :name hostgroup to delete
    #
    # @example
    #   @icinga.delete_hostgroup(host_group: 'foo')
    #
    # @return [Hash] result
    #
    def delete_hostgroup( params )

      raise ArgumentError.new('only Hash are allowed') unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing params') if( params.size.zero? )

      host_group = params.dig(:host_group)

      raise ArgumentError.new('Missing host_group') if( host_group.nil? )

      delete(
        url: format('%s/objects/hostgroups/%s?cascade=1', @icinga_api_url_base, host_group),
        headers: @headers,
        options: @options
      )
    end

    # returns all usersgroups
    #
    # @param [Hash] params
    # @option params [String] :host_group ('') optional for a single hostgroup
    #
    # @example to get all users
    #    @icinga.hostgroups
    #
    # @example to get one user
    #    @icinga.hostgroups(host_group: 'linux-servers')
    #
    # @return [Hash] returns a hash with all hostgroups
    #
    def hostgroups( params = {} )

      host_group = params.dig(:host_group)

      url =
      if( host_group.nil? )
        format( '%s/objects/hostgroups'   , @icinga_api_url_base )
      else
        format( '%s/objects/hostgroups/%s', @icinga_api_url_base, host_group )
      end

      api_data(
        url: url,
        headers: @headers,
        options: @options
      )
    end

    # returns true if the hostgroup exists
    #
    # @param [String] host_group the name of the hostgroup
    #
    # @example
    #    @icinga.exists_hostgroup?('linux-servers')
    #
    # @return [Bool] returns true if the hostgroup exists
    #
    def exists_hostgroup?( host_group )

      raise ArgumentError.new('only String are allowed') unless( host_group.is_a?(String) )
      raise ArgumentError.new('Missing host_group') if( host_group.size.zero? )

      result = hostgroups(host_group: host_group)
      result = JSON.parse( result ) if( result.is_a?(String) )
      result = result.first if( result.is_a?(Array) )

      return false if( result.is_a?(Hash) && result.dig('code') == 404 )

      true
    end

  end
end
