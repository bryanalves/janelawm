require 'ffi'

require_relative 'xcb/cookie'
require_relative 'xcb/event'

module XCB
  class GrabPointerReply < FFI::Struct
    layout :response_type, :uint8,
      :status,:uint8,
      :sequence, :uint16,
      :length, :uint32
  end

  class QueryTreeReply < FFI::Struct
    layout :response_type, :uint8,
      :pad0, :uint8,
      :sequence, :uint16,
      :length, :uint32,
      :root, :uint32,
      :parent, :uint32,
      :children_len, :uint16,
      :pad1, [:uint8, 14]

  end

  class GeometryReply < FFI::Struct
    layout :response_type, :uint8,
      :depth, :uint8,
      :sequence, :uint16,
      :length, :uint32,
      :root, :uint32,
      :x, :int16,
      :y, :int16,
      :width, :uint16,
      :height, :uint16,
      :border_width, :uint16,
      :pad0, [:uint8, 2]
  end

  class QueryPointerReply < FFI::Struct
    layout :response_type, :uint8,
      :same_screen, :uint8,
      :sequence, :uint16,
      :length, :uint32,
      :root, :uint32,
      :child, :uint32,
      :root_x, :int16,
      :root_y, :int16,
      :win_x, :int16,
      :win_y, :int16,
      :mask, :uint16,
      :pad, [:uint8, 2]
  end

  class GetWindowAttributesReply < FFI::Struct
    layout :response_type, :uint8,
      :backing_store, :uint8,
      :sequence, :uint16,
      :length, :uint32,
      :visual, :uint32,
      :_class, :uint16,
      :bit_gravity, :uint8,
      :win_gravity, :uint8,
      :backing_planes, :uint32,
      :backing_pixel, :uint32,
      :save_under, :uint8,
      :map_is_installed, :uint8,
      :map_state, :uint8,
      :override_redirect, :uint8,
      :colormap, :uint32,
      :all_event_masks, :uint32,
      :your_event_mask, :uint32,
      :do_not_propogate_mask, :uint16,
      :pad0, [:uint8, 2]
  end

  class Screen < FFI::Struct
    layout :root, :uint32,
      :default_colormap, :uint32,
      :white_pixel, :uint32,
      :black_pixel, :uint32,
      :current_input_masks, :uint32,
      :width_in_pixels, :uint16,
      :height_in_pixels, :uint16,
      :width_in_millimeters, :uint16,
      :height_in_millimeters, :uint16,
      :min_installed_maps, :uint16,
      :max_installed_maps, :uint16,
      :root_visual, :uint32,
      :backing_stores, :uint8,
      :save_unders, :uint8,
      :root_depth, :uint8,
      :allowed_depths_len, :uint8
  end

  class ScreenIterator < FFI::Struct
    layout :data, XCB::Screen.by_ref,
      :rem, :int,
      :index, :int
  end

  class Setup < FFI::Struct
    layout :status, :uint8,
      :pad0, :uint8,
      :protocol_major_version, :uint16,
      :protocol_minor_version, :uint16,
      :length, :uint16,
      :release_number, :uint32,
      :resource_id_base, :uint32,
      :resource_id_mask, :uint32,

      :motion_buffer_size, :uint32,
      :vendor_len, :uint16,
      :maximum_request_length, :uint16,
      :roots_len, :uint8,
      :pixmap_formats_len, :uint8,
      :image_byte_order, :uint8,
      :bitmap_format_bit_order, :uint8,
      :bitmap_format_scanline_unit, :uint8,
      :bitmap_format_scanline_pad, :uint8,
      :min_keycode, :uint8,
      :max_keycode, :uint8,
      :pad1, [:uint8, 4]
  end
end

