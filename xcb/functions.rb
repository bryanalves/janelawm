module XCB
  extend FFI::Library

  ffi_lib 'xcb'

  def self.xcb_function(name, args, retval, **options)
    attach_function name, :"xcb_#{name}", args, retval, options
  end

  xcb_function :connect, [:string, :int], :pointer
  xcb_function :disconnect, [:pointer], :void
  xcb_function :get_setup, [:pointer], :pointer
  xcb_function :wait_for_event, [:pointer], XCB::Event::Generic.by_ref, { blocking: true }
  xcb_function :poll_for_event, [:pointer], XCB::Event::Generic.by_ref

  xcb_function :get_file_descriptor, [:pointer], :int
  xcb_function :connection_has_error, [:pointer], :int
  xcb_function :flush, [:pointer], :int
  xcb_function :setup_roots_iterator, [:pointer], XCB::ScreenIterator.by_value
  xcb_function :get_setup, [:pointer], XCB::Setup.by_ref
  xcb_function :screen_next, [XCB::ScreenIterator.by_ref], :void

  xcb_function :change_window_attributes, [:pointer, :uint32, :uint32, :pointer], :void

  xcb_function :grab_button, [:pointer, :uint8,  :uint32, :uint16, :uint8, :uint8, :uint32, :uint32, :uint8, :uint16], :void

  xcb_function :grab_pointer, [:pointer, :uint8, :uint32, :uint16, :uint8, :uint8, :uint32, :uint32, :uint32], XCB::Cookie::Pointer.by_value
  xcb_function :grab_pointer_reply, [:pointer, XCB::Cookie::Pointer.by_value, :pointer], XCB::Reply::GrabPointer.by_ref

  xcb_function :configure_window, [:pointer, :uint32, :uint16, :pointer], :void

  xcb_function :query_pointer, [:pointer, :uint32], XCB::Cookie::Pointer.by_value
  xcb_function :query_pointer_reply, [:pointer, XCB::Cookie::Pointer.by_value, :pointer], XCB::Reply::QueryPointer.by_ref

  xcb_function :get_geometry, [:pointer, :uint32], XCB::Cookie::Geometry.by_value
  xcb_function :get_geometry_reply, [:pointer, XCB::Cookie::Geometry.by_value, :pointer], XCB::Reply::Geometry.by_ref

  xcb_function :query_tree, [:pointer, :uint32], XCB::Cookie::QueryTree.by_value
  xcb_function :query_tree_reply, [:pointer, XCB::Cookie::QueryTree.by_value, :pointer], XCB::Reply::QueryTree.by_ref

  xcb_function :query_tree_children_length, [XCB::Reply::QueryTree.by_ref], :int
  xcb_function :query_tree_children, [XCB::Reply::QueryTree.by_ref], :pointer

  xcb_function :get_window_attributes, [:pointer, :uint32], XCB::Cookie::GetWindowAttributes.by_value
  xcb_function :get_window_attributes_reply, [:pointer, XCB::Cookie::GetWindowAttributes.by_value, :pointer], XCB::Reply::GetWindowAttributes.by_ref

  xcb_function :ungrab_pointer, [:pointer, :uint16], :void
end
