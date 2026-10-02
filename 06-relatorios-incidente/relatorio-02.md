# Relatório de Incidente 02 - Tentativa de Persistência Remota (NTLM / wmiexec)

## 1. Sumário executivo
Foi detectada, a partir do host `192.168.99.50` (zona ATAQUE), uma **autenticação remota NTLM bem-sucedida** com a conta `Administrator`, seguida de tentativa de **execução remota (wmiexec)** para criar um usuário backdoor e elevá-lo a Domain Admin. O **Wazuh detectou** o logon remoto suspeito (regra **92652 - possible pass-the-hash**) e o **Windows Defender bloqueou** a criação do backdoor. **Nenhuma persistência foi estabelecida.** Impacto real: **nenhum** (contido). Severidade atribuída: **Alta** (comprometimento de credencial de Domain Admin).

## 2. Linha do tempo (UTC-3)
| Hora | Evento |
|---|---|
| ~23:15 | Autenticações NTLM remotas como `Administrator` a partir de `192.168.99.50` → **rule 92652** (nível 6) no Wazuh |
| ~23:15 | netexec reporta `Pwn3d!` (autenticação válida como DA) e tenta `net user hacker_remoto /add` via wmiexec |
| ~23:15 | netexec: *"Could not retrieve output file, it may have been detected by AV"* |
| (verificação) | No DC, `net user hacker_remoto` → **"não encontrado"** → criação **bloqueada pelo Defender** |

## 3. Detecção
- **Regra:** `92652` - *"Successful Remote Logon Detected – User:\Administrator - NTLM authentication, possible pass-the-hash attack"* (nível 6).
- **Caça / pivot:** filtro por **IP de origem** `data.win.eventdata.ipAddress:192.168.99.50` isolou **22 eventos** vindos exclusivamente da Kali - separando o atacante do tráfego legítimo.
- **Observação técnica:** `agent.ip` aponta o DC (`192.168.10.10`); a **origem real** do ataque está em `data.win.eventdata.ipAddress`. Confundir os dois leva a conclusão errada.

## 4. Análise (MITRE ATT&CK)
- **T1021.002 / T1047** - Remote Services (SMB/Admin$) + WMI para execução remota.
- **T1078** — uso de conta válida (Administrator).
- **T1136.001 / T1098** - tentativa de criar conta e manipular grupo (Domain Admins).
- Indício de **pass-the-hash / NTLM relay** sinalizado pela própria regra 92652.

## 5. Impacto
- **Confidencialidade/Integridade/Disponibilidade:** sem impacto efetivo - a execução maliciosa foi bloqueada antes de criar o artefato.
- **Exposição identificada:** a credencial de `Administrator` foi usada com sucesso para autenticar remotamente → **a senha deve ser considerada comprometida**.

## 6. Resposta e contenção
1. **Prevenção automática:** Windows Defender barrou a criação do backdoor (EDR funcionando).
2. **Detecção:** alerta 92652 disponível para triagem no SIEM.
3. **Ação recomendada imediata:** **trocar a senha do `Administrator`** e revisar logons recentes dessa conta.
4. **Validação:** confirmar que nenhum usuário/serviço não planejado existe no domínio (`Get-ADUser -Filter *`, revisão de Domain Admins).

## 7. Recomendações (hardening / defesa em profundidade)
- **Reduzir superfície NTLM:** priorizar Kerberos; auditar/limitar NTLM (políticas "Network security: Restrict NTLM").
- **Contas administrativas:** contas dedicadas por função, **LAPS** para senhas locais, e **Protected Users** / Tier model para DAs.
- **Segmentação:** manter o DC inacessível a zonas não confiáveis (a regra temporária `ATAQUE → any` deve ser **removida** após o lab).
- **Monitoramento contínuo:** alertar em tempo real para 92652 e para 4720/4728 (criação de conta / Domain Admins).

## 8. Lições aprendidas
- Uma credencial de admin válida transforma "acesso" em **comprometimento de domínio** - o elo mais fraco não foi técnico, foi o **segredo exposto**.
- **Detecção e prevenção são camadas distintas:** aqui o Defender preveniu e o Wazuh detectou - as duas coisas precisam existir.
- **Caçar por IP de origem** é a diferença entre "vi um monte de logon" e "isolei o atacante".

---
