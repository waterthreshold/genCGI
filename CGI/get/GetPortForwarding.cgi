{
  "lan_ip": "192.168.1.1",
  "pf_enable": true,
  "pf_table": [
    {
      "id": 1,
      "Name": "tes1",
      "exPort": 11,
      "inPort": 111,
      "ipAddr": "192.168.1.1"
    },
    {
      "id": 2,
      "Name": "tes2",
      "exPort": 12,
      "inPort": 112,
      "ipAddr": "192.168.1.2"
    },
    {
      "id": 3,
      "Name": "tes3",
      "exPort": 13,
      "inPort": 113,
      "ipAddr": "192.168.1.3"
    },
    {
      "id": 4,
      "Name": "tes4",
      "exPort": 14,
      "inPort": 114,
      "ipAddr": "192.168.1.4"
    },
    {
      "id": 5,
      "Name": "tes5",
      "exPort": 15,
      "inPort": 115,
      "ipAddr": "192.168.1.5"
    }
  ],
  "pt_enable": true,
  "pt_table": [
    {
      "id": 1,
      "Enable": true,
      "SName": "http",
      "SType": "",
      "InBound": "11",
      "SUser": "192.168.1.1"
    },
    {
      "id": 2,
      "Enable": true,
      "SName": "ftp",
      "SType": "",
      "InBound": "12",
      "SUser": "192.168.1.2"
    },
    {
      "id": 3,
      "Enable": true,
      "SName": "telnet",
      "SType": "",
      "InBound": "13",
      "SUser": "192.168.1.3"
    }
  ]
}
