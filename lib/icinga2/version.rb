
module Icinga2

  module Version

    MAJOR = 1
    MINOR = 4
    TINY  = 8

  end

  VERSION = [Version::MAJOR, Version::MINOR, Version::TINY].compact * '.'

end

