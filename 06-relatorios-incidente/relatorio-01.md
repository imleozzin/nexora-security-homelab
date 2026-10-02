# Relatório de Detecção & Triagem - Nexora Security Lab

## 1. Sumário executivo

Durante a validação da fase de **monitoramento (Blue Team)** do laboratório, dois alertas foram analisados ponta a ponta:

1. **Falso positivo de alta severidade (nível 15)** - um alerta crítico de "arquivo executável criado em pasta usada por malware", disparado por **atividade administrativa legítima** (instalação do Sysmon via PowerShell).
2. **Verdadeiro positivo (nível 5, correlacionado)** - múltiplas **falhas de autenticação (brute force)** contra uma conta de domínio, geradas por um ataque simulado em ambiente controlado.

Ambos foram triados com base em **evidência do SIEM**, demonstrando o ciclo completo de um analista SOC: **detecção → investigação → classificação → recomendação**. O principal aprendizado reforçado: **severidade alta não é sinônimo de ameaça real** - a classificação depende da investigação.

---

## 2. Caso 1 - FALSO POSITIVO
### "Executable file dropped in folder commonly used by malware"

### 2.1 Alerta

| Campo | Valor |
|---|---|
| Regra | **92213** - "Executable file dropped in folder commonly used by malware" |
| Nível | **15 (crítico)** |
| MITRE ATT&CK | **T1105 - Ingress Tool Transfer** (tática: Command and Control) |
| Agente | `SRV-DC01` (192.168.10.10) |
| Canal / Evento | `Microsoft-Windows-Sysmon/Operational` - **EID 11 (File Created)** |
| Grupos da regra | `sysmon`, `sysmon_eid11_detections`, `windows` |
| Timestamp | 2026-09-30 20:22:03 |

### 2.2 Evidência coletada

- **Processo (image):** `C:\WINDOWS\System32\WindowsPowerShell\v1.0\powershell.exe`
- **Arquivo criado (targetFilename):** `C:\Users\Administrator\AppData\Local\Temp\__PSScriptPolicyTest_22gdtgmq.ia4.ps1`
- **Usuário:** `NEXORA\Administrator`

### 2.3 Investigação

O arquivo que disparou o alerta - `__PSScriptPolicyTest_*.ps1` - **não é um artefato de ataque**. É um arquivo temporário que o **próprio PowerShell gera** para testar a *execution policy* antes de rodar um script. É criado de forma rotineira e automática.

A regra 92213 dispara para **qualquer** script/executável criado em `%TEMP%`, porque *staging* em pastas temporárias é um comportamento comum de malware (daí o nível 15). Neste caso, porém:

- O processo criador é o `powershell.exe` **legítimo** do sistema (`System32`).
- A **correlação temporal** bate exatamente com a instalação do Sysmon via PowerShell, feita pelo administrador.
- O nome do arquivo corresponde a um artefato **conhecido e benigno** do PowerShell.

### 2.4 Classificação: **FALSO POSITIVO (benigno)**

Atividade administrativa legítima. **Sem indicadores de comprometimento (IoC).**

### 2.5 Recomendação (tuning)

- Criar uma **exceção** para o padrão `__PSScriptPolicyTest_*.ps1` quando o processo pai for o `powershell.exe` assinado — ou reduzir o nível apenas para esse padrão específico.
- **Não suprimir a regra inteira:** ela continua necessária para detectar *drops* reais de ferramentas em `%TEMP%`. O objetivo do tuning é reduzir ruído sem perder visibilidade.

---

## 3. Caso 2 - VERDADEIRO POSITIVO
### Brute Force / Password Guessing (falhas de autenticação)

### 3.1 Simulação (autorizada - laboratório)

8 tentativas de autenticação com **senha incorreta** contra o compartilhamento `IPC$` do Domain Controller, usando a conta `nexora\joao.souza`, via `net use` em loop - padrão clássico de *password guessing*.

### 3.2 Alerta

| Campo | Valor |
|---|---|
| Regra | **60122** - "Logon Failure - Unknown user or bad password" |
| Nível | **5** |
| firedtimes | **5** (regra reincidente na janela) |
| MITRE (tag da regra) | T1531 - Account Access Removal |
| MITRE (comportamento real) | **T1110 - Brute Force** *(ver nota 3.5)* |
| Agente | `SRV-DC01` (192.168.10.10) |
| Canal / Evento | `Security` - **EID 4625 (An account failed to log on)** |
| Grupos da regra | `windows`, `windows_security`, `authentication_failed` |
| Timestamp | 2026-09-30 20:54:36–38 |

### 3.3 Evidência coletada

