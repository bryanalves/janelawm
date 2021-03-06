class ControlSocket
  attr_reader :socket

  def initialize
    FileUtils.rm_f('/tmp/rubywm_sock')
    @socket = Socket.new(:UNIX, :STREAM)
    sock_addr = Socket.sockaddr_un('/tmp/rubywm_sock')
    socket.bind(sock_addr)
    socket.listen(5)
  end

  def command
    fd, _ = socket.sysaccept
    client_socket = Socket.for_fd(fd)
    var = client_socket.readline
    client_socket.close
    var.strip
  end
end
