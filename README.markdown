# GPO Preferences Manager

A simple program for exporting active directory groups and the printers associated with them via group policy preferences. 

## Installation

Simply download gpp.exe and run. If you want to use the .rb file, you'll need the nokogiri gem. 

## Usage

	C:\> gpp.exe
	
or

	C:\> ruby gpp.rb
	
## Advanced usage

	require "./gpp.rb"
	
	gpp = GPP::PrinterPreferences.new(false)
	html_output = gpp.for_domain('ad.contoso.com')
	file = gpp.class.write_file(html_output)
	GPP::PrinterPreferences.open_file_in_browser(file)