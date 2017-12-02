
# frozen_string_literal: true
module Icinga2

  # namespace for network handling
  module Network

    # static function for GET Requests
    #
    # @param [Hash] params
    # @option params [String] :host
    # @option params [String] :url
    # @option params [String] :headers
    # @option params [String] :options
    # @option params [Hash] :payload
    #
    #
    # @return [Hash]
    #
    def api_data( params )

      raise ArgumentError.new(format('wrong type. \'params\' must be an Hash, given \'%s\'', params.class.to_s)) unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing params') if( params.size.zero? )

      url     = params.dig(:url)
      headers = params.dig(:headers)
      options = params.dig(:options)
      payload = params.dig(:payload)

      raise ArgumentError.new('Missing url') if( url.nil? )
      raise ArgumentError.new('Missing headers') if( headers.nil? )
      raise ArgumentError.new('Missing options') if( options.nil? )

      rest_client = RestClient::Resource.new( URI.encode( url ), options )

      if( payload )
        raise ArgumentError.new('only Hash for payload are allowed') unless( payload.is_a?(Hash) )
        headers['X-HTTP-Method-Override'] = 'GET'
        method = 'POST'
      else
        headers['X-HTTP-Method-Override'] = 'GET'
        method = 'GET'
      end

      begin
        data = request( rest_client, method, headers, payload )

        data = JSON.parse( data ) if( data.is_a?(String) )
        data = data.deep_string_keys
        data = data.dig('results') if( data.is_a?(Hash) )

        return data

      rescue => e

        logger.error(e)
        logger.error(e.backtrace.join("\n"))

        return nil
      end
    end

    # static function for GET Requests without filters
    #
    # @param [Hash] params
    # @option params [String] :host
    # @option params [String] :url
    # @option params [String] :headers
    # @option params [String] :options
    # @option params [Hash] :payload
    #
    #
    # @return [Hash]
    #
    def icinga_application_data( params )

      raise ArgumentError.new(format('wrong type. \'params\' must be an Hash, given \'%s\'', params.class.to_s)) unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing params') if( params.size.zero? )

      url     = params.dig(:url)
      headers = params.dig(:headers)
      options = params.dig(:options)

      raise ArgumentError.new('Missing url') if( url.nil? )
      raise ArgumentError.new('Missing headers') if( headers.nil? )
      raise ArgumentError.new('Missing options') if( options.nil? )

      begin

        data = api_data( url: url, headers: headers, options: options )
        data = data.first if( data.is_a?(Array) )

        data

        return data.dig('status') unless( data.nil? )

      rescue => e

        logger.error(e)
        logger.error(e.backtrace.join("\n"))

        return nil
      end

    end

    # static function for POST Requests
    #
    # @param [Hash] params
    # @option params [String] :url
    # @option params [String] :headers
    # @option params [String] :options
    # @option params [Hash] :payload
    #
    #
    # @return [Hash]
    #
    def post( params )

      raise ArgumentError.new(format('wrong type. \'params\' must be an Hash, given \'%s\'', params.class.to_s)) unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing params') if( params.size.zero? )

      url     = params.dig(:url)
      headers = params.dig(:headers)
      options = params.dig(:options)
      payload = params.dig(:payload)

      raise ArgumentError.new('Missing url') if( url.nil? )
      raise ArgumentError.new('Missing headers') if( headers.nil? )
      raise ArgumentError.new('Missing options') if( options.nil? )
      raise ArgumentError.new('only Hash for payload are allowed') unless( payload.is_a?(Hash) )

      rest_client = RestClient::Resource.new( URI.encode( url ), options )
      headers['X-HTTP-Method-Override'] = 'POST'

      begin
        data = request( rest_client, 'POST', headers, payload )

        data = JSON.parse( data ) if( data.is_a?(String) )
        data = data.deep_string_keys
        data = data.dig('results').first if( data.is_a?(Hash) )

        return { 'code' => data.dig('code').to_i, 'name' => data.dig('name'), 'status' => data.dig('status') } unless( data.nil? )

      rescue => e

        logger.error(e)
        logger.error(e.backtrace.join("\n"))

        return nil
      end
    end

    # static function for PUT Requests
    #
    # @param [Hash] params
    # @option params [String] :host
    # @option params [String] :url
    # @option params [String] :headers
    # @option params [String] :options
    # @option params [Hash] :payload
    #
    #
    # @return [Hash]
    #
    def put( params )

      raise ArgumentError.new(format('wrong type. \'params\' must be an Hash, given \'%s\'', params.class.to_s)) unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing params') if( params.size.zero? )

      url     = params.dig(:url)
      headers = params.dig(:headers)
      options = params.dig(:options)
      payload = params.dig(:payload)

      raise ArgumentError.new('Missing url') if( url.nil? )
      raise ArgumentError.new('Missing headers') if( headers.nil? )
      raise ArgumentError.new('Missing options') if( options.nil? )
      raise ArgumentError.new('only Hash for payload are allowed') unless( payload.is_a?(Hash) )

      rest_client = RestClient::Resource.new( URI.encode( url ), options )
      headers['X-HTTP-Method-Override'] = 'PUT'

      begin

        data = request( rest_client, 'PUT', headers, payload )
        data = JSON.parse( data ) if( data.is_a?(String) )
        data = data.deep_string_keys

        if( data.is_a?(Hash) )
          results = data.dig('results')
          results = results.first if( results.is_a?(Array) )
        else
          results = data
        end

        return { 'code' => results.dig('code').to_i, 'name' => results.dig('name'), 'status' => results.dig('status') } unless( results.nil? )

      rescue => e

        logger.error(e)
        logger.error(e.backtrace.join("\n"))

        return nil
      end
    end

    # static function for DELETE Requests
    #
    # @param [Hash] params
    # @option params [String] :url
    # @option params [String] :headers
    # @option params [String] :options
    #
    #
    # @return [Hash]
    #
    def delete( params )

      raise ArgumentError.new(format('wrong type. \'params\' must be an Hash, given \'%s\'', params.class.to_s)) unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing params') if( params.size.zero? )

      url     = params.dig(:url)
      headers = params.dig(:headers)
      options = params.dig(:options)

      raise ArgumentError.new('Missing url') if( url.nil? )
      raise ArgumentError.new('Missing headers') if( headers.nil? )
      raise ArgumentError.new('Missing options') if( options.nil? )

      rest_client = RestClient::Resource.new( URI.encode( url ), options )
      headers['X-HTTP-Method-Override'] = 'DELETE'

      begin
        data = request( rest_client, 'DELETE', headers )

        data = JSON.parse( data ) if( data.is_a?(String) )
        data = data.deep_string_keys

        if( data.is_a?(Hash) )
          results = data.dig('results')
          results = results.first if( results.is_a?(Array) )
        else
          results = data
        end

        return { 'code' => results.dig('code').to_i, 'name' => results.dig('name'), 'status' => results.dig('status') } unless( results.nil? )

      rescue => e
        logger.error(e)
        logger.error(e.backtrace.join("\n"))

        return nil
      end
    end

    private
    #
    # internal functionfor the Rest-Client Request
    #
    def request( client, method, headers, data = {} )

      # logger.debug( "request( #{client.to_s}, #{method}, #{headers}, #{options}, #{data} )" )

      raise ArgumentError.new('client must be an RestClient::Resource') unless( client.is_a?(RestClient::Resource) )
      raise ArgumentError.new('method must be an \'GET\', \'POST\', \'PUT\' or \'DELETE\'') unless( %w[GET POST PUT DELETE].include?(method) )

      unless( data.nil? )
        raise ArgumentError.new(format('data must be an Hash (%s)', data.class.to_s)) unless( data.is_a?(Hash) )
      end

      max_retries = 3
      retried     = 0

      begin

        case method.upcase
        when 'GET'
          response = client.get( headers )
        when 'POST'
          response = client.post( data.to_json, headers )
        when 'PATCH'
          response = client.patch( data, headers )
        when 'PUT'
          # response = @api_instance[endpoint].put( data, @headers )
          client.put( data.to_json, headers ) do |response, req, _result|

            @req           = req
            @response_raw  = response
            @response_body = response.body
            @response_code = response.code.to_i

            # logger.debug('----------------------------')
            # logger.debug(@response_raw)
            # logger.debug(@response_body)
            # logger.debug(@response_code)
            # logger.debug('----------------------------')

            case response.code
            when 200
              return @response_body
            when 400
              raise RestClient::BadRequest
            when 404
              raise RestClient::NotFound
            when 500
              raise RestClient::InternalServerError
            else
              response.return
            end
          end

        when 'DELETE'
          response = client.delete( @headers )
        else
          @logger.error( "Error: #{__method__} is not a valid request method." )
          return false
        end

        response_body    = response.body
        response_headers = response.headers
        response_body    = JSON.parse( response_body )

        return response_body

      rescue RestClient::BadRequest

        response_body = JSON.parse(response_body) if response_body.is_a?(String)

        return {
         'results' => [{
           'code' => 400,
           'status' => response_body.nil? ? 'Bad Request' : response_body
          }]
        }

      rescue RestClient::Unauthorized

        return {
            'code' => 401,
            'status' => format('Not authorized to connect \'%s\' - wrong username or password?', @icinga_api_url_base)
        }

      rescue RestClient::NotFound

        return {
          'results' => [{
            'code' => 404,
            'status' => 'Object not Found'
          }]
        }

      rescue RestClient::InternalServerError

        response_body = JSON.parse(@response_body) if @response_body.is_a?(String)

        results = response_body.dig('results')
        results = results.first if( results.is_a?(Array) )
        status  = results.dig('status')
        errors  = results.dig('errors')
        errors  = errors.first if( errors.is_a?(Array) )
        errors  = errors.sub(/ \'.*\'/,'')

        return {
          'results' => [{
            'code' => 500,
            'status' => format('%s (%s)', status, errors).delete('.')
          }]
        }

      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH => e

        # TODO
        # ist hier ein raise sinnvoll?
        raise format( "Maximum retries (%d) against '%s' reached. Giving up ...", max_retries, @icinga_api_url_base ) if( retried >= max_retries )

        retried += 1
        warn(format("Cannot execute request against '%s': '%s' (retry %d / %d)", @icinga_api_url_base, e, retried, max_retries))
        sleep(3)
        retry

      rescue RestClient::ExceptionWithResponse => e

        @logger.error( "Error: #{__method__} #{method_type.upcase} on #{endpoint} error: '#{e}'" )
        @logger.error( data )
        @logger.error( @headers )
        @logger.error( JSON.pretty_generate( response_headers ) )


        return {
          'results' => [{
            'code' => 500,
            'status' => e
          }]
        }
      end

    end


  end
end
