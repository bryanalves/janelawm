module XCB
  class Cookie::Pointer < FFI::Struct
    layout :sequence, :uint16
  end
end
