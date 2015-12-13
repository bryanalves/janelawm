module XCB
  class Connection
    def initialize
      @connection = XCB::connect(nil, 0)
    end
  end
end
