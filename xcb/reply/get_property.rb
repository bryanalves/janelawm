module XCB
  class Reply::GetProperty < FFI::Struct
    layout :response_type, :uint8,
           :format, :uint8,
           :sequence, :uint16,
           :length, :uint32,
           :type, :atom,
           :bytes_after, :uint32,
           :value_len, :uint32,
           :pad0, [:uint8, 12]
  end
end
