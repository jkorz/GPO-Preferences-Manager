#Converts a binary SID from active directory to the human readable format
class SID

	def self.convert(data)
	  sid = data[0..1].unpack('hh')
	  
	  len = sid.pop.to_i + 2
	  
	  rid = data.to_s[3..len].split(//).map{|i| i.unpack('h')[0]}.join('').to_i
	  sid << rid.to_i.to_s
	 
	  sid += data.unpack("bbbbbbbbV*")[8..-1]
	  "S-" + sid.join('-')
	end
	
end