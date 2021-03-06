# Git Test Environment Builder
#
# rubocop:disable Metrics/ModuleLength
# rubocop:disable Metrics/MethodLength
# rubocop:disable Metrics/AbcSize
module GitTestEnvBuilder
  def git_build_test_environment!
    git_create_base_component
  end

  def git_test_env_components
    @manifest = git_base_component_manifest

    @component_1 = @manifest.components[:component_1]
    @component_2 = @manifest.components[:component_2]
    @leaf_component_1 = @component_1.manifest.components[:leaf_component_1]
    @leaf_component_2 = @component_1.manifest.components[:leaf_component_2]
    @leaf_component_3 = @component_2.manifest.components[:leaf_component_3]

    [@component_1, @component_2, @leaf_component_1,
     @leaf_component_2, @leaf_component_3]
  end

  def git_base_component_manifest
    contents = File.read("#{@base_component_dir}/Compoundfile")
    GitCompound::Manifest.new(contents)
  end

  def git_create_leaf_component_1
    @leaf_component_1_dir = "#{@dir}/leaf_component_1.git"
    Dir.mkdir(@leaf_component_1_dir)

    git(@leaf_component_1_dir) do
      git_init
      git_add_file('leaf_component_1') { 'leaf_component_1_content' }
      git_commit('initial commit')
      git_tag('v1.0', 'version 1.0')
    end
  end

  def git_create_leaf_component_2
    @leaf_component_2_dir = "#{@dir}/leaf_component_2.git"
    Dir.mkdir(@leaf_component_2_dir)

    git(@leaf_component_2_dir) do
      git_init
      git_add_file('component') { 'leaf_component_2' }
      git_commit('initial commit')
      git_tag('v1.0', 'version 1.0')
    end
  end

  def git_create_leaf_component_3
    @leaf_component_3_dir = "#{@dir}/leaf_component_3.git"
    Dir.mkdir(@leaf_component_3_dir)

    git(@leaf_component_3_dir) do
      git_init
      git_add_file('component') { 'leaf_component_3' }
      git_commit('initial commit')
      git_tag('v1.0', 'version 1.0')
    end
  end

  def git_create_component_1
    git_create_leaf_component_1
    git_create_leaf_component_2

    @component_1_dir = "#{@dir}/component_1.git"
    Dir.mkdir(@component_1_dir)

    git(@component_1_dir) do
      git_init
      git_add_file('.gitcompound') do
        'name :component_1'
      end
      git_commit('gitcompound commit')
      git_tag('v0.1', 'version 0.1')
      git_add_file('version_1.1') { 'v1.1' }
      git_commit('v1.1 commit')
      git_tag('v1.1', 'version 1.1')
      git_add_file('version_1.2') { 'v1.2' }
      git_edit_file('.gitcompound') do
        <<-END
          name :component_1

          component :leaf_component_1 do
            version '1.0'
            source  '#{@leaf_component_1_dir}'
            destination '/leaf_component_1_destination'
          end

          component :leaf_component_2 do
            version '1.0'
            source  '#{@leaf_component_2_dir}'
            destination 'leaf_component_2_destination/'
          end

          task :component_1_tasks, :each do |dir, component|
            $stderr.puts "component_1_tasks for " + component.name.to_s +
              " dir: " + dir
          end
        END
      end
      git_commit('v1.2 commit')
      git_tag('v1.2', 'version 1.2')
    end
  end

  def git_create_component_2
    git_create_leaf_component_3

    @component_2_dir = "#{@dir}/component_2.git"
    Dir.mkdir(@component_2_dir)

    git(@component_2_dir) do
      git_init
      git_add_file('Compoundfile') do
        'name :component_2_test'
      end
      git_commit('compoundfile commit')
      git_tag('v0.1', 'version 0.1')
      git_edit_file('Compoundfile') do
        <<-END
          name :component_2

          component :leaf_component_3 do
            version '~>1.0'
            source  '#{@leaf_component_3_dir}'
            destination '/leaf_component_3_destination'
          end

          task :component_2_task do
            $stderr.puts 'component_2_task'
          end

          task :component_2_leaf_component_3_task, :each do |dir|
            $stderr.puts 'leaf_component_3_dir ' + dir
          end
        END
      end
      git_commit('v1.1 commit')
      git_tag('v1.1', 'version 1.1')
      git_edit_file('Compoundfile') do
        <<-END
          name :component_2
        END
      end
      git_commit('v1.2 commit')
      @component_2_commit_tag_v1_2_sha = git_tag('v1.2', 'version 1.2')
    end
  end

  def git_create_base_component
    git_create_component_1
    git_create_component_2

    @base_component_dir = "#{@dir}/base_component.git"
    Dir.mkdir(@base_component_dir)

    @component_1_dst = '/component_1'
    @component_2_dst = '/component_2'

    git(@base_component_dir) do
      git_init
      git_add_file('Compoundfile') do
        <<-END
          name :base_component

          component :component_1 do
            version "~>1.1"
            source '#{@component_1_dir}'
            destination '#{@component_1_dst}'
          end

          component :component_2 do
            version "1.1"
            source '#{@component_2_dir}'
            destination '#{@component_2_dst}'
          end

          task :base_component_second_tasks, :each do |dir, component|
            $stderr.puts "base_component_second_tasks for " + component.name.to_s
          end

          task :base_component_first_task do
            $stderr.puts 'base_component_first_task'
          end
        END
      end
      git_commit('compoundfile commit')
    end
  end
end
# rubocop:enable Metrics/AbcSize
# rubocop:enable Metrics/ModuleLength
# rubocop:enable Metrics/MethodLength
