class Wm
  attr_reader :conn
  attr_reader :screen
  attr_reader :ctrl_socket

  MOUSE_MASK = XCB::MOD_MASK_1

  def initialize(xcb_conn, ctrl_socket)
    @conn = xcb_conn
    @screen = conn.default_screen
    @ctrl_socket = ctrl_socket
  end

  def setup_children
    children = conn.children_of_screen(screen[:root])
    children.each do |child|
      setup_mouse(child)
    end

    conn.flush
  end

  def wait_for_event
    fds = [conn.connection_io, ctrl_socket.socket].compact
    event = nil
    until event
      events, _, _ = IO.select(fds, nil, nil, 0.25)
      if events
        event = conn.poll_for_event if events.include?(conn.connection_io)
        ctrl_socket.handle if events.include?(ctrl_socket.socket)
      end
    end

    event
  end

  def setup_mouse(win)
    conn.grab_button(1,
                     win,
                     XCB::EVENT_MASK_BUTTON_PRESS,
                     XCB::GRAB_MODE_ASYNC,
                     XCB::GRAB_MODE_ASYNC,
                     XCB::WINDOW_NONE,
                     XCB::NONE,
                     1,
                     MOUSE_MASK)

    conn.grab_button(1,
                     win,
                     XCB::EVENT_MASK_BUTTON_PRESS,
                     XCB::GRAB_MODE_ASYNC,
                     XCB::GRAB_MODE_ASYNC,
                     XCB::WINDOW_NONE,
                     XCB::NONE,
                     3,
                     MOUSE_MASK)
  end

  def mousemotion(win)
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

    ungrab = false
    while !ungrab do
      conn.flush
      res = wait_for_event
      event = res.event_type
      conn.flush

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
        conn.configure_window(event_win, XCB::CONFIG_WINDOW_X | XCB::CONFIG_WINDOW_Y, coords)
        conn.flush

      when XCB::BUTTON_RELEASE
        ungrab = true

      else
        $stderr.puts "Unknown event: #{event}"
      end
    end

    conn.ungrab_pointer(XCB::CURRENT_TIME)
    conn.flush
  end

  def mouseresize(win)
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

    base_x = geom[:width] - pointer[:root_x]
    base_y = geom[:height] - pointer[:root_y]

    ungrab = false
    while !ungrab do
      conn.flush
      res = wait_for_event
      event = res.event_type
      conn.flush

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
        conn.configure_window(event_win, XCB::CONFIG_WINDOW_WIDTH | XCB::CONFIG_WINDOW_HEIGHT, coords)
        conn.flush

      when XCB::BUTTON_RELEASE
        ungrab = true

      else
        $stderr.puts "Unknown event: #{event}"
      end
    end

    conn.ungrab_pointer(XCB::CURRENT_TIME)
    conn.flush
  end
end
