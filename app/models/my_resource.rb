class MyResource < DAV4Rack::FileResource
	# request.env["PATH_INFO"]
	# path looks like this [B/D/Skcript_Icon.png]
	# request path looks like this [/B/D/Skcript_Icon.png]

	TYPEMATCH = %r{^.*\.[^\\$]}
	HIDDENMATCH = %r{^._}

	def hidden_entity?(name)
		return true if name == ".DS_Store"
		return true if name.match(HIDDENMATCH)
		return false
	end

	def entity_type
		name = File.basename(path)
		dir = File.dirname(path)
		if path.match(TYPEMATCH)
			if hidden_entity?(name)
				# puts "NOT adding hidden files!"
				return :invalid
			else
				# puts "Adding file #{name} to #{dir}!"
				return :file
			end
		else
			# puts "Adding folder #{name} to #{dir}!"
			return :folder
		end
	end

	def file?
		entity_type == :file
	end

	def folder?
		entity_type == :folder
	end

	def move_entity(dest)
		if file?
			puts "Moving file from #{path} to #{dest}"
		elsif folder?
			puts "Moving folder from #{path} to #{dest}"
		end
	end

	# =========== OVER RIDING PARENT FUNCTIONS ===========

	def root
		File.join(options[:root].to_s, user.id.to_s)
	end

	# File Creation
 	def put(request, response)
 		puts "FILE CREATION #{path}" if file?
 		super
    end

    # Folder Creation
    def make_collection
    	puts "FOLDER CREATION #{path}" if folder?
      	super
    end

    # File/Folder Moving
    # File/Folder Copying is done as a new folder/file creation. 
    # Do not over ride copy function here. Since it is called by move internally.
    def move(*args)
    	# Sending destination path
    	puts "MOVING"
    	move_entity(*args[0].public_path)
      	super
    end

    def delete
    	if file?
    		puts "DELETING file #{path}"
    	elsif folder?
    		puts "DELETING folder #{path}"
    	end
    end

	private
	def authenticate(username, password)
		self.user = User.find_by_username(username)
		user.try(:valid_password?, password)
	end  
    
end