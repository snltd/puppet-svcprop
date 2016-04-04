Puppet::Type.type(:svcprop).provide(:solaris) do
  desc 'Solaris svcprop provider'
  defaultfor operatingsystem: :solaris

  commands svccfg:  '/usr/sbin/svccfg'
  commands svcprop: '/usr/bin/svcprop'
  commands svcadm:  '/usr/sbin/svcadm'

  attr_reader :resource

  def prep(val, type = 'astring', bracketify = false)
    #
    # svccfg is typed, and it's picky about syntax. For instance,
    # astrings should be quoted, but net_addresses must not. Multiples
    # seem to want grouping in brackets, but I'm not sure that is
    # absolutely always the case, so I've left it kind of to the
    # user to decide, as it may need tweaking in the future.
    #
    if val.is_a?(Array)
      val.map!{ |v| '"' + v + '"' } if type == 'astring'
      val = val.join(' ')
      bracketify = true
    else
      val = "\"#{val}\"" if type == 'astring'
    end

    bracketify ? "(#{val})" : val
  end

  def create
    # Set a default type of 'astring'. The user can override this.
    #
    @resource[:type] ||= 'astring'

    svccfg('-s', resource[:fmri], 'setprop', resource[:property],
           '=', "#{resource[:type]}:", prep(resource[:value],
           resource[:type]))

    svcadm('refresh', resource[:fmri])
  end

  def destroy
    fail ArgumentError, 'cannot destroy a property'
  end

  def exists?
    begin
      current = svcprop('-p', resource[:property], resource[:fmri]).strip
    rescue
      return false
    end

    current = current.split if resource[:value].is_a?(Array)
    current == resource[:value]
  end

  def validate
    fail ArgumentError, 'missing FMRI' if resource[:fmri].empty?
    fail ArgumentError, 'missing property' if resource[:property].empty?
    fail ArgumentError, 'missing value' if resource[:value].empty?
  end
end
