module XCB
  class Reply::QueryPointer < FFI::Struct
    layout :response_type, :uint8,
           :same_screen, :uint8,
           :sequence, :uint16,
           :length, :uint32,
           :root, :window,
           :child, :window,
           :root_x, :int16,
           :root_y, :int16,
           :win_x, :int16,
           :win_y, :int16,
           :mask, :uint16,
           :pad, [:uint8, 2]
  end
end
