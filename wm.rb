class Wm
  attr_reader :conn
  attr_reader :screen
  attr_reader :ctrl_socket

  MOUSE_MASK = XCB::MOD_MASK_1
  EVENT_POLL_TIMEOUT = 0.25

  def initialize(xcb_conn, ctrl_socket)
    @conn = xcb_conn
    @screen = conn.default_screen
    @ctrl_socket = ctrl_socket
  end

  def setup_root
    events = XCB::EVENT_MASK_SUBSTRUCTURE_REDIRECT |
             XCB::EVENT_MASK_SUBSTRUCTURE_NOTIFY |
             XCB::EVENT_MASK_PROPERTY_CHANGE |
             XCB::EVENT_MASK_BUTTON_PRESS

    event_pointer = FFI::MemoryPointer.new(:int, 1)
    event_pointer.write_array_of_int([events])
    conn.change_window_attributes(screen[:root], XCB::CW_EVENT_MASK, event_pointer)
  end

  def setup_children
    children = conn.children_of_screen(screen[:root])
    children.each do |child|
      setup_mouse(child)

      #events = XCB::EVENT_MASK_PROPERTY_CHANGE |
               #XCB::EVENT_MASK_ENTER_WINDOW

      events = XCB::EVENT_MASK_PROPERTY_CHANGE
      event_pointer = FFI::MemoryPointer.new(:int, 1)
      event_pointer.write_array_of_int([events])

      conn.change_window_attributes(child, XCB::CW_EVENT_MASK, event_pointer)
    end

    conn.flush
  end

  def wait_for_event
    fds = [conn.connection_io, ctrl_socket.socket].compact
    event = nil
    until event
      events, _, _ = IO.select(fds, nil, nil, EVENT_POLL_TIMEOUT)
      if events
        event = conn.poll_for_event if events.include?(conn.connection_io)
        handle_socket_command(ctrl_socket.command) if events.include?(ctrl_socket.socket)
      end
    end

    if event.event_type == 0
      wait_for_event
    else
      event
    end
  end

  def setup_mouse(win)
    [XCB::LEFT_MOUSE, XCB::RIGHT_MOUSE].each do |button|
      conn.grab_button(1,
                       win,
                       XCB::EVENT_MASK_BUTTON_PRESS,
                       XCB::GRAB_MODE_ASYNC,
                       XCB::GRAB_MODE_ASYNC,
                       XCB::WINDOW_NONE,
                       XCB::NONE,
                       button,
                       MOUSE_MASK)
    end
  end

  def mousemove(win)
    base_x, base_y, _, _ = mousemotionsetup(win)
    mouseloop(XCB::CONFIG_WINDOW_X | XCB::CONFIG_WINDOW_Y, base_x, base_y)
  end

  def mouseresize(win)
    _, _, base_width, base_height = mousemotionsetup(win)
    mouseloop(XCB::CONFIG_WINDOW_WIDTH | XCB::CONFIG_WINDOW_HEIGHT, base_width, base_height)
  end

  private

  def mousemotionsetup(win)
    geom = conn.window_geometry(win)
    pointer = conn.pointer(screen[:root])

    conn.grab_pointer_reply(
      conn.grab_pointer(0,
                        screen[:root],
                        XCB::EVENT_MASK_BUTTON_PRESS |
                          XCB::EVENT_MASK_BUTTON_RELEASE |
                          XCB::EVENT_MASK_BUTTON_MOTION |
                          XCB::EVENT_MASK_POINTER_MOTION,
                        XCB::GRAB_MODE_ASYNC,
                        XCB::GRAB_MODE_ASYNC,
                        win,
                        XCB::NONE,
                        XCB::CURRENT_TIME),
      nil)

    base_x = geom[:x] - pointer[:root_x]
    base_y = geom[:y] - pointer[:root_y]
    base_width = geom[:width] - pointer[:root_x]
    base_height = geom[:height] - pointer[:root_y]
    [base_x, base_y, base_width, base_height]
  end

  def mouseloop(configure_mask, base_x, base_y)
    conn.flush
    while true do
      res = conn.wait_for_event
      event = res.event_type

      case event
      when XCB::MOTION_NOTIFY
        mne = XCB::Event::MotionNotify.new res.to_ptr
        event_win = mne[:child]
        ev_root_x = mne[:root_x]
        ev_root_y = mne[:root_y]

        target_x = base_x + ev_root_x
        target_y = base_y + ev_root_y

        coords = FFI::MemoryPointer.new(:int, 2)
        coords.write_array_of_int([target_x, target_y])
        conn.configure_window(event_win, configure_mask, coords)
        conn.flush

      when XCB::CONFIGURE_REQUEST
        break
      when XCB::MAP_REQUEST
        break
      when XCB::BUTTON_PRESS
        # break
      when XCB::BUTTON_RELEASE
        break
      when XCB::KEY_PRESS
        # break
      when XCB::KEY_RELEASE
        break
      when XCB::CONFIGURE_NOTIFY
        # ignore these
      when XCB::ENTER_NOTIFY
        # ignore these
      when XCB::PROPERTY_NOTIFY
        # ignore these
      else
        $stderr.puts "mouseloop: unknown event: #{event}"
      end
    end

    conn.ungrab_pointer(XCB::CURRENT_TIME)
    conn.flush
  end

  def handle_socket_command(command)
    case command
    when 'restart'
      exec $PROGRAM_NAME
    when  'flush'
      conn.flush
    else
      $stderr.puts "sock_hander: #{command}"
    end
  end
end
