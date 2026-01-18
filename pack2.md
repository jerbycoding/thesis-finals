# Content Pack 2: Advanced Threats

This pack leverages the new mechanics (`trace`, `Network Map`, `Decryption`) to introduce complex, multi-stage threats that require more than just looking at a log file.

## 🎫 New Tickets

| ID | Title | Severity | Tool | Mechanics Used |
| :--- | :--- | :--- | :--- | :--- |
| `DDOS-MITIGATION-001` | **DDoS Attack in Progress** | 🔴 Critical | Terminal | Requires `trace` to find internal compromised host, then `isolate`. |
| `CRYPTOMINER-HUNT-001` | **High CPU Anomaly** | 🟠 High | TaskMgr | Requires checking Task Manager for spikes, then using Terminal to scan suspect hosts. |
| `VPN-ANOMALY-001` | **Impossible Travel Alert** | 🟠 High | SIEM | "Login from NY, then Tokyo 5 mins later." Requires analyzing IPs. |

## 📋 Supporting Logs

| ID | Source | Message | Related Ticket |
| :--- | :--- | :--- | :--- |
| `LOG-DDOS-001` | Firewall | **High inbound traffic volume detected (UDP Flood).** | `DDOS-MITIGATION-001` |
| `LOG-DDOS-002` | IDS | **Internal host WORKSTATION-15 sending anomalous outbound UDP.** | `DDOS-MITIGATION-001` |
| `LOG-MINER-001` | SysMon | **Process 'xmr-stak.exe' utilizing 95% CPU.** | `CRYPTOMINER-HUNT-001` |
| `LOG-MINER-002` | Network | **Connection established to mining pool 'stratum+tcp://xmr.pool.com'.** | `CRYPTOMINER-HUNT-001` |
| `LOG-VPN-001` | VPN-Gateway | **User 'j.doe' connected from IP 45.33.22.11 (New York, US).** | `VPN-ANOMALY-001` |
| `LOG-VPN-002` | VPN-Gateway | **User 'j.doe' connected from IP 103.20.15.1 (Tokyo, JP).** | `VPN-ANOMALY-001` |

## 📧 Supporting Emails

| ID | Sender | Subject | Related Ticket |
| :--- | :--- | :--- | :--- |
| `EMAIL-SLOW-NET` | Users | Internet is super slow? | `DDOS-MITIGATION-001` |
| `EMAIL-LOUD-FAN` | User | My computer fan is really loud | `CRYPTOMINER-HUNT-001` |
