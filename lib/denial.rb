module Sunnyside
  class Denial
    attr_reader :check

    def initialize(check)
      @check = check
    end
  end
end