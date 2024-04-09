{
  "pf_enable": true,
  "pf_table": [
    {
      "Name": "tes1",
      "exPort": 11,
      "id": 1,
      "inPort": 111,
      "ipAddr": "192.168.1.1"
    },
    {
      "Name": "tes2",
      "exPort": 12,
      "id": 2,
      "inPort": 112,
      "ipAddr": "192.168.1.2"
    },
    {
      "Name": "tes3",
      "exPort": 13,
      "id": 3,
      "inPort": 113,
      "ipAddr": "192.168.1.3"
    },
    {
      "Name": "tes4",
      "exPort": 14,
      "id": 4,
      "inPort": 114,
      "ipAddr": "192.168.1.4"
    },
    {
      "Name": "tes5",
      "exPort": 15,
      "id": 5,
      "inPort": 115,
      "ipAddr": "192.168.1.5"
    }
  ],
  "pt_enable": true,
  "pt_table": [
    {
      "Enable": true,
      "InBound": "11",
      "SName": "http",
      "SUser": "192.168.1.1",
      "Stype": 1,
      "id": 1
    },
    {
      "Enable": false,
      "InBound": "12",
      "SName": "ftp",
      "SUser": "192.168.1.2",
      "Stype": 2,
      "id": 2
    },
    {
      "Enable": true,
      "InBound": "13",
      "SName": "telnet",
      "SUser": "192.168.1.3",
      "Stype": 3,
      "id": 3
    }
  ]
}
