
# frozen_string_literal: true

module Icinga2

  # namespace for service handling
  module Services

    # add services
    #
    # @param [Hash] params
    # @option params [String] :host
    # @option params [String] :services
    #
    # @todo
    #  this function is not operable
    #  need help, time or beer
    #
    # @return [Hash]
    #
    def add_services( params = {} )

      raise ArgumentError.new('only Hash are allowed') unless( params.is_a?(Hash) )

      # TODO
      puts 'add_services() ToDo'

      host_name = params.dig(:host)
      services  = params.dig(:services)

      services.each do |s,v|

        payload = {
          'templates' => [ 'generic-service' ],
          'attrs'     => update_host( v, host_name )
        }

        logger.debug( s )
        logger.debug( v.to_json )

        logger.debug( JSON.pretty_generate( payload ) )

        Network.put(
          url: format( '%s/objects/services/%s!%s', @icinga_api_url_base, host_name, s ),
          headers: @headers,
          options: @options,
          payload: payload
        )
      end

    end

    # return all unhandled services
    #
    # @param [Hash] params
    #
    # @todo
    #  this function is not operable
    #  need help, time or beer
    #
    # @return [Nil]
    #
    def unhandled_services( params = {} )

      raise ArgumentError.new('only Hash are allowed') unless( params.is_a?(Hash) )

      # TODO
      puts 'unhandled_services() ToDo'

      # taken from https://blog.netways.de/2016/11/18/icinga-2-api-cheat-sheet/
      # 5) Anzeige aller Services die unhandled sind und weder in Downtime, noch acknowledged sind
      # /usr/bin/curl -k -s -u 'root:icinga' -H 'X-HTTP-Method-Override: GET' -X POST
      # 'https://127.0.0.1:5665/objects/services' #
      # -d '{ "attrs": [ "__name", "state", "downtime_depth", "acknowledgement" ], "filter": "service.state != ServiceOK && service.downtime_depth == 0.0 && service.acknowledgement == 0.0" }''' | jq

    end

    # return services
    #
    # @param [Hash] params
    # @option params [String] :host
    # @option params [String] :service
    #
    # @example to get all services
    #    @icinga.services
    #
    # @example to get one service for host
    #    @icinga.services( host: 'icinga2', service: 'ping4' )
    #
    # @return [Hash]
    #
    def services( params = {} )

      raise ArgumentError.new('only Hash are allowed') unless( params.is_a?(Hash) )

      host_name = params.dig(:host)
      service   = params.dig(:service)

      url =
      if( service.nil? )
        format( '%s/objects/services/%s', @icinga_api_url_base, host_name )
      else
        format( '%s/objects/services/%s!%s', @icinga_api_url_base, host_name, service )
      end

      data = Network.api_data(
        url: url,
        headers: @headers,
        options: @options
      )

      return data.dig('results') if( data.dig(:status).nil? )

      nil
    end

    # returns true if the service exists
    #
    # @param [Hash] params
    # @option params [String] :host
    # @option params [String] :service
    #
    # @example
    #    @icinga.exists_service?(host: 'icinga2', service: 'users' )
    #
    # @return [Bool]
    #
    def exists_service?( params )

      raise ArgumentError.new('only Hash are allowed') unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing params') if( params.size.zero? )

      host    = params.dig(:host)
      service = params.dig(:service)

      raise ArgumentError.new('Missing host') if( host.nil? )
      raise ArgumentError.new('Missing service') if( service.nil? )

      result = services( host: host, service: service )
      result = JSON.parse( result ) if  result.is_a?( String )

      return true if  !result.nil? && result.is_a?(Array)

      false
    end

    # returns service objects
    #
    # @param [Hash] params
    # @option params [Array] :attrs (['name', 'state', 'acknowledgement', 'downtime_depth', 'last_check'])
    # @option params [Array] :filter ([])
    # @option params [Array] :joins (['host.name','host.state','host.acknowledgement','host.downtime_depth','host.last_check'])
    #
    # @example with default attrs and joins
    #    @icinga.service_objects
    #
    # @example
    #    @icinga.service_objects(attrs: ['name', 'state'], joins: ['host.name','host.state'])
    #
    # @return [Array]
    #
    def service_objects( params = {} )

      attrs   = params.dig(:attrs)
      filter  = params.dig(:filter)
      joins   = params.dig(:joins)
      payload = {}

      if( attrs.nil? )
        attrs = %w[name state acknowledgement downtime_depth  last_check]
      end

      if( joins.nil? )
        joins = ['host.name', 'host.state', 'host.acknowledgement', 'host.downtime_depth', 'host.last_check']
      end

      payload['attrs']  = attrs unless  attrs.nil?
      payload['filter'] = filter unless filter.nil?
      payload['joins']  = joins unless  joins.nil?

      data = Network.api_data(
        url: format( '%s/objects/services', @icinga_api_url_base ),
        headers: @headers,
        options: @options,
        payload: payload
      )

      status  = data.dig(:status)

      if( status.nil? )

        results = data.dig('results')

        unless( results.nil? )

          all_services = results.clone

          unless( all_services.nil? )

            @services_all              = all_services.size
            @services_problems         = count_problems(results)
            @services_handled_warning  = count_problems(results, Icinga2::SERVICE_STATE_WARNING)
            @services_handled_critical = count_problems(results, Icinga2::SERVICE_STATE_CRITICAL)
            @services_handled_unknown  = count_problems(results, Icinga2::SERVICE_STATE_UNKNOWN)
          end
        end
      end

      results
    end

    # returns adjusted service state
    #
    # @example
    #    @icinga.cib_data
    #    @icinga.service_objects
    #    warning, critical, unknown = @icinga.services_adjusted.values
    #
    #    s = @icinga.services_adjusted
    #    unknown = s.dig(:unknown)
    #
    # @return [Hash]
    #    * warning
    #    * critical
    #    * unknown
    #
    def services_adjusted

      service_warning          = @services_warning.nil?          ? 0 : @services_warning
      service_critical         = @services_critical.nil?         ? 0 : @services_critical
      service_unknown          = @services_unknown.nil?          ? 0 : @services_unknown
      service_handled_warning  = @services_handled_warning.nil?  ? 0 : @services_handled_warning
      service_handled_critical = @services_handled_critical.nil? ? 0 : @services_handled_critical
      service_handled_unknown  = @services_handled_unknown.nil?  ? 0 : @services_handled_unknown

      # calculate service problems adjusted by handled problems
      service_adjusted_warning  = service_warning  - service_handled_warning
      service_adjusted_critical = service_critical - service_handled_critical
      service_adjusted_unknown  = service_unknown  - service_handled_unknown

      {
        warning: service_adjusted_warning.to_i,
        critical: service_adjusted_critical.to_i,
        unknown: service_adjusted_unknown.to_i
      }
    end

    # return count of services with problems
    #
    # @example
    #    @icinga.count_services_with_problems
    #
    # @return [Integer]
    #
    def count_services_with_problems

      service_data = service_objects
      service_data = JSON.parse(service_data) if service_data.is_a?(String)

      f = service_data.select { |t| t.dig('attrs','state') != 0 && t.dig('attrs','downtime_depth').zero? && t.dig('attrs','acknowledgement').zero? }

      f.size
    end

    # return a list of services with problems
    #
    # @param [Integer] max_items numbers of list entries
    #
    # @example
    #    problems, problems_and_severity = @icinga.list_services_with_problems.values
    #
    #    l = @icinga.list_services_with_problems
    #    problems_and_severity = l.dig(:services_with_problems_and_severity)
    #
    # @return [Hash]
    #    * Array (services_with_problems)
    #    * Hash  (services_with_problems_and_severity)
    #
    def list_services_with_problems( max_items = 5 )

      services_with_problems = {}
      services_with_problems_and_severity = {}

      # only fetch the minimal attribute set required for severity calculation
      services_data = service_objects
      services_data = JSON.parse( services_data ) if services_data.is_a?(String)

      unless( services_data.nil? )

        services_data.each do |s,_v|

          name  = s.dig('name')
          state = s.dig('attrs','state')
          next if  state.zero?

          services_with_problems[name] = service_severity(s)
        end

        if( services_with_problems.count != 0 )
          services_with_problems.sort.reverse!
          services_with_problems = services_with_problems.keys[1..max_items].each { |k,_v| services_with_problems_and_severity[k] = services_with_problems[k] }
        end
      end

      {
        services_with_problems: services_with_problems,
        services_with_problems_and_severity: services_with_problems_and_severity
      }
    end

    # update host
    #
    # @param [Hash] hash
    # @param [String] host
    #
    # @todo
    #  this function are not operable
    #  need help, time or beer
    #
    # @return [Hash]
    #
    def update_host( hash, host )

      hash.each do |k, v|

        if( k == 'host' && v.is_a?( String ) )
          v.replace( host )

        elsif( v.is_a?( Hash ) )
          update_host( v, host )

        elsif( v.is_a?(Array) )

          v.flatten.each { |x| update_host( x, host ) if x.is_a?( Hash ) }
        end
      end

      hash
    end

    # returns a counter of all services
    #
    # @example
    #    @icinga.cib_data
    #    @icinga.service_objects
    #    @icinga.services_all
    #
    # @return [Integer]
    #
    def services_all
      @services_all
    end

    # returns data with service problems they be handled (acknowledged or in downtime)
    #
    # @example
    #    @icinga.cib_data
    #    @icinga.service_objects
    #    all, critical, warning, unknown = @icinga.service_problems_handled.values
    #
    #    p = @icinga.service_problems_handled
    #    warning = p.dig(:warning)
    #
    # @return [Hash]
    #    * all
    #    * critical
    #    * warning
    #    * unknown
    #
    def service_problems_handled

      problems_all      = @services_handled.nil?          ? 0 : @services_handled
      problems_critical = @services_handled_critical.nil? ? 0 : @services_handled_critical
      problems_warning  = @services_handled_warning.nil?  ? 0 : @services_handled_warning
      problems_unknown  = @services_handled_unknown.nil?  ? 0 : @services_handled_unknown

      {
        all: problems_all.to_i,
        critical: problems_critical.to_i,
        warning: problems_warning.to_i,
        unknown: problems_unknown.to_i
      }

