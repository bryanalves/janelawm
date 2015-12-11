module XCB
  class Event::MotionNotify < FFI::Struct
    layout :response_type, :uint8,
           :detail, :uint8,
           :sequence, :uint16,
           :time, :uint32,
           :root, :uint32,
           :event, :uint32,
           :child, :uint32,
           :root_x, :int16,
           :root_y, :int16,
           :event_x, :int16,
           :event_y, :int16,
           :state, :uint16,
           :same_screen, :uint8,
           :pad0, :uint8
  end
end
