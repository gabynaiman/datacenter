require_relative 'lib/datacenter.rb'
require 'hirb'
extend Hirb::Console

server  = ARGV[0]
user = ARGV[1]

shell = Datacenter::Shell::Ssh.new server,user
shell.open
machine = Datacenter::Machine.new shell

puts "General Information \n\n"

# Server name
server = [{:value=>"Server : #{server} \n", :level=>0}]
# Operating System
os = [{:value=>"Operating System", :level=>0}]
os << {:value=>"#{machine.os.name} #{machine.os.distribution}" "#{machine.os.version}", :level=>3}
os << {:value=>"Kernel #{machine.os.kernel} #{machine.os.platform}", :level=>3}
# Hardware
hw = [{:value=>"Hardware", :level=>0}]
hw << {:value=>"Memory: #{machine.memory.to_i} MB", :level=>3}
hw << {:value=>"Processor: #{machine.cpu} x #{machine.cores}", :level=>3}
# Status
st = [{:value=>"Status", :level=>0}]
st += machine.disk_partition.map { |p| Hash[:value => "Partition #{p.filesystem}: #{p.available.to_i} MB available", :level=>3] }
st << {:value=>"Memory Free: #{machine.memory_free.to_i} MB", :level=>3}
st << {:value=>"Swap Free: #{machine.swap_free.to_i} MB", :level=>3}

info_machine = server + os + hw + st
puts "#{Hirb::Helpers::Tree.render(info_machine)} \n"

puts "\n\nDetailed Information \n\n"

puts 'Operating System'
os_fields = [:name, :distribution, :platform, :kernel, :version]
table machine.os, :fields=>os_fields

puts 'Hardware'

hw_fields = [:cpu, :cores, :memory]
hw = {}
hw[:cpu] = "#{machine.cpu}"
hw[:cores] = "#{machine.cores}"
hw[:memory] = "#{machine.memory.to_i} MB"
puts Hirb::Helpers::Table.render [hw], :fields=>hw_fields

puts 'Top Processes by Memory Usage'
pr_fields = [:name, :mem_usage, :cpu_usage, :command, :status, :user]
table machine.top(:memory)[0..5], :fields=>pr_fields

puts 'Top Processes by CPU Usage'
pr_fields = [:name, :mem_usage, :cpu_usage, :command, :status, :user]
table machine.top(:cpu)[0..5], :fields=>pr_fields

puts 'Filesystems'
hdd_fields = [:filesystem, :type, :size, :used, :available, :use, :mounted]
hdd = machine.disk_partition.map { |p| Hash[:filesystem=>"#{p.filesystem}", 
																						:size=>"#{p.size.to_i} MB",
																						:type=>"#{p.type}",
																						:used=>"#{p.used.to_i} MB",
																						:available=>"#{p.available.to_i} MB",
																						:use=>"#{p.p_use} %",
																						:mounted=>"#{p.mounted} "]}
puts Hirb::Helpers::Table.render hdd, :fields=>hdd_fields

puts 'Memory'
mem_fields = [:memory, :memory_free, :memory_used, :swap, :swap_used, :swap_free]
mem = {}
mem[:memory] = "#{machine.memory.to_i} MB"
mem[:memory_free] = "#{machine.memory_free.to_i} MB"
mem[:memory_used] = "#{machine.memory_used.to_i} MB"
mem[:swap] = "#{machine.swap.to_i} MB"
mem[:swap_free] = "#{machine.swap_free.to_i} MB"
mem[:swap_used] = "#{machine.swap_used.to_i} MB"
puts Hirb::Helpers::Table.render [mem], :fields=>mem_fields

# TODO: No funciona el menú
# class InfoMachineType
# 	attr_reader :description

# 	def initialize(description, detail)
# 		@description = description
# 		@detail = detail
# 	end
	
# 	def detail
# 	 	Hirb::Helpers::Tree.render(@detail)
# 	end	
# end

# type_gen = InfoMachineType.new 'Informacion General', info_machine
# type_det = InfoMachineType.new 'Info Detallada', 'Muestra info detallada'

# menu [type_gen, type_det], :prompt=> "Elegir opción: ", :fields => [:description], :default_field=>:detail, :two_d=>true