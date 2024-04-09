{
  "bridgePort": [
    {
      "Enable": true,
      "id": 1,
      "type": "wired"
    },
    {
      "Enable": false,
      "id": 2,
      "type": "wired"
    },
    {
      "Enable": true,
      "id": 3,
      "type": "wired"
    },
    {
      "Enable": true,
      "id": 1,
      "type": "wireless"
    },
    {
      "Enable": true,
      "id": 2,
      "type": "wireless"
    }
  ],
  "lan_portcount": 4,
  "vlan_enable": true,
  "vlan_group": [
    {
      "Enable": true,
      "Name": "vlan_10",
      "Priority": 8,
      "action": "active",
      "vlan_id": 10,
      "wieredPort": "1,2",
      "wierelessBnad": "1"
    },
    {
      "Enable": true,
      "Name": "vlan_100",
      "Priority": 7,
      "action": "active",
      "vlan_id": 100,
      "wieredPort": "3,4",
      "wierelessBnad": "2"
    }
  ],
  "vlan_mode": "bridge",
  "wirebandCount": 2
}
