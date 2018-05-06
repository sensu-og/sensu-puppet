require 'spec_helper'
require 'puppet/type/sensu_handler'

describe Puppet::Type.type(:sensu_handler) do
  before(:each) do
    @sensu_handler = described_class.new(
      name: 'test',
      type: 'pipe',
      command: 'test'
    )
  end

  let(:default_config) do
    {
      name: 'test',
      type: 'pipe',
      command: 'test',
    }
  end
  let(:config) do
    default_config
  end
  let(:check) do
    described_class.new(config)
  end

  it 'should add to catalog without raising an error' do
    catalog = Puppet::Resource::Catalog.new
    expect {
      catalog.add_resource @sensu_handler
    }.to_not raise_error
  end

  it 'should require a name' do
    expect {
      described_class.new({})
    }.to raise_error(Puppet::Error, 'Title or name must be provided')
  end

  it 'should not accept invalid name' do
    expect {
      @sensu_handler[:name] = 'foo bar'
    }.to raise_error(Puppet::Error)
  end

  it 'should accept type' do
    @sensu_handler[:type] = 'tcp'
    expect(@sensu_handler[:type]).to eq(:tcp)
  end

  it 'should not accept invalid type' do
    expect {
      @sensu_handler[:type] = 'foo'
    }.to raise_error(Puppet::Error)
  end

  it 'should accept filters' do
    @sensu_handler[:filters] = ['foo', 'bar']
    expect(@sensu_handler[:filters]).to eq(['foo', 'bar'])
  end

  it 'should accept mutator' do
    @sensu_handler[:mutator] = 'foo'
    expect(@sensu_handler[:mutator]).to eq('foo')
  end

  it 'should accept timeout' do
    @sensu_handler[:timeout] = 5
    expect(@sensu_handler[:timeout]).to eq(5)
  end

  it 'should accept timeout string' do
    @sensu_handler[:timeout] = '5'
    expect(@sensu_handler[:timeout]).to eq(5)
  end

  it 'should not accept invalid timeout' do
    expect {
      @sensu_handler[:timeout] = 'foobar'
    }.to raise_error(Puppet::ResourceError, /should be an Integer/)
  end

  it 'should accept command' do
    @sensu_handler[:command] = '/foo/bar'
    expect(@sensu_handler[:command]).to eq('/foo/bar')
  end

  it 'should accept env_vars' do
    @sensu_handler[:env_vars] = ['foo', 'bar']
    expect(@sensu_handler[:env_vars]).to eq(['foo', 'bar'])
  end

  it 'should accept handlers' do
    @sensu_handler[:handlers] = ['foo', 'bar']
    expect(@sensu_handler[:handlers]).to eq(['foo', 'bar'])
  end

  it 'should accept organization' do
    @sensu_handler[:organization] = 'foobar'
    expect(@sensu_handler[:organization]).to eq('foobar')
  end

  it 'should have default environment' do
    expect(@sensu_handler[:environment]).to eq('default')
  end

  it 'should accept environment' do
    @sensu_handler[:environment] = 'foobar'
    expect(@sensu_handler[:environment]).to eq('foobar')
  end

  it 'should accept socket_host' do
    @sensu_handler[:socket_host] = 'foo'
    expect(@sensu_handler[:socket_host]).to eq('foo')
  end

  it 'should accept socket_port' do
    @sensu_handler[:socket_port] = 5
    expect(@sensu_handler[:socket_port]).to eq(5)
  end

  it 'should accept socket_port string' do
    @sensu_handler[:socket_port] = '5'
    expect(@sensu_handler[:socket_port]).to eq(5)
  end

  it 'should not accept invalid socket_port' do
    expect {
      @sensu_handler[:socket_port] = 'foobar'
    }.to raise_error(Puppet::ResourceError, /should be an Integer/)
  end

  it 'should accept custom value' do
    @sensu_handler[:custom] = {'foo' => 'bar'}
    expect(@sensu_handler[:custom]).to eq({'foo' => 'bar'})
  end

  it 'should not accept invalid custom' do
    expect {
      @sensu_handler[:custom] = 'foo'
    }.to raise_error(Puppet::Error)
  end

  it 'should autorequire Package[sensu-cli]' do
    package = Puppet::Type.type(:package).new(:name => 'sensu-cli')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource @sensu_handler
    catalog.add_resource package
    rel = @sensu_handler.autorequire[0]
    expect(rel.source.ref).to eq(package.ref)
    expect(rel.target.ref).to eq(@sensu_handler.ref)
  end

  it 'should autorequire Service[sensu-backend]' do
    service = Puppet::Type.type(:service).new(:name => 'sensu-backend')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource @sensu_handler
    catalog.add_resource service
    rel = @sensu_handler.autorequire[0]
    expect(rel.source.ref).to eq(service.ref)
    expect(rel.target.ref).to eq(@sensu_handler.ref)
  end

  it 'should autorequire Exec[sensuctl_configure]' do
    exec = Puppet::Type.type(:exec).new(:name => 'sensuctl_configure', :command => '/usr/bin/sensuctl')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource @sensu_handler
    catalog.add_resource exec
    rel = @sensu_handler.autorequire[0]
    expect(rel.source.ref).to eq(exec.ref)
    expect(rel.target.ref).to eq(@sensu_handler.ref)
  end

  it 'should autorequire sensu_api_validator' do
    validator = Puppet::Type.type(:sensu_api_validator).new(:name => 'sensu')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource @sensu_handler
    catalog.add_resource validator
    rel = @sensu_handler.autorequire[0]
    expect(rel.source.ref).to eq(validator.ref)
    expect(rel.target.ref).to eq(@sensu_handler.ref)
  end

  [
    :type,
  ].each do |property|
    it "should require property when ensure => present" do
      config.delete(property)
      config[:ensure] = :present
      expect { handler }.to raise_error(Puppet::Error, /You must provide a #{property}/)
    end
  end

  it 'should require command for type pipe' do
    config.delete(:command)
    expect { handler }.to raise_error(Puppet::Error, /command must be defined for type pipe/)
  end

  it 'should require socket_host and socket_port' do
    config.delete(:socket_port)
    expect { handler }.to raise_error(Puppet::Error, /socket_port is required if socket_host is set/)
  end
  it 'should require socket_host and socket_port' do
    config.delete(:socket_host)
    expect { handler }.to raise_error(Puppet::Error, /socket_host is required if socket_port is set/)
  end
  it 'should require socket properties for tcp type' do
    config.delete(:socket_host)
    config.delete(:socket_port)
    config[:type] = :tcp
    expect { handler }.to raise_error(Puppet::Error, /socket_host and socket_port are required for type tcp or type udp/)
  end
  it 'should require socket properties for udp type' do
    config.delete(:socket_host)
    config.delete(:socket_port)
    config[:type] = :udp
    expect { handler }.to raise_error(Puppet::Error, /socket_host and socket_port are required for type tcp or type udp/)
  end
end
