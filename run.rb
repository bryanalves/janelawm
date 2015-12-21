#!/usr/bin/env ruby

require 'pry'

require_relative './xcb'
require_relative './wm'
require_relative './control_socket'

xcb_conn = XCB::Connection.new
ctrl_socket = ControlSocket.new
wm = Wm.new(xcb_conn, ctrl_socket)

def debug(msg)
  $stderr.puts "mainloop: #{msg}"
end

while true
  event = wm.wait_for_event
  wm.conn.flush

  case event.event_type
  when XCB::MAP_REQUEST
    win = event[:pad][1]
    debug 'map_request'
    wm.map_request(win)

  when XCB::CONFIGURE_REQUEST
    debug 'configure_request'

  when XCB::PROPERTY_NOTIFY
    debug 'property_notify'

  when XCB::CONFIGURE_NOTIFY
    debug 'configure_notify'

  when XCB::ENTER_NOTIFY
    win = event[:pad][2]
    debug 'enter_notify'
    wm.enter_notify(win)

  when XCB::BUTTON_PRESS
    win = event[:pad][2]
    debug 'button_press'
    if event[:pad0] == XCB::LEFT_MOUSE
      wm.mousemove(win)
    elsif event[:pad0] == XCB::RIGHT_MOUSE
      wm.mouseresize(win)
    end
  else
    $stderr.puts "mainloop: unknown event: #{event.event_type}"
  end
end
