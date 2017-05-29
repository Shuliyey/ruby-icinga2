#!/usr/bin/ruby
#
# 23.01.2017 - Bodo Schulz
#
#
# v0.9.0

# -----------------------------------------------------------------------------

require_relative '../lib/icinga'

# -----------------------------------------------------------------------------

icingaHost         = ENV.fetch( 'ICINGA_HOST'             , 'icinga2' )
icingaApiPort      = ENV.fetch( 'ICINGA_API_PORT'         , 5665 )
icingaApiUser      = ENV.fetch( 'ICINGA_API_USER'         , 'admin' )
icingaApiPass      = ENV.fetch( 'ICINGA_API_PASSWORD'     , nil )
icingaCluster      = ENV.fetch( 'ICINGA_CLUSTER'          , false )
icingaSatellite    = ENV.fetch( 'ICINGA_CLUSTER_SATELLITE', nil )


# convert string to bool
icingaCluster   = icingaCluster.to_s.eql?('true') ? true : false

config = {
  :icinga => {
    :host      => icingaHost,
    :api       => {
      :port => icingaApiPort,
      :user => icingaApiUser,
      :pass => icingaApiPass
    },
    :cluster   => icingaCluster,
    :satellite => icingaSatellite,
  }
}

# ---------------------------------------------------------------------------------------
# NEVER FORK THE PROCESS!
# the used supervisord will control all
stop = false

Signal.trap('INT')  { stop = true }
Signal.trap('HUP')  { stop = true }
Signal.trap('TERM') { stop = true }
Signal.trap('QUIT') { stop = true }

# ---------------------------------------------------------------------------------------

i = Icinga::Client.new( config )

if( i != nil )
  i.run()
end


# for periotic work ..

# scheduler = Rufus::Scheduler.new
#
# scheduler.every( interval, :first_in => 5 ) do
#
#   i.queue()
#
# end
#
#
# scheduler.every( 5 ) do
#
#   if( stop == true )
#
#     p 'shutdown scheduler ...'
#
#     scheduler.shutdown(:kill)
#   end
#
# end
#
#
# scheduler.join

# -----------------------------------------------------------------------------

# EOF
