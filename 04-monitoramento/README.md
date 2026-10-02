# Evidências — Fase 3 (Monitorar: Wazuh + Sysmon)

## 1. IP estático do SIEM
`SRV-SIEM01` com IP fixo **`192.168.30.50/24`** aplicado via **systemd-networkd** (não DHCP) e persistente após reboot — requisito de um SIEM (os agentes apontam para um IP fixo).

<img width="853" height="191" alt="image" src="../imagens/663182414-b957e97f-3693-432c-8158-2f0eb4f9e8b0.png" />

## 2. Agente Wazuh ativo no Domain Controller
Agente registrado e **`active`** no `SRV-DC01` (Windows Server 2025). É o pipeline endpoint → agente → SIEM funcionando.

<img width="1916" height="1036" alt="image" src="../imagens/663182479-d307dfbd-a616-4a0a-8c8a-7da81fe63875.png" />

## 3. Painel Wazuh operacional
Dashboard do Wazuh de pé, acessível por `https://192.168.30.50`.

<img width="1918" height="1034" alt="image" src="../imagens/663182623-46ab720d-3a45-481b-b9ae-ded6e6950cd7.png" />

## 4. Sysmon alimentando o SIEM
Após instalar o **Sysmon** (config SwiftOnSecurity) no DC e apontar o agente para o canal `Microsoft-Windows-Sysmon/Operational`: **72 eventos** coletados e **5 técnicas MITRE ATT&CK** já visíveis (Ingress Tool Transfer, PowerShell, File Deletion, Account Discovery, Windows Command Shell).

<img width="1916" height="1032" alt="image" src="../imagens/663182693-c60cd54a-a18d-4211-94b9-02bce7911813.png" />

---

**Competências demonstradas:** deploy de SIEM (Wazuh), configuração de rede estática em Linux (systemd-networkd), enrollment de agente, integração do Sysmon via `localfile`/`eventchannel`, leitura de telemetria mapeada ao MITRE ATT&CK.
