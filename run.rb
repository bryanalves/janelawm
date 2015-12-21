#!/usr/bin/env ruby

require 'pry'

require_relative './xcb'
require_relative './wm'
require_relative './control_socket'

xcb_conn = XCB::Connection.new
ctrl_socket = ControlSocket.new
wm = Wm.new(xcb_conn, ctrl_socket)

wm.run
