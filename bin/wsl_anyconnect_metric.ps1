# =============================================================================
# https://aquasoftware.net/blog/?p=1472
# https://qiita.com/hisato_imanishi/items/0358e093cc6714b571dc
# https://gist.github.com/nfekete/7a277bf9e25e89e1c8bfb8b64dcc08ed
# https://zenn.dev/hashiba/articles/wls2-on-cisco-anyconnect
# https://github.com/microsoft/WSL/issues/4277#issuecomment-779141250
# =============================================================================
# # define function
# function Get-NetworkAddress ([Parameter(Mandatory, ValueFromPipelineByPropertyName)][string]$IPAddress, [Parameter(Mandatory, ValueFromPipelineByPropertyName)][int]$PrefixLength) {
#     process {
#         [pscustomobject]@{
#             Addr = $IPAddress;
#             Prfx = $PrefixLength;
#             NwAddr = [ipaddress]::Parse($IPAddress).Address -band [uint64][BitConverter]::ToUInt32([System.Linq.Enumerable]::Reverse([BitConverter]::GetBytes([uint32](0xFFFFFFFFL -shl (32 - $PrefixLength) -band 0xFFFFFFFFL))), 0);
#         };
#     }
# }
# # extend route metric
# $targets = Get-NetAdapter | Where-Object InterfaceDescription -Match 'Hyper-V Virtual Ethernet Adapter' | Get-NetIPAddress -AddressFamily IPv4 | Get-NetworkAddress;
# Get-NetAdapter | Where-Object InterfaceDescription -Match 'Cisco AnyConnect' | Get-NetRoute -AddressFamily IPv4 | Select-Object -PipelineVariable rt | Where-Object { $targets | Where-Object { $_.NwAddr -eq (Get-NetworkAddress $rt.DestinationPrefix.Split('/')[0] $_.Prfx).NwAddr } } | Set-NetRoute -RouteMetric 60000;
#
#Get-DnsClientServerAddress -AddressFamily ipv4 | Select-Object -ExpandProperty ServerAddresses
#
#
Get-NetAdapter | Where-Object {$_.InterfaceDescription -Match "Cisco AnyConnect"} | Set-NetIPInterface -InterfaceMetric 6000;
