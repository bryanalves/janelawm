module XCB
  extend FFI::Library

  ffi_lib 'xcb'

  def self.xcb_function(name, args, retval, **options)
    attach_function name, :"xcb_#{name}", args, retval, options
  end

  def self.xcb_connection_function(name, args, retval, **options)
    xcb_function name, [:xcb_connection] + args, retval, options

    XCB::Connection.send(:define_method, name) do |*conn_meth_args|
      XCB.send(name, *([@connection] + conn_meth_args))
    end
  end

  xcb_function :connect,
    [:string, :int],
    :xcb_connection

  xcb_connection_function :disconnect,
    [],
    :void

  xcb_connection_function :get_setup,
    [],
    :pointer

  xcb_connection_function :wait_for_event,
    [],
    XCB::Event::Generic.by_ref,
    { blocking: true }

  xcb_connection_function :poll_for_event,
    [],
    XCB::Event::Generic.by_ref

  xcb_connection_function :get_file_descriptor,
    [],
    :int

  xcb_connection_function :connection_has_error,
    [],
    :int

  xcb_connection_function :flush,
    [],
    :int

  xcb_connection_function :setup_roots_iterator,
    [],
    XCB::ScreenIterator.by_value

  xcb_connection_function :get_setup,
    [],
    XCB::Setup.by_ref

  xcb_function :screen_next,
    [XCB::ScreenIterator.by_ref],
    :void

  xcb_connection_function :change_window_attributes,
    [:uint32, :uint32, :pointer],
    :void

  xcb_connection_function :grab_button,
    [:uint8,  :uint32, :uint16, :uint8, :uint8, :uint32, :uint32, :uint8, :uint16],
    :void

  xcb_connection_function :grab_pointer,
    [:uint8, :uint32, :uint16, :uint8, :uint8, :uint32, :uint32, :uint32],
    XCB::Cookie::Pointer.by_value

  xcb_connection_function :grab_pointer_reply,
    [XCB::Cookie::Pointer.by_value, :pointer],
    XCB::Reply::GrabPointer.by_ref

  xcb_connection_function :configure_window,
    [:uint32, :uint16, :pointer],
    :void

  xcb_connection_function :query_pointer,
    [:uint32],
    XCB::Cookie::Pointer.by_value

  xcb_connection_function :query_pointer_reply,
    [XCB::Cookie::Pointer.by_value, :pointer],
    XCB::Reply::QueryPointer.by_ref

  xcb_connection_function :get_geometry,
    [:uint32],
    XCB::Cookie::Geometry.by_value

  xcb_connection_function :get_geometry_reply,
    [XCB::Cookie::Geometry.by_value, :pointer],
    XCB::Reply::Geometry.by_ref

  xcb_connection_function :query_tree,
    [:uint32],
    XCB::Cookie::QueryTree.by_value

  xcb_connection_function :query_tree_reply,
    [XCB::Cookie::QueryTree.by_value, :pointer],
    XCB::Reply::QueryTree.by_ref

  xcb_function :query_tree_children_length,
    [XCB::Reply::QueryTree.by_ref],
    :int

  xcb_function :query_tree_children,
    [XCB::Reply::QueryTree.by_ref],
    :pointer

  xcb_connection_function :get_window_attributes,
    [:uint32],
    XCB::Cookie::GetWindowAttributes.by_value

  xcb_connection_function :get_window_attributes_reply,
    [XCB::Cookie::GetWindowAttributes.by_value, :pointer],
    XCB::Reply::GetWindowAttributes.by_ref

  xcb_connection_function :ungrab_pointer,
    [:uint16],
    :void
end
