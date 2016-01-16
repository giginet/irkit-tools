require 'irkit'
require 'json'
require 'args_parser'

args = ArgsParser.parse ARGV do
  arg :signal, "signal name"
  arg :device, "device name"
end

if args.has_param? :device
  unless info = IRKit::App::Data["Device"][args[:device]]
    STDERR.puts %Q{Device "#{args[:device]}" not found}
    exit 1
  end
  clientkey = info.clientkey
  deviceid = info.deviceid
  irkit = IRKit::InternetAPI.new(clientkey: clientkey, deviceid: deviceid)
else
  irkit = IRKit::Device.find.first
  unless irkit
    STDERR.puts 'device not found'
    exit 1
  end
  token = irkit.get_token
  res = irkit.get_key_and_deviceid(token)
  clientkey = res.clientkey
  deviceid = res.deviceid
end


if args.has_param? :signal
  unless remote = IRKit::App::Data["IR"][args[:signal]]
    STDERR.puts "IR signal #{args[:signal]} not found"
    exit 1
  end
else 
  STDERR.puts "--signal is required"
  exit 1
end

info = {clientkey: clientkey, deviceid: deviceid, message:remote.to_json}
params = info.map { |k, v| "#{k}=#{v}" }.join('&')

puts params
