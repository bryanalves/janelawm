module XCB
  class Event::ConfigureNotify < FFI::Struct
    layout :response_type, :uint8,
           :pad0, :uint8,
           :sequence, :uint16,
           :event, :window,
           :window, :window,
           :above_sibling, :window,
           :x, :int16,
           :y, :int16,
           :width, :uint16,
           :height, :uint16,
           :border_width, :uint16,
           :override_redirect, :uint8,
           :pad1, :uint8
  end
end
