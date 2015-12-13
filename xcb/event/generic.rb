module XCB
  class Event::Generic < FFI::Struct
    layout :response_type, :uchar,
           :pad0, :uchar,
           :sequence, :short,
           :pad, [:uint, 7],
           :full_sequence, :uint

    def event_type
      self[:response_type] & ~0x80
    end
  end
end
