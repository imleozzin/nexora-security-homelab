# Nexora Security Lab 🛡️

> Laboratório de segurança defensiva (Blue Team / SOC) simulando o ambiente corporativo de uma empresa fictícia, do zero: rede segmentada, Active Directory, hardening, monitoramento com SIEM, simulação de ataques e resposta a incidentes.

<img width="1538" height="579" alt="Arquitetura do Nexora Security Lab" src="imagens/662212872-902cf168-0234-4ca0-9c58-15838443f288.png" />

---

## 📖 A História (Contexto do projeto)

A **Nexora Logística Ltda** é uma empresa fictícia de logística com aproximadamente 40 funcionários. Após uma **tentativa de phishing**, a diretoria pediu à equipe de TI visibilidade de segurança: segmentação de rede, hardening do Active Directory e monitoramento centralizado capaz de detectar ataques.

Este repositório documenta a construção desse ambiente ponta a ponta — **construir → proteger → monitorar → atacar → detectar → responder** — com foco em demonstrar competências reais de um Analista de SOC / Blue Team Júnior.

> ⚠️ **Escopo e ética:** todos os ataques deste laboratório são executados exclusivamente contra máquinas do próprio ambiente, em rede isolada, sem acesso à internet a partir da zona de ataque. Nenhum sistema de terceiros é alvo.

---

## 🎯 Competências no projeto

| Área | O que este projeto prova |
|---|---|
| Redes | Segmentação em zonas, firewall (pfSense), roteamento entre redes, DHCP relay, regras de menor privilégio |
| Active Directory | Promoção de Domain Controller, estrutura de OUs, usuários/grupos, DNS, GPOs de hardening |
| Windows | Auditoria avançada, Event IDs, PowerShell, hardening de estações |
| Linux | Servidor de arquivos, coleta de logs, agente de monitoramento |
| SOC / Blue Team | SIEM (Wazuh), Sysmon, detecção de ataques, correlação de eventos, caça a ameaças |
| Resposta a incidentes | Relatórios estruturados: timeline, evidências, contenção, lições aprendidas |
| Documentação | Registro de todas as provas e passos do projeto |

---

## 🗺️ Arquitetura

Firewall **pfSense** no centro, roteando entre 4 zonas internas + WAN. Cada zona é uma rede virtual isolada no VMware.

| Zona | Sub-rede | Gateway | Hosts |
|---|---|---|---|
| WAN | DHCP (NAT VMware) | — | FW01 (saída p/ internet) |
| Servidores | 192.168.10.0/24 | .1 | SRV-DC01 (.10) |
| Usuários | 192.168.20.0/24 | .1 | WS-RH01, WS-FIN01 (via DHCP) |
| Segurança | 192.168.30.0/24 | .1 | SRV-SIEM (.50) |
| Ataque | 192.168.99.0/24 | .1 | KALI01 (.50) — **isolada, sem internet** |

---

## 🧰 Stack

`VMware Workstation` · `pfSense CE` · `Windows Server 2025` · `Windows 11` · `Ubuntu Server 24.04` · `Wazuh` · `Sysmon` · `Kali Linux` · `PowerShell`

<div align="left">
  <img width="40" height="40" alt="VMware" src="imagens/662231181-a209e356-ea08-464d-b764-70d0b738163f.png" />&nbsp;&nbsp;
  <img width="40" height="40" alt="pfSense" src="imagens/662235542-67f24f3e-c8d4-4634-862a-ca8f81533d46.png" />&nbsp;&nbsp;
  <img width="40" height="40" alt="Windows" src="imagens/662236667-e80c401e-05f5-4c14-aa6c-068d1158dab6.png" />&nbsp;&nbsp;
  <img width="40" height="40" alt="Linux" src="imagens/662237278-d195b36e-f531-482d-9e01-1ba7de2a18d6%20%281%29.png" />&nbsp;&nbsp;
  <img width="40" height="40" alt="Wazuh" src="imagens/662237773-c05f7ef0-101d-4dac-ae54-af964a48a9ec.png" />&nbsp;&nbsp;
  <img width="40" height="40" alt="Sysmon" src="imagens/662238523-e6683128-8597-49c8-b433-b60cd71c5e2b.png" />&nbsp;&nbsp;
  <img width="40" height="40" alt="Kali Linux" src="imagens/662239001-55d3cd06-5f37-4db0-8dca-a96cb4ed1fa3.png" />
</div>

---

## 📂 Estrutura do repositório

```
nexora-homelab/
├── readme.md                    ← você está aqui
├── 01-arquitetura/              ← rede, IPs, diagrama, decisões de arquitetura
├── 02-active-directory/         ← passo a passo do AD + scripts PowerShell
├── 03-hardening/                ← GPOs e endurecimento
├── 04-monitoramento/            ← Wazuh, Sysmon, coleta de logs
├── 05-cenarios-ataque/          ← simulações de ataque e detecções (MITRE ATT&CK)
├── 06-relatorios-incidente/     ← relatórios por incidente
└── 07-licoes-aprendidas/        ← troubleshooting e lições aprendidas
```

---

## 👤 Autor

**Leonardo Ramalho** — Analista de TI | Cybersecurity (Blue Team / SOC).

[LinkedIn](https://www.linkedin.com/in/leonardo-ramalho-) · [GitHub](https://github.com/imleozzin)


