#Creates a UUID using the windows API

require 'Win32API'
class GUID
	
	@@uuid_create = Win32API.new('rpcrt4', 'UuidCreate', 'P', 'L')

	def self.generate
	  result = ' ' * 16
	  @@uuid_create.call(result)
	  a, b, c, d, e, f, g, h = result.unpack('SSSSSSSS')
	  sprintf('{%04X%04X-%04X-%04X-%04X-%04X%04X%04X}', a, b, c, d, e, f, g, h)
	end
end