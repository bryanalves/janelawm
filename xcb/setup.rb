module XCB
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
