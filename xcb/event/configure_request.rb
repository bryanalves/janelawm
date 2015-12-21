module XCB
  class Event::ConfigureRequest < FFI::Struct
    layout :response_type, :uint8,
           :stack_mode, :uint8,
           :sequence, :uint16,
           :parent, :window,
           :window, :window,
           :sibling, :window,
           :x, :int16,
           :y, :int16,
           :width, :uint16,
           :height, :uint16,
           :border_width, :uint16,
           :value_mask, :uint16
  end
end
