module XCB
  class ScreenIterator < FFI::Struct
    layout :data, XCB::Screen.by_ref,
           :rem, :int,
           :index, :int
  end
end
