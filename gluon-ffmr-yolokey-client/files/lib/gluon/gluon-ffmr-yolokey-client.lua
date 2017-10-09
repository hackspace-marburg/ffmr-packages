#!/usr/bin/lua

local uci = require('simple-uci').cursor()
local util = require('gluon.util')

local uci_section = 'yolokey_' .. string.gsub(os.getenv('INTERFACE'), '-', '_')
local last_log

local function log(level, str)  -- FIXME: call syslog()
    os.execute(
        string.format('logger -p daemon.%s -t yolokey-client "%s"', level, str)
    )
    last_log = level .. ': ' .. str
end

if uci:get_bool('fastd', uci_section, 'key_uploaded') then  -- save some resources
    log(
        'info',
        'Yolokey has already uploaded a key for this interface. ' ..
        'Reset with # uci set fastd.' .. uci_section .. '.key_uploaded=0'
    )
    os.exit(0)
end


local function run(cmd)
    local f = assert(io.popen(cmd, 'r'))
    local s = assert(f:read('*a'))
    f:close()
    return s
end

local function upload_key(peer_address, hostname, local_key)
    local url = string.format(
        'http://%s/yolokey/add/%s/%s',
        peer_address, hostname, local_key
    )
    local ret = run(
        string.format('wget -T 120 -O - "%s" 2>&1', url)
    )

    if string.find(ret, 'HTTP error 409') then
        log(
            'warn',
            string.format('Key does already exist. Details: %s.', url)
        )
        return true
    elseif string.find(ret, 'Download completed') then
        log(
            'info',
            string.format(
                'Successfully uploaded %s for %s.', local_key, hostname)
        )
        return true
    end

    log(
        'error',
        string.format('Error uploading key by accessing %s.', url)
    )
    return false
end

local upload_successful = upload_key(
    os.getenv('PEER_ADDRESS'),
    uci:get_first('system', 'system', 'hostname') .. '__' .. util.node_id(),
    os.getenv('LOCAL_KEY')
)

uci:section('fastd', 'yolokey', uci_section,
    {
        key_uploaded = (upload_successful and '1' or '0'),
        status = last_log
    }
)
uci:save('fastd')
uci:commit('fastd')
