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

def enter_notify(wm, event)
  win_pointer = FFI::MemoryPointer.new(:int, 1)
  win_pointer.write_array_of_int([event[:pad][2]])
  wm.conn.change_property(XCB::PROP_MODE_REPLACE,
                          wm.screen[:root],
                          Wm::NET_ATOMS['_NET_ACTIVE_WINDOW'],
                          XCB::ATOM_WINDOW,
                          32,
                          1,
                          win_pointer)

  stack = FFI::MemoryPointer.new(:int, 1)
  stack.write_array_of_int([0])
  wm.conn.configure_window(event[:pad][2], XCB::CONFIG_WINDOW_STACK_MODE, stack)
  wm.conn.set_input_focus(XCB::INPUT_FOCUS_POINTER_ROOT, event[:pad][2], XCB::NONE)
  wm.conn.flush
end

def debug(msg)
  $stderr.puts "mainloop: #{msg}"
end

while true
  event = wm.wait_for_event
  wm.conn.flush

  window_hex = event[:pad][2].to_s(16)

  case event.event_type
  when XCB::MAP_REQUEST
    win = event[:pad][1]
    wm.conn.map_window(win)
    coords = FFI::MemoryPointer.new(:int, 2)
    coords.write_array_of_int([0, 0])
    wm.conn.configure_window(win, XCB::CONFIG_WINDOW_X | XCB::CONFIG_WINDOW_Y, coords)
    wm.setup_child(win)
    wm.conn.flush
    debug "map_request: #{win.to_s(16)}"
  when XCB::CONFIGURE_REQUEST
    debug "configure_request: #{window_hex}"
  when XCB::PROPERTY_NOTIFY
    debug "property_notify"
  when XCB::CONFIGURE_NOTIFY
    debug "configure_notify: #{window_hex}"
  when XCB::ENTER_NOTIFY
    debug "enter_notify: #{window_hex}"
    enter_notify(wm, event)
  when XCB::BUTTON_PRESS
    debug "button_press: #{window_hex}"
    win = event[:pad][2]
    if event[:pad0] == XCB::LEFT_MOUSE
      wm.mousemove(win)
    elsif event[:pad0] == XCB::RIGHT_MOUSE
      wm.mouseresize(win)
    end
  else
    $stderr.puts "mainloop: unknown event: #{event.event_type}"
  end
end

