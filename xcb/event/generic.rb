module XCB
  class Event::Generic < FFI::Struct
    layout :response_type, :uchar,
           :pad0, :uchar,
           :sequence, :short,
           :pad, [:uint, 7],
           :full_sequence, :uint
  end
end
