# Overview

## Run Dev Mode

```shell
boundary dev -api-listen-address=0.0.0.0 -cluster-listen-address=0.0.0.0 -proxy-listen-address=0.0.0.0 -worker-public-address=192.168.1.80
```

## Authenticating to Boundary

Using token none (make sure to unset the BOUNDARY_TOKEN env variable if set):
```shell
# boundary authenticate password -auth-method-id ampw_1234567890 -login-name admin -password "password" -token-name=none
```

Using BOUNDARY_TOKEN env variable:
```shell
export BOUNDARY_ADDR=http://192.168.1.80:9200
boundary authenticate password -auth-method-id=ampw_1234567890 \
      -login-name=admin -password=password \
      -token-name=none -format=json | jq -r ".token" > boundary_token.txt
export BOUNDARY_TOKEN=$(cat boundary_token.txt)
```

## Connecting via SSH

This works well with WSL
```shell
boundary connect ssh -target-id ttcp_MrnNne0v2b -host-id hst_nhqWFGddI7
```
wireshark filter: `ip.addr == 192.168.1.80`

## Connecting via RDP

This works well with WSL, just make sure you increase the connection count to at least 2 for rdp to work.

```shell
boundary connect rdp -target-id ttcp_G0ywIPFD8Z -host-id hst_VI8E6uZUAa
```

wireshark filter: `ip.addr == 192.168.1.7`
