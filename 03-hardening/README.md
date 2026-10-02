# Evidências — Fase 2 (Hardening + GPOs)

## Política de conta (Default Domain Policy)

**1. Política de senha e bloqueio**
`net accounts` no DC: comprimento mínimo **12**, histórico **24**, bloqueio após **5** tentativas, duração **15 min**. Reaplicada após o reset com `dcgpofix`.

<img width="1913" height="1030" alt="image" src="../imagens/662281622-b414ab64-8866-4286-a644-a24c6e9d6210.png" />


## Auditoria (GPO AUDITORIA)

**2. Eventos de auditoria fluindo**
Security log do DC com **4688 (Process Creation)**, **4624 (Logon)** e **4634 (Logoff)** — a auditoria avançada está gerando os eventos que o SIEM vai consumir na Fase 3.

<img width="1914" height="1031" alt="image" src="../imagens/662281714-fea17a4c-710a-4208-96dd-73a5b8d598d7.png" />

**3. gpresult no DC — AUDITORIA como Winning GPO**
"Include command line in process creation events" com **Winning GPO = AUDITORIA** (não mais "Default Domain Policy").

<img width="1916" height="1031" alt="image" src="../imagens/662281800-2ad07641-0ac1-4927-85c8-20f25c934707.png" />


## Hardening de rede e PowerShell (GPOs por OU)

**4. gpresult no WS-RH01 — GPOs nomeadas aplicadas por OU**
As GPOs **HARDENING-REDE** (LLMNR + SMBv1) e **POWERSHELL-LOG** aplicadas via `OU=Computadores`. Prova o escopo por OU funcionando.

<img width="1914" height="1032" alt="image" src="../imagens/662281961-605c3ef8-397f-44d4-b579-f3cd345d7921.png" />


## Banner de aviso legal (GPO BANNER-LEGAL)

**5. Aviso no logon**
"Acesso restrito a usuários autorizados. Uso monitorado."

<img width="1917" height="1034" alt="image" src="../imagens/662282083-7ba3d338-2711-4495-a7cd-0701cb7b2b62.png" />


## Bloqueio de USB por setor (GPO BLOQUEIO-USB-FINANCEIRO)

**6. GPO vinculada só na OU=Financeiro**
Política de bloqueio de mídia removível escopada **apenas ao Financeiro** — vinculada em `OU=Usuarios/Financeiro`.

<img width="1917" height="1033" alt="image" src="../imagens/662282220-9704c6d9-6eab-41f3-85a1-b576ff6fac93.png" />


**Usuário João Souza setor Financeiro:**
<img width="1918" height="1034" alt="image" src="../imagens/663177976-d8d6d654-5c0b-44d4-858e-10b377061339.png" />

**Usuário Maria Silva setor RH:**

<img width="1917" height="1036" alt="image" src="../imagens/663178656-58d4e083-d2bb-42e7-96ec-b5ac00d7fc53.png" />

---

