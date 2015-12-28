module XCB
  extend FFI::Library

  ffi_lib 'xcb'

  def self.xcb_function(name, args, retval, **options)
    attach_function name, :"xcb_#{name}", args, retval, options
  end

  xcb_function :connect,
    [:string, :int],
    :xcb_connection

  xcb_function :disconnect,
    [:xcb_connection],
    :void

  xcb_function :allow_events,
    [:xcb_connection, :uint8, :timestamp],
    :void

  xcb_function :change_property,
    [:xcb_connection, :uint8, :window, :atom, :atom, :uint8, :uint32, :pointer],
    :void

  xcb_function :get_property,
    [:xcb_connection, :uint8, :window, :atom, :atom, :uint32, :uint32],
    XCB::Cookie::GetProperty.by_value

  xcb_function :get_property_reply,
    [:xcb_connection, XCB::Cookie::GetProperty.by_value, :pointer],
    XCB::Reply::GetProperty.by_ref

  xcb_function :get_property_value,
    [XCB::Reply::GetProperty.by_ref],
    :pointer

  xcb_function :get_property_value_length,
    [XCB::Reply::GetProperty.by_ref],
    :uint

  xcb_function :map_window,
    [:xcb_connection, :window],
    :void

  xcb_function :set_input_focus,
    [:xcb_connection, :uint8, :window, :timestamp],
    :void

  xcb_function :get_setup,
    [:xcb_connection],
    :pointer

  xcb_function :wait_for_event,
    [:xcb_connection],
    XCB::Event::Generic.by_ref,
    { blocking: true }

  xcb_function :poll_for_event,
    [:xcb_connection],
    XCB::Event::Generic.by_ref

  xcb_function :get_file_descriptor,
    [:xcb_connection],
    :int

  xcb_function :connection_has_error,
    [:xcb_connection],
    :int

  xcb_function :flush,
    [:xcb_connection],
    :int

  xcb_function :setup_roots_iterator,
    [:xcb_connection],
    XCB::ScreenIterator.by_value

  xcb_function :get_setup,
    [:xcb_connection],
    XCB::Setup.by_ref

  xcb_function :screen_next,
    [XCB::ScreenIterator.by_ref],
    :void

  xcb_function :change_window_attributes,
    [:xcb_connection, :uint32, :uint32, :pointer],
    :void

  xcb_function :grab_button,
    [:xcb_connection, :uint8,  :uint32, :uint16, :uint8, :uint8, :uint32, :uint32, :uint8, :uint16],
    :void

  xcb_function :intern_atom,
    [:xcb_connection, :uint8, :uint16, :string],
    XCB::Cookie::InternAtom.by_value

  xcb_function :intern_atom_reply,
    [:xcb_connection, XCB::Cookie::InternAtom.by_value, :pointer],
    XCB::Reply::InternAtom.by_ref

  xcb_function :grab_pointer,
    [:xcb_connection, :uint8, :uint32, :uint16, :uint8, :uint8, :uint32, :uint32, :uint32],
    XCB::Cookie::Pointer.by_value

  xcb_function :grab_pointer_reply,
    [:xcb_connection, XCB::Cookie::Pointer.by_value, :pointer],
    XCB::Reply::GrabPointer.by_ref

  xcb_function :configure_window,
    [:xcb_connection, :uint32, :uint16, :pointer],
    :void

  xcb_function :query_pointer,
    [:xcb_connection, :uint32],
    XCB::Cookie::Pointer.by_value

  xcb_function :query_pointer_reply,
    [:xcb_connection, XCB::Cookie::Pointer.by_value, :pointer],
    XCB::Reply::QueryPointer.by_ref

  xcb_function :get_geometry,
    [:xcb_connection, :uint32],
    XCB::Cookie::Geometry.by_value

  xcb_function :get_geometry_reply,
    [:xcb_connection, XCB::Cookie::Geometry.by_value, :pointer],
    XCB::Reply::Geometry.by_ref

  xcb_function :query_tree,
    [:xcb_connection, :uint32],
    XCB::Cookie::QueryTree.by_value

  xcb_function :query_tree_reply,
    [:xcb_connection, XCB::Cookie::QueryTree.by_value, :pointer],
    XCB::Reply::QueryTree.by_ref

  xcb_function :query_tree_children_length,
    [XCB::Reply::QueryTree.by_ref],
    :int

  xcb_function :query_tree_children,
    [XCB::Reply::QueryTree.by_ref],
    :pointer

  xcb_function :get_window_attributes,
    [:xcb_connection, :uint32],
    XCB::Cookie::GetWindowAttributes.by_value

  xcb_function :get_window_attributes_reply,
    [:xcb_connection, XCB::Cookie::GetWindowAttributes.by_value, :pointer],
    XCB::Reply::GetWindowAttributes.by_ref

  xcb_function :ungrab_pointer,
    [:xcb_connection, :uint16],
    :void
end
