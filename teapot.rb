
teapot_version "1.0"

define_target "glslang" do |target|
	target.provides "Convert/GLSLang" do
		define Rule, "convert.glslang-file" do
			input :source_file, pattern: /\.frag|\.vert/
			output :destination_path
			
			apply do |arguments|
				mkpath File.dirname(arguments[:destination_path])
				
				run!("glslangValidator", arguments[:source_file], "-V", "-o", arguments[:destination_path])
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
