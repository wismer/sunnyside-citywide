module Sunnyside
  DB = Sequel.connect('sqlite://sunnyside-test.db')
  class Auth < Sequel::Model; end
  class Charge < Sequel::Model; end
  class Invoice < Sequel::Model; end
  class Filelib < Sequel::Model; end
  class Payment < Sequel::Model; end
  class Claim < Sequel::Model; end
  class Client < Sequel::Model; end
  class Service < Sequel::Model; end
  class Provider < Sequel::Model; end
  class Visit < Sequel::Model; end
end