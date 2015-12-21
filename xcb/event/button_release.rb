module XCB
  class Event::ButtonRelease < FFI:Struct
      layout :response_type, :uint8,
             :detail, :button,
             :sequence, :uint16,
             :time, :timestamp,
             :root, :window,
             :event, :window,
             :child, :window,
             :root_x, :int16,
             :root_y, :int16,
             :event_x, :int16,
             :event_y, :int16,
             :state, :uint16,
             :same_screen, :uint8,
             :pad0, :uint8
  end
end
