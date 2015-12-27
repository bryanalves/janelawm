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

    def to_event
      case event_type
      when XCB::MAP_REQUEST
        XCB::Event::MapRequest.new to_ptr

      when XCB::CONFIGURE_REQUEST
        XCB::Event::ConfigureRequest.new to_ptr

      when XCB::PROPERTY_NOTIFY
         XCB::Event::PropertyNotify.new to_ptr

      when XCB::CONFIGURE_NOTIFY
         XCB::Event::ConfigureNotify.new to_ptr

      when XCB::ENTER_NOTIFY
         XCB::Event::EnterNotify.new to_ptr

      when XCB::BUTTON_PRESS
         XCB::Event::ButtonPress.new to_ptr
      else
        $stderr.puts "mainloop: unknown event: #{event_type}"
        self
      end
    end
  end
end
