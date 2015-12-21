module XCB
  class Event::EnterNotify < FFI::Struct
    layout :response_type, :uint8,
           :detail, :uint8,
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
           :mode, :uint8,
           :same_screen_focus, :uint8
  end
end
