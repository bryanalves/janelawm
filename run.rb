require_relative './xcb'
require_relative './wm'
require_relative './control_socket'
require 'pry'

xcb_conn = XCB::Connection.new
ctrl_socket = ControlSocket.new
wm = Wm.new(xcb_conn, ctrl_socket)
wm.setup_children

while true do
  event = wm.wait_for_event
  wm.conn.flush

  case event.event_type
  when XCB::BUTTON_PRESS
    win = event[:pad][2]
    if event[:pad0] == 1
      wm.mousemove(win)
    elsif event[:pad0] == 3
      wm.mouseresize(win)
    end
  else
    $stderr.puts "unknown event: #{event}"
  end
end
