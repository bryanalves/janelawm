module XCB
  class Connection
    attr_reader :connection, :connection_io

    def initialize
      @connection = XCB::connect(nil, 0)
      @connection_io = IO.open(get_file_descriptor)
    end

    def children_of_screen(screen)
      tree = query_tree_reply(query_tree(screen), nil)
      child_count = XCB.query_tree_children_length(tree)
      children = XCB.query_tree_children(tree)

      children.read_array_of_type(:uint32, :read_uint32, child_count)
    end

    def window_geometry(win)
      get_geometry_reply(get_geometry(win), nil)
    end

    def pointer(screen)
      query_pointer_reply(query_pointer(screen), nil)
    end
  end
end
