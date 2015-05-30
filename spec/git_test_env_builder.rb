# Git Test Environment Builder
#
# rubocop:disable Metrics/ModuleLength
# rubocop:disable Metrics/MethodLength
module GitTestEnvBuilder
  def git_build_test_environment!
    git_create_leaf_component_1
    git_create_leaf_component_2
    git_create_dependent_component_1
    git_create_dependent_component_2
    git_create_base_component
  end

  def git_create_leaf_component_1
    @leaf_component_1_dir = "#{@dir}/leaf_component_1.git"
    Dir.mkdir(@leaf_component_1_dir)

    git(@leaf_component_1_dir) do
      git_init
      git_add_file('component') { 'leaf_component_1' }
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

  def git_create_dependent_component_1
    @dependent_component_1_dir = "#{@dir}/dependent_component_1.git"
    Dir.mkdir(@dependent_component_1_dir)

    git(@dependent_component_1_dir) do
      git_init
      git_add_file('.gitcompound') do
        'name :dependent_component_1'
      end
      git_commit('gitcompound commit')
      git_tag('v0.1', 'version 0.1')
      git_add_file('version_1.1') { 'v1.1' }
      git_commit('v1.1 commit')
      git_tag('v1.1', 'version 1.1')
      git_add_file('version_1.2') { 'v1.2' }
      git_edit_file('.gitcompound') do
        <<-END
          name :dependent_component_1

          component :dependent_leaf_1 do
            version '1.0'
            source  '#{@leaf_component_1_dir}'
            destination 'd'
          end

          component :dependent_leaf_2 do
            version '1.0'
            source  '#{@leaf_component_2_dir}'
            destination 'd'
          end
        END
      end
      git_commit('v1.2 commit')
      git_tag('v1.2', 'version 1.2')
    end
  end

  def git_create_dependent_component_2
    @dependent_component_2_dir = "#{@dir}/dependent_component_2.git"
    Dir.mkdir(@dependent_component_2_dir)

    git(@dependent_component_2_dir) do
      git_init
      git_add_file('Compoundfile') do
        'name :dependent_component_2'
      end
      git_commit('compoundfile commit')
      git_tag('v0.1', 'version 0.1')
      git_edit_file('Compoundfile') do
        <<-END
          name :dependent_component_2

          component :dependent_leaf_1_1 do
            version '1.0'
            source  '#{@leaf_component_1_dir}'
            destination 'd'
          end
        END
      end
      git_commit('v1.1 commit')
      git_tag('v1.1', 'version 1.1')
      git_edit_file('Compoundfile') do
        <<-END
          name :dependent_component_2
        END
      end
      git_commit('v1.2 commit')
      git_tag('v1.2', 'version 1.2')
    end
  end

  def git_create_base_component
    @base_component_dir = "#{@dir}/base_component.git"
    Dir.mkdir(@base_component_dir)

    git(@base_component_dir) do
      git_init
      git_add_file('Compoundfile') do
        <<-END
          name :test_component
          component :dependent_component_1 do
            version "~>1.1"
            source '#{@dependent_component_1_dir}'
            destination '#{@dir}/compound/component_1'
          end
          component :dependent_component_2 do
            version "1.1"
            source '#{@dependent_component_2_dir}'
            destination '#{@dir}/compound/component_2'
          end
        END
      end
      git_commit('compoundfile commit')
    end
  end
end
# rubocop:enable Metrics/ModuleLength
# rubocop:enable Metrics/MethodLength