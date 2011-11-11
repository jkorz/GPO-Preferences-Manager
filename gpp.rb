#GPP::PrinterAssignments
#
#Example usage when required in another ruby program:
#
#  # Finds all GPP printer assignments for domain, generates html representation and displays it in the default browser
#  require './gpp.rb'
#  GPP::PrinterAssignments.new
#
#Example usage when run from the command line:
#
#  ruby gpp.rb 
#
#GPP is compatible with the OCRA gem. You may compile this file by typing:
#
#  gem install ocra
#  ocra gpp.rb
#
#And run the resulting gpp.exe using the command line or double clicking


require 'nokogiri'
module GPP

	class PrinterAssignments
		attr_accessor :printers, :ad_groups, :domain
		
		#initialize
		#
		#If domain argument is given, it will find all GPP printer assignments for the domain the computer is a member of, generate the HTML file and open it in the default browser. 
		#Otherwise, simply initialize the instance variables.
		def initialize(auto_run = true)
			@printers = {}
			@ad_groups = {}
			@domain = ENV['USERDNSDOMAIN']
			
			if auto_run
				t = self.for_domain(@domain)
				f = self.class.write_file(t)
				self.class.open_file_in_browser(f)
			end
		end
		
		#add_xml
		#
		#Adds the data in an XML file to printers and ad_groups.
		#Requires the full path 
		def add_xml(path)
			doc = Nokogiri::XML.parse(open(path)){|c| c.options = Nokogiri::XML::ParseOptions::NOBLANKS}
			printers = doc.xpath('//Printers/SharedPrinter')
			printers.each do |p|
				filter_groups = p.xpath('.//FilterGroup')
				name = p.attributes['name'].value
				@printers[name.upcase] ||= []
				filter_groups.each do |g| 
					n = g.attributes['name'].value.gsub(/.+\\/, '')
					@ad_groups[n] ||= []
					@ad_groups[n] << name
					@printers[name.upcase] << n
				end
			end
			nil
		end
		
		
		#to_html
		#
		#Writes the current printers and ad groups to an HTML file. 
		def to_html
			self.class.write_html(@printers, @ad_groups)
		end
		
		#for_domain
		#
		#Gets all gpo paths which contain printer preferences and adds their data to printers and ad groups.
		def for_domain(domain_name)
			paths = self.class.catalog_gpo_paths(domain_name)
			raise "Domain name incorrect or no Printer Preferences found. Please use the full domain name such as ad.contoso.com." if paths.length == 0
			paths.each do |path|
				add_xml(path)
			end
			to_html
		end
		
		#self.write_file
		#
		#Writes text from output argument to file location specified in path argument.
		def self.write_file(output, path = ENV['temp'])
			filename = '\\printers.html'
			full_path = path + filename
			f = File.open(full_path, 'w')
			f.write output
			f.close
			full_path
		end
		
		#self.open_file_in_browser
		#
		#Opens the given file in its default viewer.
		def self.open_file_in_browser(file)
			`start file:///#{file}`
			nil
		end
			
		#self.catalog_gpo_paths
		#
		#Finds the path of all GPO preferences printer assignment files.  
		def self.catalog_gpo_paths(domain_name)
			printer_subfolder = "/\User/\Preferences/\Printers/\Printers.xml"
			dirs = Dir["\/\/#{domain_name}\/sysvol\/#{domain_name}\/Policies\/*"]
			raise "The domain specified is incorrect. Please use a fully qualified domain name such as ad.contoso.com" if dirs.length == 0
			paths = []
			dirs.each do |dir|
				full_path = dir + printer_subfolder
				paths << full_path if File.exists? full_path
			end
			paths
		end
		
		
		#self.write_html
		#
		#Creates a formatted html document containing all the printers and ad groups. 
		def self.write_html(printers, ad_groups)
			output = <<-eos
			<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
			"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
			<html><head><title>GPO Printer Groups</title><style>
				body{
					width: 700px;
					color: #111111;
				}
				.entry{
					width: 100%;
					float: left;
					padding: 3px;
					margin: 3px;
					background-color: #EEEEFF;
				}
				.title{
					width: 90%;
					float: left;
					font-weight: bold;
					
				}
				.container{
					float: left;
					margin-top: 5px;
				}
				.header{
					float: left;
					margin-top: 5px;
					width: 100%;
				}
				.printer{
					float: left;
					padding: 3px;
					margin: 4px;
					background-color: #DDDDEE;
				}
				.grouplistitem{
					float: left;
					margin: 2px;
					padding: 3px;
					background-color: #DDDDFF;
				}
				.top{
					float: right;
				}
				a, a.link{
					color: #002244;
				}
				h3, hr{float: clear;}
				.clear{float: clear;}
				</style></head><body><h2>Groups</h2><hr />
			eos
			ad_groups.sort.each do |k,v|
				output += "<div class=\"grouplistitem\"><a href=\"##{k.gsub(/[\W_]/, '')}\">#{k}</a></div>"
			end
			output += "<div class=\"header\"><h2>Printers</h2><hr /></div>"
			printers.sort.each do |k,v|
				output += "<div class=\"grouplistitem\"><a href=\"##{k.gsub(/[\W_]/, '')}\">#{k}</a></div>"
			end
			output += "<div class=\"entry\"><h2>Groups</h2><hr /></div>"
			ad_groups.sort.each do |k,v|
				output += "<div class=\"entry\"><div class=\"title\"><a name=\"#{k.gsub(/[\W_]/, '')}\">#{k}</a></div><div class=\"top\"><a href=\"#\">Top</a></div><div class=\"container\">"
				v.each do |printer|
					output += "<a href=\"##{printer.gsub(/[\W_]/, '')}\"><span class=\"printer\">#{printer}</span></a>"
				end
				output += "</div><div class=\"clear\"></div></div>"
			end
			output += "<div class=\"entry\"><h2>Printers</h2><hr /></div>"
			printers.sort.each do |k,v|
				output += "<div class=\"entry\"><div class=\"title\"><a name=\"#{k.gsub(/[\W_]/, '')}\">#{k}</a></div><div class=\"top\"><a href=\"#\">Top</a></div><div class=\"container\">"
				v.each do |group|
					output += "<a href=\"##{group.gsub(/[\W_]/, '')}\"><span class=\"printer\">#{group}</span></a>"
				end
				output += "</div><div class=\"clear\"></div></div>"
			end
			output += "</body></html>"
		end
	end
end

# If this file is run from the command line instead of being required, run the default routine.
if File.identical?(__FILE__, $0)
	GPP::PrinterAssignments.new
end