- **Conta alvo:** `targetUserName = joao.souza` · `targetDomainName = nexora`
- **Autenticação:** `authenticationPackageName = NTLM` · `logonProcessName = NtLmSsp` · `logonType = 3` (logon de rede)
- **Código de falha:** `status = 0xc000006d` / **`subStatus = 0xc000006a`**
  → `0xc000006a` significa **"senha incorreta"** (a conta **existe**, a senha é que está errada).
- **Origem:** 192.168.10.10 · `ipPort = 56570`

### 3.4 Interpretação

Múltiplos eventos **4625 com `subStatus 0xc000006a`** (senha errada) para o **mesmo usuário** em uma **janela de poucos segundos** = assinatura clássica de **brute force / password guessing**. O fato de ser "bad password" (e não "unknown user") indica que o atacante **conhece um usuário válido** e está tentando adivinhar a senha - um ataque **direcionado**, mais perigoso que varredura aleatória.

### 3.5 Nota analítica — MITRE

A regra 60122 do Wazuh veio marcada como **T1531 (Account Access Removal)**, mas o comportamento observado (várias falhas de senha do mesmo usuário) corresponde tecnicamente a **T1110 - Brute Force**. Essa divergência entre a *tag* da regra e a técnica real é comum e é parte do trabalho do analista reconhecer - a classificação correta orienta a resposta.

### 3.6 Classificação: **VERDADEIRO POSITIVO (ataque simulado, autorizado)**

### 3.7 Resposta recomendada (se fosse um incidente real)

1. **Verificar lockout:** confirmar se a conta foi bloqueada (a GPO da Fase 2 bloqueia após 5 tentativas - ver nota 3.8).
2. **Checar sucesso pós-falha:** procurar um **4624 (logon com sucesso)** do mesmo usuário logo após as falhas - indicaria brute force **bem-sucedido**.
3. **Investigar a origem** das tentativas; isolar o host se for externo/comprometido.
4. **Revisar política de senha** e avaliar **MFA** para contas sensíveis.

### 3.8 Nota de arquitetura - Defesa em profundidade

A **GPO de bloqueio de conta** configurada na Fase 2 (bloqueio após 5 tentativas) **mitiga** este ataque: a conta seria travada antes de muitas tentativas. Isso demonstra as duas camadas trabalhando juntas:
- **Prevenção** → GPO de lockout (impede)
- **Detecção** → SIEM/Wazuh (enxerga e alerta)

---

## 4. Mapeamento de conformidade (gerado automaticamente pelo Wazuh)

O alerta de falha de autenticação já veio mapeado para múltiplos frameworks - útil para auditoria:

| Framework | Controle |
|---|---|
| PCI-DSS | 10.2.4, 10.2.5 |
| HIPAA | 164.312.b |
| NIST 800-53 | AU.14, AC.7 |
| GDPR | IV_35.7.d, IV_32.2 |

---

## 5. Metodologia e lição aprendida

> **"Severidade alta não é ameaça - é um pedido de investigação."**

O ciclo aplicado nos dois casos foi idêntico e replicável:

1. **Detectar** o alerta no SIEM.
2. **Coletar evidência:** processo, arquivo, usuário, códigos de status, contexto temporal.
3. **Correlacionar** com atividade conhecida do ambiente.
4. **Classificar:** falso positivo × verdadeiro positivo.
5. **Recomendar:** tuning (para FP) ou resposta ao incidente (para TP).

Separar o falso positivo do verdadeiro positivo - e saber **justificar com evidência** - é o trabalho central de um analista de SOC/Blue Team.

---

## 6. Competências demonstradas

- Operação de **SIEM (Wazuh)**: busca, filtros, análise de eventos.
- Telemetria com **Sysmon** e eventos nativos do Windows (Security channel).
- Leitura de **Event IDs** (4625, Sysmon EID 11) e **status codes** NTLM (`0xc000006a`).
- **Triagem de alertas** e distinção FP × TP com base em evidência.
- **MITRE ATT&CK** (T1105, T1110) e mapeamento de conformidade (PCI, HIPAA, NIST, GDPR).
- Noção de **defesa em profundidade** (GPO de lockout + detecção no SIEM).

---

## 7. Apêndice - Queries utilizadas (Wazuh Discover / Threat Hunting)

```text
# Todos os eventos do Sysmon
data.win.system.providerName:Microsoft-Windows-Sysmon

# Alertas críticos (nível 15)
rule.level:15

# Falhas de autenticação (brute force)
data.win.system.eventID:4625

# Alertas altos em geral
rule.level >= 12
```

---

*Documento produzido como parte do portfólio do Nexora Security Lab. Todas as ações ofensivas foram executadas pelo proprietário do laboratório, em ambiente isolado e autorizado.*
