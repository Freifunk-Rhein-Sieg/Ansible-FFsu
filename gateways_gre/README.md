## Tunnel für das Routing von den Domänen zum ffsu Backbone

### Rollen
Es gibt zwei Rollen, die die Tunnel zwischen den Gateways der einzelnen Domänen und dem ffsu Backbone aufbauen.

- ``interfaces_ffsu_backbone``
- ``gateways_gre`` (diese Rolle)

Die Rolle ``interfaces_ffsu_backbone`` muss auf den Backbone Servern ausgeführt werden. Die Rolle ``gateways_gre`` muss auf den Gateway-Servern der jeweiligen Domäne ausgeführt werden.

### Konfiguration
Die Konfiguration findet ausschließlich in den ``host_vars`` statt.
Die Konfiguration sieht exemplarisch wie folgt aus:

```
ffsu_tun_to:
- host_name: fgw01
- host_name: fgw02
- ...
```

#### Hinweise

- ``host_name`` bezeichnet nicht den Hostnamen, der auf dem Server konfiguriert ist, sondern den Hostnamen der in Ansible in der ``hosts`` Datei steht.
- Der Backbone-Server muss in der Ansible-Gruppe ``backbone`` sein, damit das Template funktioniert. Falls mehr Flexibilität erfoderlich sein sollte, müsste das noch angepasst werden.
- Das zum Routing erforderliche Netz wird wie folgt berechnet: ``192.168.[BB-VM-ID].[GW-VM-ID*4]/30`` Wobei die erste verfügbare Adresse die des Backbone-Servers (+1) ist und die zweite verfügbare Adresse (+2) die des Gateway-Servers in der Domäne ist.
