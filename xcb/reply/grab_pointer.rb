module XCB
  class Reply::GrabPointer < FFI::Struct
    layout :response_type, :uint8,
           :status, :uint8,
           :sequence, :uint16,
           :length, :uint32
  end
end
