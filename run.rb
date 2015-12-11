require_relative './xcb'
require 'pry'

class Simple
  include XCB
end

wm = Simple.new
connection = wm.connect(nil, 0)
connection_fd = IO.open(wm.get_file_descriptor(connection))

setup = wm.get_setup(connection)
iter = wm.setup_roots_iterator(setup)

screen = iter[:data]

def setup_mouse(wm, connection, win)
  wm.grab_button(connection,
                1,
                win,
                XCB::EVENT_MASK_BUTTON_PRESS,
                XCB::GRAB_MODE_SYNC,
                XCB::GRAB_MODE_ASYNC,
                XCB::WINDOW_NONE,
                XCB::NONE,
                1,
                XCB::MOD_MASK_1)
end

tree_reply = wm.query_tree_reply(connection, wm.query_tree(connection, screen[:root]), nil)
child_count = wm.query_tree_children_length(tree_reply)
children = wm.query_tree_children(tree_reply);

children = children.read_array_of_type(:uint32, :read_uint32, child_count)

children.each do |child|
  #attr = wm.get_window_attributes_reply(connection, wm.get_window_attributes(connection, child), nil)
  setup_mouse(wm, connection, child)
end

wm.flush(connection)

def mousemotion(wm, connection, connection_fd, screen, win)
  geom = wm.get_geometry_reply(connection, wm.get_geometry(connection, win), nil)
  pointer = wm.query_pointer_reply(connection, wm.query_pointer(connection, screen[:root]), nil)

  wm.grab_pointer_reply(connection,
    wm.grab_pointer(connection,
                        0,
                        screen[:root],
                        XCB::EVENT_MASK_BUTTON_PRESS | XCB::EVENT_MASK_BUTTON_RELEASE | XCB::EVENT_MASK_BUTTON_MOTION | XCB::EVENT_MASK_POINTER_MOTION,
                        XCB::GRAB_MODE_ASYNC,
                        XCB::GRAB_MODE_ASYNC,
                        XCB::NONE,
                        XCB::NONE,
                        XCB::CURRENT_TIME),
  nil)

  ungrab = false
  while !ungrab do
    wm.flush(connection)
    #res = wm.wait_for_event(connection)
    res = wait_for_event(wm, connection, connection_fd)
    event = res[:response_type] & ~0x80
    wm.flush(connection)

    case event
    when XCB::MOTION_NOTIFY
      mne = XCB::MotionNotifyEvent.new res.to_ptr
      event_win = mne[:child]
      ev_root_x = mne[:root_x]
      ev_root_y = mne[:root_y]

      target_x = geom[:x] + ev_root_x - pointer[:root_x]
      target_y = geom[:y] + ev_root_y - pointer[:root_y]

      coords = FFI::MemoryPointer.new(:int, 2)
      coords.write_array_of_int([target_x, target_y])
      wm.configure_window(connection, event_win, XCB::CONFIG_WINDOW_X | XCB::CONFIG_WINDOW_Y, coords)
      wm.flush(connection)

    when XCB::BUTTON_RELEASE
      ungrab = true

    else
      puts event
    end
  end

  wm.ungrab_pointer(connection, XCB::CURRENT_TIME)
  wm.flush(connection)

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

def wait_for_event(wm, connection, connection_fd, conn_sock = nil)
  fds = [connection_fd, conn_sock].compact
  event = nil
  until event
    events, _, _ = IO.select(fds, nil, nil, 0.25)
    if events
      event = wm.poll_for_event(connection) if events.include?(connection_fd)
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
  res = wait_for_event(wm, connection, connection_fd, conn_sock)
  puts res
  win = res[:pad][2]
  event = res[:response_type] & ~0x80

  wm.flush(connection)
  case event
  when XCB::BUTTON_PRESS
    mousemotion(wm, connection, connection_fd, screen, win)
    wm.flush(connection)
  else
    puts 'UNKNOWN'
    puts event
  end
end
