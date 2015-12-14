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

while true
  event = wm.wait_for_event
  wm.conn.flush

  case event.event_type
  when XCB::MAP_REQUEST
    $stderr.puts 'mainloop: map_request'
  when XCB::CONFIGURE_REQUEST
    $stderr.puts 'mainloop: configure_request'
  when XCB::PROPERTY_NOTIFY
    $stderr.puts 'mainloop: property_notify'
  when XCB::CONFIGURE_NOTIFY
    $stderr.puts 'mainloop: configure_notify'
  when XCB::ENTER_NOTIFY
    $stderr.puts "mainloop: enter_notify #{event[:pad][2].to_s(16)}"
    enter_notify(wm, event)
  when XCB::BUTTON_PRESS
    $stderr.puts 'mainloop: button_press'
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

