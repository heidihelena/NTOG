# frozen_string_literal: true

require "yaml"

repo_root = File.expand_path("../..", __dir__)
blueprint_path = File.join(repo_root, "render.yaml")
blueprint = YAML.safe_load(File.read(blueprint_path))
services = blueprint.fetch("services")
service = services.find { |candidate| candidate["name"] == "ntog-trends" }
abort("render.yaml does not define ntog-trends") unless service

abort("ntog-trends must use the Docker runtime") unless service["runtime"] == "docker"
abort("ntog-trends must set rootDir explicitly") unless service["rootDir"] == "trends"
abort("Use buildFilter, not buildFilters") if service.key?("buildFilters")

root_dir = File.expand_path(service.fetch("rootDir"), repo_root)
dockerfile = File.expand_path(service.fetch("dockerfilePath"), root_dir)
docker_context = File.expand_path(service.fetch("dockerContext"), root_dir)

abort("Render rootDir is missing: #{root_dir}") unless Dir.exist?(root_dir)
abort("Render Dockerfile is missing: #{dockerfile}") unless File.file?(dockerfile)
abort("Render Docker context is missing: #{docker_context}") unless Dir.exist?(docker_context)
unless dockerfile.start_with?("#{docker_context}#{File::SEPARATOR}")
  abort("Render Dockerfile must be inside its Docker build context")
end

unless service["autoDeployTrigger"] == "checksPass"
  abort("ntog-trends must deploy only after checks pass")
end

puts "Verified Render Blueprint: #{dockerfile} with context #{docker_context}"
