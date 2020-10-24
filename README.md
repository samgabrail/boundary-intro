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
boundary connect ssh -target-id ttcp_7LRbqnnjVy -host-id hst_6vtDxXpX5y
```
wireshark filter: `ip.addr == 192.168.1.80`

## Connecting via RDP

This works well with WSL, just make sure you increase the connection count to at [least 2 for rdp to work.](https://discuss.hashicorp.com/t/rdp-to-windows-server-not-connecting/16169). Terraform already takes care of this.

```shell
boundary connect rdp -target-id ttcp_BGvrgRh0XC -host-id hst_UOjKi24taj
```

wireshark filter: `ip.addr == 192.168.1.80`

## Presentation Flow
1. Introduction
2. Slides to Explain Boundary
3. Getting Started and Installation
4. Start Boundary in Dev Mode
5. Run Terraform to Configure it
6. Authenticate to Boundary
7. SSH Connect to Linux Server
8. Wireshark the SSH Connection
9. RDP Connect to Windows Server
10. Wireshark the RDP Connection
11. Conclusion

## References
[Blog Announcement](https://www.hashicorp.com/blog/hashicorp-boundary)
[Armon's Whiteboard](https://youtu.be/tUMe7EsXYBQ)
[Terraform Boundary Provider](https://registry.terraform.io/providers/hashicorp/boundary/latest)
[Getting Started Learn Guide](https://learn.hashicorp.com/tutorials/boundary/getting-started-intro?in=boundary/getting-started)
[Production AWS Reference Architecture](https://github.com/hashicorp/boundary-reference-architecture)
[Production High Availability Architecture](https://www.boundaryproject.io/docs/installing/high-availability)