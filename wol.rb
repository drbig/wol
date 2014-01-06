#!/usr/bin/env ruby
# coding: utf-8
# vim: ts=2 et sw=2 sts=2
#
# wol.rb - Wake on Lan
# 
# © Copyright Piotr S. Staszewski 2013
# Visit http://www.drbig.one.pl for contact information.
#

require 'socket'

class WOL
  BRDCASTIP = '192.168.0.255'
  MACTAB = {
    'bebop.l' => '70:5A:B6:94:8F:59',
    'gamer.l' => '00:25:22:f4:0b:0e',
    'lore.l' => '00:40:ca:6d:16:07',
    'nox.l' => '00:40:63:D5:8B:65',
    'rpi.l' => 'B8:27:EB:0D:EB:01'
  }

  @s = UDPSocket.new
  @s.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)

  def self.send(mac)
    if mac.match(/..:..:..:..:..:../).nil?
      nmac = MACTAB[mac]
      unless nmac
        STDERR.puts "#{mac} - failed to parse, packet not send."
        return false
      end
      mac = nmac
    end
    payload = 0xff.chr*6 + mac.split(':').pack('H*'*6)*16
    3.times { @s.send(payload, 0, BRDCASTIP, 'discard') }
  end
end

if __FILE__ == $0
  ARGV.each {|a| WOL.send(a) }
end
