local conf = {}

conf.sample_rate = 48000
conf.inv_sample_rate = 1/conf.sample_rate
conf.operator_count = 32
conf.channel_count = 1 -- untested at other values
conf.modulation_count = conf.operator_count * 2
conf.modulation_output_count = conf.operator_count + conf.channel_count

return conf
