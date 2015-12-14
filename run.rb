#!/usr/bin/env ruby

require_relative './xcb'
require_relative './wm'
require_relative './control_socket'
require 'pry'

def restart
  $stderr.puts 'Restarting'
  exec $PROGRAM_NAME
  $stderr.puts 'Unable to restart'
  exit(1)
end

xcb_conn = XCB::Connection.new
ctrl_socket = ControlSocket.new
wm = Wm.new(xcb_conn, ctrl_socket)
wm.setup_root
wm.setup_children

while true do
  event = wm.wait_for_event
  wm.conn.flush

  case event.event_type
  when XCB::BUTTON_PRESS
    win = event[:pad][2]
    if event[:pad0] == XCB::LEFT_MOUSE
      wm.mousemove(win)
    elsif event[:pad0] == XCB::RIGHT_MOUSE
      wm.mouseresize(win)
    end
  else
    $stderr.puts "unknown event: #{event}"
  end
end
