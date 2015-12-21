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

    def default_screen
      setup = get_setup
      iter = XCB.setup_roots_iterator(setup)
      iter[:data]
    end

    def window_event_listeners(win, events)
      event_pointer = FFI::MemoryPointer.new(:int, 1)
      event_pointer.write_array_of_int([events])

      change_window_attributes(win, XCB::CW_EVENT_MASK, event_pointer)
    end

    def window_move(win, x, y)
      coords = FFI::MemoryPointer.new(:int, 2)
      coords.write_array_of_int([x, y])
      configure_window(win, XCB::CONFIG_WINDOW_X | XCB::CONFIG_WINDOW_Y, coords)
    end
  end
end
