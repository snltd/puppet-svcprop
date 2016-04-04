Puppet::Type.newtype(:svcprop) do
    @doc = 'Manage Solaris SMF properties'
    attr_reader :resource

    ensurable do
      defaultvalues
      defaultto :present

      def change_to_s(oldstate, newstate)
        if oldstate == :absent && newstate == :present
          return "set #{resource[:property]} = #{resource[:value]}"
        end
      end
    end

    newparam(:name) do
      desc 'mnemonic name'
      isnamevar
    end

    newparam(:fmri) do
      desc 'FMRI of service'
    end

    newparam(:property) do
      desc 'name of property'
    end

    newparam(:value) do
      desc 'desired value(s) of property'
    end

    newparam(:type) do
      desc 'type of property'
    end

    def validate
      provider.validate if provider.respond_to?(:validate)
    end
end
