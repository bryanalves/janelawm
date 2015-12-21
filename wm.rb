class Wm
  attr_reader :conn
  attr_reader :screen
  attr_reader :ctrl_socket

  MOUSE_MASK = XCB::MOD_MASK_1
  EVENT_POLL_TIMEOUT = 0.25

  NET_ATOMS = {
    '_NET_SUPPORTED'           => nil,
    '_NET_WM_STATE_FULLSCREEN' => nil,
    '_NET_WM_STATE'            => nil,
    '_NET_SUPPORTING_WM_CHECK' => nil,
    '_NET_ACTIVE_WINDOW'       => nil,
    '_NET_NUMBER_OF_DESKTOPS'  => nil,
    '_NET_CURRENT_DESKTOP'     => nil,
    '_NET_DESKTOP_GEOMETRY'    => nil,
    '_NET_DESKTOP_VIEWPORT'    => nil,
    '_NET_WORKAREA'            => nil,
    '_NET_SHOWING_DESKTOP'     => nil,
    '_NET_CLOSE_WINDOW'        => nil,
    '_NET_WM_DESKTOP'          => nil,
    '_NET_WM_WINDOW_TYPE'      => nil
  }

  WM_ATOMS = {
    'WM_PROTOCOLS'     => nil,
    'WM_DELETE_WINDOW' => nil
  }

  def initialize(xcb_conn, ctrl_socket)
    @conn = xcb_conn
    @screen = conn.default_screen
    @ctrl_socket = ctrl_socket
    setup_atoms
    setup_root
    setup_children
  end

  def setup_atoms
    NET_ATOMS.each do |atom_name, val|
      NET_ATOMS[atom_name] = conn.intern_atom_reply(conn.intern_atom(0, atom_name.length, atom_name), nil)[:atom]
    end

    WM_ATOMS.each do |atom_name, val|
      WM_ATOMS[atom_name] = conn.intern_atom_reply(conn.intern_atom(0, atom_name.length, atom_name), nil)[:atom]
    end
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

  def run
    while true
      event = wait_for_event
      conn.flush

      case event.event_type
      when XCB::MAP_REQUEST
        win = event[:pad][1]
        debug 'map_request'
        map_request(win)

      when XCB::CONFIGURE_REQUEST
        debug 'configure_request'

      when XCB::PROPERTY_NOTIFY
        debug 'property_notify'

      when XCB::CONFIGURE_NOTIFY
        debug 'configure_notify'

      when XCB::ENTER_NOTIFY
        win = event[:pad][2]
        debug 'enter_notify'
        enter_notify(win)

      when XCB::BUTTON_PRESS
        win = event[:pad][2]
        debug 'button_press'
        if event[:pad0] == XCB::LEFT_MOUSE
          mousemove(win)
        elsif event[:pad0] == XCB::RIGHT_MOUSE
          mouseresize(win)
        end
      else
        $stderr.puts "mainloop: unknown event: #{event.event_type}"
      end
    end
  end

  def setup_children
    children = conn.children_of_screen(screen[:root])
    children.each do |child|
      setup_child(child)
    end

    conn.flush
  end

  def setup_child(child)
    setup_mouse(child)

    events = XCB::EVENT_MASK_PROPERTY_CHANGE | XCB::EVENT_MASK_ENTER_WINDOW
    conn.window_event_listeners(events)
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

  def enter_notify(win)
    win_pointer = FFI::MemoryPointer.new(:int, 1)
    win_pointer.write_array_of_int([win])
    conn.change_property(XCB::PROP_MODE_REPLACE,
                         screen[:root],
                         Wm::NET_ATOMS['_NET_ACTIVE_WINDOW'],
                         XCB::ATOM_WINDOW,
                         32,
                         1,
                         win_pointer)

    stack = FFI::MemoryPointer.new(:int, 1)
    stack.write_array_of_int([0])
    conn.configure_window(win, XCB::CONFIG_WINDOW_STACK_MODE, stack)
    conn.set_input_focus(XCB::INPUT_FOCUS_POINTER_ROOT, win, XCB::NONE)
    conn.flush
  end

  def map_request(win)
    conn.map_window(win)
    coords = FFI::MemoryPointer.new(:int, 2)
    coords.write_array_of_int([0, 0])
    conn.configure_window(win, XCB::CONFIG_WINDOW_X | XCB::CONFIG_WINDOW_Y, coords)
    setup_child(win)
    conn.flush
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
    mouseloop(win, XCB::CONFIG_WINDOW_X | XCB::CONFIG_WINDOW_Y, base_x, base_y)
  end

  def mouseresize(win)
    _, _, base_width, base_height = mousemotionsetup(win)
    mouseloop(win, XCB::CONFIG_WINDOW_WIDTH | XCB::CONFIG_WINDOW_HEIGHT, base_width, base_height)
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

  def mouseloop(win, configure_mask, base_x, base_y)
    $stderr.puts 'mouseloop'
    conn.flush
    while true
      event = conn.wait_for_event
      conn.flush
      next if event.event_type == 0

      case event.event_type
      when XCB::MOTION_NOTIFY
        mne = XCB::Event::MotionNotify.new event.to_ptr
        ev_root_x = mne[:root_x]
        ev_root_y = mne[:root_y]

        target_x = base_x + ev_root_x
        target_y = base_y + ev_root_y

        coords = FFI::MemoryPointer.new(:int, 2)
        coords.write_array_of_int([target_x, target_y])
        conn.configure_window(win, configure_mask, coords)

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

  def debug(msg)
    $stderr.puts "mainloop: #{msg}"
  end
end
