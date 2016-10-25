require "ParcoursClient/version"

module ParcoursClient
	def parse(l)
		line = l.clone()
		log = Hash.new
		time = DateTime.strptime( line.slice!(/\[.*?\]/), "[%d/%b/%Y:%H:%M:%S %Z]").to_time.to_i
		request = line.slice!(/".*"/)
		resource = request.split()[1]
		ip, identity, username, status, size = line.split

		log['ip'] = ip
		log['time'] = time
		log['request'] = request
		log['resource'] = resource
		log['status'] = status
		log['size'] = size
		return log
	end  



	def generationFichierJSONFromHash(h,filenameToGenerate)
		File.open(filenameToGenerate,"w") do |f|
			f.write(JSON.pretty_generate(h))
		end
	end

	def generationFichierFromArray(a,filenameToGenerate)
		File.open(filenameToGenerate,"w") do |f|
			a.each { |r,n| f << "#{r}:#{n}\n"}
		end
	end

	def creationFichiers(filename)

		f20X = File.new("20X.log", "w")
		f40X = File.new("40X.log", "w")
		f50X = File.new("50X.log", "w")

		File.readlines(filename).each_with_index do |line,lineNumber|
			begin
		 		log = parse(line)
		 		case log['status'][0,1]
		 			when "2"
		 				f20X.puts line
			 		when "4"
			 			f40X.puts line		 	
			 		when "5"
			 			f50X.puts line		 	
			 	end
			rescue => e
		  		puts "Skipping parse error at line:#{lineNumber} (#{line[0,10]}...)".yellow
		  	end
		end
		  	
		f20X.close
		f40X.close
		f50X.close
	end

	def parcoursClient(filename)
		parcours = Hash.new { |hash, key| hash[key] = [] }

		puts "Analyzing #{filename}".green

		File.readlines(filename).each_with_index do |line,lineNumber|
			begin
		 		log = parse(line)
		  		if log['resource'].end_with? ".html" 	
			  		visite = { 'resource' => log['resource'] , 'time' => log['time']}
			  		parcours[log['ip']] << visite
		  		end
		  	rescue => e
		  		puts "Skipping parse error at line:#{lineNumber} (#{line[0,10]}...)".yellow
		  	end
		end
	  	return parcours
	end

	def classement(filename)
		tmp = Hash.new { |hash, key| hash[key] = [] }

		File.readlines(filename).each_with_index do |line,lineNumber|
			begin
		 		log = parse(line)
		 		tmp[log['resource']] << '1' 
		  	rescue => e
		  		puts "Skipping parse error at line:#{lineNumber} (#{line[0,10]}...)".yellow
		  	end
		end
		mapTmp = tmp.map { |k, val| [k, val.length] }.to_h
		resultat = mapTmp.to_a.sort {|r1,r2| r2[1] <=> r1[1] }
		generationFichierFromArray(resultat,"classement.json")
		puts "classement.json generated".green
		end





	def pageDeSortie(filename)
		parcours = parcoursClient(filename)
		tmp = Hash.new { |hash, key| hash[key] = [] }
		parcours.values.each do |visites|
			tmp[visites.last['resource']] << "1"
		end
		mapTmp = tmp.map { |k, val| [k, val.length] }.to_h
		resultat = mapTmp.to_a.sort {|r1,r2| r2[1] <=> r1[1] }
		generationFichierFromArray(resultat,"pageDeSortie.json")
		puts "pageDeSortie.json generated".green

	end






	def ajouteDureeAuParcours(filename)

		parcours = parcoursClient(filename)
		parcours.values.each do |visites|
			begin
				previous = nil
				visites.each do |visite|
					unless previous.nil?
						previous['duration'] = visite['time'] - previous['time'] 
						
						if previous['duration'] < 3600 
							previous['exit'] = false
						else 
							previous['duration'] = 0
						end

						visite['duration'] = 0
						visite['exit'] = true
					end
					previous = visite
				end
				previous['duration'] = 0
				previous['exit'] = true

			end
		end
		#generationFichierJSONFromHash(parcours,"parcoursWithDuration.json")
		#puts "parcoursWithDuration.json generated".green
		return parcours
	end


	def dureeParPage(filename)
		durationByResource = Hash.new { |hash, key| hash[key] = [] }
		
		parcoursAvecDuree = calculDureeParPage(filename)
		parcoursAvecDuree.values.each do |visites|
			previous = nil
			visites.each do |visite|
				durationByResource[visite['resource']] << visite['duration']
			end
		end
		generationFichierJSONFromHash(durationByResource,"dureeParPage.json")
		puts "dureeParPage.json generated".green
		return durationByResource
	end

	def statsParPage(filename)
		durationByResource = dureeParRessource(filename)
		result = Hash.new { |hash, key| hash[key] = [] }


		durationByResource.each do |resource,durations|
			stat = Hash.new
			tmp = durations - [0]
			stat['outputpage'] = durations.length - tmp.length
			stat['dureemoyenne'] = tmp.inject{ |sum, el| sum + el }.to_f / tmp.size if tmp.length != 0

			result[resource] = stat
		end
		generationFichierJSONFromHash(result,"statsParRessource.json")
		puts "statsParRessource.json generated".green
		return result
	end

	def pagesDOrigine(filename)
		parcours = parcoursClient(filename)
		pagesDOrigine = Hash.new { |hash, key| hash[key] = [] }

		parcours.values.each do |visites|
			previous = nil
			visites.each do |visite|
				if !previous.nil?
					pagesDOrigine[visite['resource']] << previous['resource']  unless pagesDOrigine[visite['resource']].include?(previous['resource'])
				end
			previous = visite
			end
		end
		generationFichierJSONFromHash(pagesDOrigine,"pagesDOrigine.json")
		puts "pagesDOrigine.json generated".green
		return pagesDOrigine
	end
end