#      [problems_all,problems_critical,problems_warning,problems_unknown]
    end

    protected
    # calculate a service severity
    #
    # stolen from Icinga Web 2
    # ./modules/monitoring/library/Monitoring/Backend/Ido/Query/ServicestatusQuery.php
    #
    # @param [Hash] params
    # @option params [hash] attrs ()
    #   * state [Float]
    #   * acknowledgement [Float] (default: 0)
    #   * downtime_depth [Float] (default: 0)
    #
    # @api protected
    #
    # @example
    #   service_severity( {'attrs' => { 'state' => 0.0, 'acknowledgement' => 0.0, 'downtime_depth' => 0.0 } } )
    #
    # @return [Integer]
    #
    def service_severity( params )

      raise ArgumentError.new('only Hash are allowed') unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing params') if( params.size.zero? )

      state           = params.dig('attrs','state')
      acknowledgement = params.dig('attrs','acknowledgement') || 0
      downtime_depth  = params.dig('attrs','downtime_depth')  || 0

      raise ArgumentError.new('only Float for state are allowed') unless( state.is_a?(Float) )
      raise ArgumentError.new('only Float for acknowledgement are allowed') unless( acknowledgement.is_a?(Float) )
      raise ArgumentError.new('only Float for downtime_depth are allowed') unless( downtime_depth.is_a?(Float) )

      severity = 0

      severity +=
        if acknowledgement != 0
          2
        elsif downtime_depth > 0
          1
        else
          4
        end

      severity += 16 if object_has_been_checked?(params)

      unless state.zero?

        severity +=
          if state == 1
            32
          elsif state == 2
            64
          else
            256
          end

        # requires joins
        host_attrs = params.dig('joins','host')
        host_state           = host_attrs.dig('state')
        host_acknowledgement = host_attrs.dig('acknowledgement')
        host_downtime_depth  = host_attrs.dig('downtime_depth')

        severity +=
          if host_state > 0
            1024
          elsif host_acknowledgement
            512
          elsif host_downtime_depth > 0
            256
          else
            2048
          end

      end

      severity
    end

  end
end
