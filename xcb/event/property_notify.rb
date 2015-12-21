module XCB
  class Event::PropertyNotify < FFI::Struct
    layout :response_type, :uint8,
           :pad0, :uint8,
           :sequence, :uint16,
           :window, :window,
           :atom, :atom,
           :time, :timestamp,
           :state, :uint8,
           :pad1, [:uint8, 3]
  end
end
