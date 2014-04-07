require 'yaml'

module InchCI
  module Worker
    module Build
      class Report < Struct.new(:build)
        def to_yaml
          to_hash.to_yaml
        end

        private

        def to_hash
          data = {
              'status' => build.status,
              'repo_url' => build.url,
              'branch_name' => build.branch_name,
              'started_at' => build.started_at,
              'finished_at' => build.started_at,
            }
          data['service_name'] = build.service_name.to_s if build.service_name
          data['user_name'] = build.user_name if build.user_name
          data['repo_name'] = build.repo_name if build.repo_name
          data['revision'] = build.revision_uid if build.revision_uid
          data['objects'] = objects_hash if build.objects
          {'build' => data}
        end

        def objects_hash
          build.objects.map do |o|
            code_object_to_hash(o)
          end
        end

        def code_object_to_hash(o)
          {
            'type' => o.type,
            'fullname' => o.fullname,
            'score' => o.score.to_i,
            'grade' => o.grade.to_s,
            'priority' => o.priority.to_i,
            'location' => location(o.files.first),
            'roles' => o.roles.map { |r| role_to_hash(o, r) },
          }
        end

        def location(file)
          "#{file.relative_path}:#{file.line_no}"
        end

        def role_to_hash(object, role)
          ref_name = role.object.fullname
          name = role.class.to_s.gsub('Inch::Evaluation::Role::', '')
          hash = {
            'name' => name,
            'priority' => role.priority,
          }
          hash['potential_score'] = role.potential_score if role.potential_score
          hash['score'] = role.score if role.score
          hash['min_score'] = role.min_score if role.min_score
          hash['max_score'] = role.max_score if role.max_score
          hash['ref_name'] = ref_name if object.fullname != ref_name
          hash
        end
      end
    end
  end
end
