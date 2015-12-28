module XCB
  class Connection
    attr_reader :connection, :connection_io

    private

    def self.register_connection_function(name)
      define_method name do |*args|
        XCB.send(name, *([@connection] + args))
      end
    end

    public

    register_connection_function :disconnect
    register_connection_function :change_property
    register_connection_function :get_property
    register_connection_function :get_property_reply
    register_connection_function :map_window
    register_connection_function :set_input_focus
    register_connection_function :get_setup
    register_connection_function :wait_for_event
    register_connection_function :poll_for_event
    register_connection_function :get_file_descriptor
    register_connection_function :connection_has_error
    register_connection_function :flush
    register_connection_function :setup_roots_iterator
    register_connection_function :get_setup
    register_connection_function :change_window_attributes
    register_connection_function :grab_button
    register_connection_function :intern_atom
    register_connection_function :intern_atom_reply
    register_connection_function :grab_pointer
    register_connection_function :grab_pointer_reply
    register_connection_function :configure_window
    register_connection_function :query_pointer
    register_connection_function :query_pointer_reply
    register_connection_function :get_geometry
    register_connection_function :get_geometry_reply
    register_connection_function :query_tree
    register_connection_function :query_tree_reply
    register_connection_function :get_window_attributes
    register_connection_function :get_window_attributes_reply
    register_connection_function :ungrab_pointer
    register_connection_function :allow_events

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
