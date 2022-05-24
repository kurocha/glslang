# Teapot v3.0.0 configuration generated at 2019-02-16 19:36:29 +1300

required_version "3.0"

define_project "glslang" do |project|
	project.title = "Glslang"
end

# Build Targets

define_target 'glslang-executable' do |target|
	target.depends :platform
	
	target.depends 'Build/CMake'
	target.depends 'Build/Make'
	
	target.provides 'Executable/glslang' do
		source_files = target.package.path + "glslang"
		cache_prefix = environment[:build_prefix] / environment.checksum + "glslang"
		executable_path = cache_prefix + "bin/glslangValidator"
		package_files = executable_path
		
		cmake source: source_files, install_prefix: cache_prefix, arguments: [
			"-DBUILD_SHARED_LIBS=OFF",
		], package_files: package_files
		
		glslang_executable executable_path
	end
end

define_target "glslang" do |target|
	target.depends "Executable/glslang", public: true
	
	target.provides "Convert/GLSLang" do
		define Rule, "convert.glslang-file" do
			input :source_file, pattern: /\.frag|\.vert/
			output :destination_path
			
			apply do |arguments|
				mkpath File.dirname(arguments[:destination_path])
				
				run!(environment[:glslang_executable], arguments[:source_file], "-V", "-o", arguments[:destination_path])
			end
		end
		
		define Rule, "convert.glslang-files" do
			# The input prefix where files are copied from:
			input :source, multiple: true, pattern: /\.frag|\.vert/
			
			# The output files:
			parameter :root
			parameter :extension, default: '.spv'
			parameter :basename, default: false
				
			apply do |arguments|
				output_mapping = arguments.select{|key| [:root, :extension, :basename].include? key}
				
				arguments[:source].each do |path|
					destination_path = path.with(output_mapping)
					
					convert source_file: path, destination_path: destination_path
				end
			end
		end
	end
end

# Configurations

define_configuration 'development' do |configuration|
	configuration[:source] = "https://github.com/kurocha"
	configuration.import "glslang"
	
	# Provides all the build related infrastructure:
	configuration.require 'platforms'
end

define_configuration "glslang" do |configuration|
	configuration.public!
	
	configuration.require "build-make"
	configuration.require "build-cmake"
end
