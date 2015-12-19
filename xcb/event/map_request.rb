module XCB
  class Event::MapRequest < FFI::Struct
    layout :response_type, :uint8,
           :pad0, :uint8,
           :sequence, :uint16,
           :parent, :window,
           :window, :window
  end
end
