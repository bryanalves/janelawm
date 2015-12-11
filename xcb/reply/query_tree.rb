module XCB
  class Reply::QueryTree < FFI::Struct
    layout :response_type, :uint8,
           :pad0, :uint8,
           :sequence, :uint16,
           :length, :uint32,
           :root, :uint32,
           :parent, :uint32,
           :children_len, :uint16,
           :pad1, [:uint8, 14]
  end
end
