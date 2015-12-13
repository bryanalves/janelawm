require_relative './xcb'
require 'pry'

conn = XCB::Connection.new

setup = conn.get_setup
iter = XCB.setup_roots_iterator(setup)

screen = iter[:data]

def setup_mouse(conn, win)
  conn.grab_button(1,
                win,
                XCB::EVENT_MASK_BUTTON_PRESS,
                XCB::GRAB_MODE_ASYNC,
                XCB::GRAB_MODE_ASYNC,
                XCB::WINDOW_NONE,
                XCB::NONE,
                1,
                XCB::MOD_MASK_1)
end

children = conn.children_of_screen(screen[:root])

children.each do |child|
  #attr = conn.get_window_attributes_reply(conn.get_window_attributes(child), nil)
  setup_mouse(conn, child)
end

conn.flush

def mousemotion(conn, screen, win)
  geom = conn.window_geometry(win)
  pointer = conn.pointer(screen[:root])

  conn.grab_pointer_reply(conn.grab_pointer(0,
                        screen[:root],
                        XCB::EVENT_MASK_BUTTON_PRESS | XCB::EVENT_MASK_BUTTON_RELEASE | XCB::EVENT_MASK_BUTTON_MOTION | XCB::EVENT_MASK_POINTER_MOTION,
                        XCB::GRAB_MODE_ASYNC,
                        XCB::GRAB_MODE_ASYNC,
                        win,
                        XCB::NONE,
                        XCB::CURRENT_TIME),
  nil)

  ungrab = false
  while !ungrab do
    conn.flush
    #res = conn.wait_for_event
    res = wait_for_event(conn)
    event = res[:response_type] & ~0x80
    conn.flush

    case event
    when XCB::MOTION_NOTIFY
      mne = XCB::Event::MotionNotify.new res.to_ptr
      event_win = mne[:child]
      ev_root_x = mne[:root_x]
      ev_root_y = mne[:root_y]

      target_x = geom[:x] + ev_root_x - pointer[:root_x]
      target_y = geom[:y] + ev_root_y - pointer[:root_y]

      coords = FFI::MemoryPointer.new(:int, 2)
      coords.write_array_of_int([target_x, target_y])
      conn.configure_window(event_win, XCB::CONFIG_WINDOW_X | XCB::CONFIG_WINDOW_Y, coords)
      conn.flush

    when XCB::BUTTON_RELEASE
      ungrab = true

    else
      puts event
    end
  end

  conn.ungrab_pointer(XCB::CURRENT_TIME)
  conn.flush

  exit(0)
end

trap 'TERM' do |sig|
  puts "caught #{sig}"
  exit(0)
end

trap 'INT' do |sig|
  puts "caught #{sig}"
  exit(0)
end

def wait_for_event(conn, conn_sock = nil)
  fds = [conn.connection_io, conn_sock].compact
  event = nil
  until event
    events, _, _ = IO.select(fds, nil, nil, 0.25)
    if events
      event = conn.poll_for_event if events.include?(conn.connection_io)
      sock_handler(conn_sock) if events.include?(conn_sock)
    end
  end
  puts event
  event
end

def sock_handler(conn_sock)
  fd, _ = conn_sock.sysaccept
  client_socket = Socket.for_fd(fd)
  var = client_socket.readline
  client_socket.close
  puts var
end

FileUtils.rm_f('/tmp/rubywm_sock')
conn_sock = Socket.new(:UNIX, :STREAM)
sock_addr = Socket.sockaddr_un("/tmp/rubywm_sock")
conn_sock.bind(sock_addr)
conn_sock.listen(5)

while true do
  res = wait_for_event(conn, conn_sock)
  puts res
  win = res[:pad][2]
  event = res[:response_type] & ~0x80

  conn.flush
  case event
  when XCB::BUTTON_PRESS
    mousemotion(conn, screen, win)
    conn.flush
  else
    puts 'UNKNOWN'
    puts event
  end
end
