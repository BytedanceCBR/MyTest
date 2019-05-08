require 'delegate'
module Pod
  class Specification
    class Consumer
      def dependencies
          []
      end
    end
  end
  
  class PodTarget < Target
    if Pod::VERSION > '1.4.0'
      def header_search_paths(include_test_dependent_targets = false)
        header_search_paths = []
        header_search_paths.concat(build_headers.search_paths(platform, nil, false))
        header_search_paths.concat(sandbox.public_headers.search_paths(platform))
        dependent_targets = recursive_dependent_targets
        dependent_targets += recursive_test_dependent_targets if include_test_dependent_targets
        dependent_targets.each do |dependent_target|
          header_search_paths.concat(sandbox.public_headers.search_paths(platform, dependent_target.pod_name, defines_module? && dependent_target.uses_modular_headers?(false)))
        end
        header_search_paths.uniq
      end
    end
  end
end
