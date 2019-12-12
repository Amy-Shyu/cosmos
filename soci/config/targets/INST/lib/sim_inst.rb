require 'cosmos'

module Cosmos
  # simulated instrument
  class SimInst < SimulatedTarget
  
    def initialize(target_name)
      super(target_name)
    
      packet = @tlm_packets['STATUS']
      packet.enable_method_missing
      packet.status = "NONE"
    end # initialize
  
    def set_rates
      set_rate('STATUS', 100)
      set_rate('DATA', 10)
    end # set_rates
  
    def write(packet)
      @tlm_packets['STATUS'].status = packet.read("status")
    end # write
  
    def read(count_100hz, time)
      pending_packets = get_pending_packets(count_100hz)
    
      pending_packets.each do |packet|
        case packet.packet_name
        when 'STATUS'
          case packet.status
          when 'OK'
            packet.uptime += 1
          end
            
          packet.counter += 1
        when 'DATA'
          cycle_tlm_item(packet, 'temp1', -95.0, 95.0, 1.0)
          
          packet.timesec = time.tv_sec
          packet.timeus  = time.tv_usec
          packet.counter += 1
        end
      end
      pending_packets
    end # read
  end # class *SimInst*
end # module *Cosmos*