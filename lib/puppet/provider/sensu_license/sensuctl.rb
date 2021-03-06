require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensuctl'))

Puppet::Type.type(:sensu_license).provide(:sensuctl, :parent => Puppet::Provider::Sensuctl) do
  desc "Provider sensu_license using sensuctl"

  def exists?
    sensuctl(['license', 'info'])
  rescue Puppet::ExecutionFailure => e
    return false
  true
  end

  def initialize(value = {})
    super(value)
    @property_flush = {}
  end

  def create
    begin
      sensuctl(['create','-f',resource[:file]])
    rescue Puppet::ExecutionFailure => e
      raise Puppet::Error, "sensuctl create failed\nOutput: #{output}\nError message: #{e.message}"
    end
  end

  def destroy
    begin
      sensuctl(['delete','-f',resource[:file]])
    rescue Puppet::ExecutionFailure => e
      raise Puppet::Error, "sensuctl create failed\nOutput: #{output}\nError message: #{e.message}"
    end
  end
end

