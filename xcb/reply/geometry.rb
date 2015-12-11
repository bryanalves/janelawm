module XCB
  class Reply::Geometry < FFI::Struct
    layout :response_type, :uint8,
           :depth, :uint8,
           :sequence, :uint16,
           :length, :uint32,
           :root, :window,
           :x, :int16,
           :y, :int16,
           :width, :uint16,
           :height, :uint16,
           :border_width, :uint16,
           :pad0, [:uint8, 2]
  end
end
