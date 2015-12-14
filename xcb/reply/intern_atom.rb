module XCB
  class Reply::InternAtom < FFI::Struct
    layout :response_type, :uint8,
           :pad0, :uint8,
           :sequence, :uint16,
           :length, :uint32,
           :atom, :atom
  end
end
