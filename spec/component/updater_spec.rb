
# GitCompound
#
module GitCompound
  describe Component do
    before do
      git_create_component_2

      # Build component first
      #
      component_dir = @component_2_dir
      @component_old = Component.new(:component_2) do
        version '0.1'
        source component_dir
        destination '/component_2_destination'
      end
      @component_old.build

      # Change source repository of component
      #
      git(@component_2_dir) do
        git_add_file('new_update_file') { 'new_file_contents' }
        git_commit('2.0 commit')
        git_tag('2.0', 'version 2.0')
      end

      # Update component
      #
      @component_new = Component.new(:component_2) do
        version '2.0'
        source component_dir
        destination '/component_2_destination'
      end
      @component_new.update

      @destination = "#{@dir}/#{@component_new.destination_path}"
    end

    it 'should checkout new ref' do
      expect(File.read(@destination + 'new_update_file'))
        .to eq "new_file_contents\n"
    end
  end
end