module XCB
  extend FFI::Library

  ffi_lib 'xcb'

  def self.xcb_function(name, args, retval, **options)
    attach_function name, :"xcb_#{name}", args, retval, options
  end

  xcb_function :connect, [:string, :int], :pointer
  xcb_function :disconnect, [:pointer], :void
  xcb_function :get_setup, [:pointer], :pointer
  xcb_function :wait_for_event, [:pointer], XCB::Event::Generic.by_ref, {blocking: true}
  xcb_function :poll_for_event, [:pointer], XCB::Event::Generic.by_ref

  xcb_function :get_file_descriptor, [:pointer], :int
  xcb_function :connection_has_error, [:pointer], :int
  xcb_function :flush, [:pointer], :int
  xcb_function :setup_roots_iterator, [:pointer], XCB::ScreenIterator.by_value
  xcb_function :get_setup, [:pointer], XCB::Setup.by_ref
  xcb_function :screen_next, [XCB::ScreenIterator.by_ref], :void

  xcb_function :change_window_attributes, [:pointer, :uint32, :uint32, :pointer], :void

  #xcb_window_t = :uint32
  #xcb_cursor_t = :uint32
  #xcb_timestamp_t = :uint32
  #xcb_drawable_t = :uint32
  xcb_function :grab_button, [:pointer, :uint8,  :uint32, :uint16, :uint8, :uint8, :uint32, :uint32, :uint8, :uint16], :void

  xcb_function :grab_pointer, [:pointer, :uint8, :uint32, :uint16, :uint8, :uint8, :uint32, :uint32, :uint32], XCB::Cookie::Pointer.by_value
  xcb_function :grab_pointer_reply, [:pointer, XCB::Cookie::Pointer.by_value, :pointer], XCB::GrabPointerReply.by_ref

  xcb_function :configure_window, [:pointer, :uint32, :uint16, :pointer], :void


  xcb_function :query_pointer, [:pointer, :uint32], XCB::Cookie::Pointer.by_value
  xcb_function :query_pointer_reply, [:pointer, XCB::Cookie::Pointer.by_value, :pointer], XCB::QueryPointerReply.by_ref

  xcb_function :get_geometry, [:pointer, :uint32], XCB::Cookie::Geometry.by_value
  xcb_function :get_geometry_reply, [:pointer, XCB::Cookie::Geometry.by_value, :pointer], XCB::GeometryReply.by_ref

  xcb_function :query_tree, [:pointer, :uint32], XCB::Cookie::QueryTree.by_value
  xcb_function :query_tree_reply, [:pointer, XCB::Cookie::QueryTree.by_value, :pointer], XCB::QueryTreeReply.by_ref

  xcb_function :query_tree_children_length, [XCB::QueryTreeReply.by_ref], :int
  xcb_function :query_tree_children, [XCB::QueryTreeReply.by_ref], :pointer

  xcb_function :get_window_attributes, [:pointer, :uint32], XCB::Cookie::GetWindowAttributes.by_value
  xcb_function :get_window_attributes_reply, [:pointer, XCB::Cookie::GetWindowAttributes.by_value, :pointer], XCB::GetWindowAttributesReply.by_ref

  xcb_function :ungrab_pointer, [:pointer, :uint16], :void

  CW_EVENT_MASK = 2048
  EVENT_MASK_NO_EVENT = 0
  EVENT_MASK_KEY_PRESS = 1
  EVENT_MASK_KEY_RELEASE = 2
  EVENT_MASK_BUTTON_PRESS = 4
  EVENT_MASK_BUTTON_RELEASE = 8
  EVENT_MASK_ENTER_WINDOW = 16
  EVENT_MASK_LEAVE_WINDOW = 32
  EVENT_MASK_POINTER_MOTION = 64
  EVENT_MASK_POINTER_MOTION_HINT = 128
  EVENT_MASK_BUTTON_1_MOTION = 256
  EVENT_MASK_BUTTON_2_MOTION = 512
  EVENT_MASK_BUTTON_3_MOTION = 1024
  EVENT_MASK_BUTTON_4_MOTION = 2048
  EVENT_MASK_BUTTON_5_MOTION = 4096
  EVENT_MASK_BUTTON_MOTION = 8192
  EVENT_MASK_KEYMAP_STATE = 16384
  EVENT_MASK_EXPOSURE = 32768
  EVENT_MASK_VISIBILITY_CHANGE = 65536
  EVENT_MASK_STRUCTURE_NOTIFY = 131072
  EVENT_MASK_RESIZE_REDIRECT = 262144
  EVENT_MASK_SUBSTRUCTURE_NOTIFY = 524288
  EVENT_MASK_SUBSTRUCTURE_REDIRECT = 1048576
  EVENT_MASK_FOCUS_CHANGE = 2097152
  EVENT_MASK_PROPERTY_CHANGE = 4194304
  EVENT_MASK_COLOR_MAP_CHANGE = 8388608
  EVENT_MASK_OWNER_GRAB_BUTTON = 16777216

  GRAB_MODE_SYNC = 0
  GRAB_MODE_ASYNC = 1
  NONE = 0

  MOD_MASK_SHIFT = 1
  MOD_MASK_LOCK = 2
  MOD_MASK_CONTROL = 4
  MOD_MASK_1 = 8
  MOD_MASK_2 = 16
  MOD_MASK_3 = 32
  MOD_MASK_4 = 64
  MOD_MASK_5 = 128

  BUTTON_PRESS = 4
  MOTION_NOTIFY = 6
  BUTTON_RELEASE = 5

  CURRENT_TIME = 0

  CONFIG_WINDOW_X = 1
  CONFIG_WINDOW_Y = 2

  WINDOW_NONE = 0
end
