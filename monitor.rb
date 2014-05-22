require_relative 'lib/datacenter.rb'	
require 'hirb'
require 'benchmark'
extend Hirb::Console

## Set up
server  = ARGV[0]
user = ARGV[1]

shell = Datacenter::Shell::Ssh.new server,user
shell.open
machine = Datacenter::Machine.new shell

## General Information
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

## Detailed Information
puts "\n\nDetailed Information \n\n"

filter_size = Proc.new{|e| "#{e.to_i} MB"}
filter_perc = Proc.new{|e| "#{e} %"}

puts 'Operating System'
os_fields = [:name, :distribution, :platform, :kernel, :version]
table machine.os, :fields=>os_fields

puts 'Hardware'

hw_fields = [:cpu, :cores, :memory]
table machine, :fields=>hw_fields, :filters=>{:memory=>filter_size}

puts 'Processes With Filter'
pr_fields = [:name, :mem_usage, :cpu_usage, :command, :status, :user]
puts "Time: #{Benchmark.measure { table machine.processes('ruby'), 	:fields=>pr_fields,
																																		:filters=>{:mem_usage=>filter_perc,
																													 					:cpu_usage=>filter_perc}}.real }"

puts 'Top Processes by Memory Usage'
pr_fields = [:name, :mem_usage, :cpu_usage, :command, :status, :user]
puts "Time: #{Benchmark.measure { table machine.top(:memory), :fields=>pr_fields,
																															:filters=>{:mem_usage=>filter_perc,
																													 							 :cpu_usage=>filter_perc}}.real }"

puts 'Top Processes by CPU Usage'
puts "Time: #{Benchmark.measure { table machine.top(:cpu), :fields=>pr_fields, 
																													 :filters=>{:mem_usage=>filter_perc,
																													 						:cpu_usage=>filter_perc} }.real}"

puts 'Filesystems'
bench = Benchmark.measure do 
hdd_fields = [:filesystem, :type, :size, :used, :available, :p_use, :mounted]
table machine.disk_partition, :fields=>hdd_fields, :filters=>{:size=>filter_size,
																															:used=>filter_size,
																															:available=>filter_size,
																															:p_use=>filter_perc}
end
puts "Time: #{bench.real}"

puts 'Memory'
bench = Benchmark.measure do 
mem_fields = [:memory, :memory_free, :memory_used, :swap, :swap_used, :swap_free]
table machine, :fields=>mem_fields, :filters=> Hash.new.tap { |f| mem_fields.map { |e| f[e]=filter_size } }
end
puts "Time #{bench.real}"

## Menu: TODO: Hay que definir como usarlo, es para verlo
class InfoMachineType
	attr_reader :description

	def initialize(description, detail)
		@description = description
		@detail = detail
	end
	
	def detail
	 	Hirb::Helpers::Tree.render(@detail)
	end	
end

type_gen = InfoMachineType.new 'Informacion General', info_machine
type_det = InfoMachineType.new 'Info Detallada', info_machine

puts menu [type_gen, type_det], :prompt=> "Elegir opción: ", 
																:fields => [:description], 
																:default_field=>
																:detail,
																:two_d=>true
