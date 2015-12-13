module XCB
  class Connection
    attr_reader :connection, :connection_io

    def initialize
      @connection = XCB::connect(nil, 0)
      @connection_io = IO.open(get_file_descriptor)
    end
  end
end
