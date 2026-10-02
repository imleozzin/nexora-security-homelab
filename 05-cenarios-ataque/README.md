# Evidências — Fase 4 (Atacar e Detectar)

## 🏆 Defesa em profundidade comprovada
Três ataques contidos por **três camadas diferentes**, os que passaram foram **detectados**:
- **Brute force** → bloqueado pela **GPO de lockout** (4740) + detectado (4625)
- **Responder (LLMNR)** → bloqueado pela **segmentação de rede** (pfSense)
- **Persistência remota** → **detectada** (NTLM/pass-the-hash, rule 92652) **e** bloqueada pelo **Windows Defender**

---

## Triagem — Falso Positivo (T1105)
Alerta nível 15 investigado até a causa raiz: `PSScriptPolicyTest` do próprio Windows = **falso positivo**.
- `01-alerta-nivel15-visao-geral.png`
- `02-fp-detalhe-eid11.png`
- `03-fp-rule92213-t1105.png`

## Ataque 1 — Reconhecimento / Nmap (T1046)
Scan do DC: portas de AD expostas (53, 88, 135/139/445, 389/636/3268, 5985) e o domínio `nexora.local` vazando via LDAP.

<img width="1914" height="1038" alt="image" src="../imagens/663133939-f495e799-7f40-4369-b5e0-31b5e4cfab46.png" />


## Ataque 2 — Brute force (T1110): detectado + bloqueado
`4625` em massa (rule 60122) e a conta travada pela **GPO de lockout** → `4740` (rule 60115).

<img width="1918" height="1035" alt="image" src="../imagens/663134039-a42d35e5-a738-44a3-8379-e9c660b8fbd6.png" />

<img width="1916" height="1037" alt="image" src="../imagens/663134352-23147cb2-29da-4ea4-b8d5-c9af798f45c9.png" />

<img width="1914" height="1035" alt="image" src="../imagens/663134908-b4369ecf-67e9-4f2c-a1ef-bd483e1f7e9c.png" />

> Detectado (SIEM) **e** bloqueado (GPO) no mesmo evento detecção + prevenção juntas.

## Ataque 3 — Password spraying (T1110.003)
Mesma descrição ("Logon Failure"), **ataque diferente**: o campo `data.win.eventdata.targetUserName` mostra **usuários variados** (1 tentativa cada), evitando o lockout.

<img width="1916" height="1034" alt="image" src="../imagens/663135065-6d57a1e4-7aa3-48a1-9aa0-23369bafe410.png" />

<img width="1915" height="1032" alt="image" src="../imagens/663135202-2cdb0eba-d236-4276-bb31-0caaa45f0b2f.png" />

> Saber ler o `targetUserName` é o que distingue brute force (1 usuário, N senhas) de spraying (N usuários, 1 senha).

## Ataque 4 — Persistência local: admin backdoor (T1136/T1098)
Criação de usuário + elevação a Domain Admin (cenário *assumed breach*), detectados pelo SIEM.

<img width="1916" height="1035" alt="image" src="../imagens/663135332-08b49ef6-87b4-4430-a43b-f285f5b6e225.png" />

<img width="1915" height="1038" alt="image" src="../imagens/663135424-544c792a-2b7b-487e-aab6-825bb0663b9f.png" />

<img width="1914" height="1035" alt="image" src="../imagens/663135540-4fd888a7-c6ba-4af2-bcaf-a5acac8f0d1f.png" />

> Novo Domain Admin não planejado = bandeira vermelha nº 1 de invasão.

### Limpeza (higiene de laboratório)
O artefato foi **removido** após a evidência — o lab não fica com backdoor ativo.

<img width="1915" height="1036" alt="image" src="../imagens/663135684-2027037c-e4fd-4be2-af5a-37756d5d3fac.png" />


## Ataque 5 — Responder / LLMNR Poisoning → BLOQUEADO pela segmentação (T1557.001)
O Responder ficou escutando na zona ATAQUE, mas o broadcast (LLMNR/NBT-NS) do WS-RH01 **não cruza sub-redes** (pfSense). Nada capturado = defesa funcionando.

<img width="1916" height="1032" alt="image" src="../imagens/663135778-81ba0a26-7bf3-41d5-8a5d-2027ef0525e0.png" />

<img width="1910" height="1035" alt="image" src="../imagens/663135908-201ee639-0c89-44b8-bd12-982e4e946365.png" />


## Ataque 6 — Persistência REMOTA (wmiexec) → DETECTADA + BLOQUEADA (T1136/T1021/T1047)
Autenticou como DA (`Pwn3d!`), **mas**: (a) o **Wazuh detectou** o logon remoto NTLM — rule **92652** "possible pass-the-hash" — e (b) o **Windows Defender** barrou a criação do backdoor (netexec: *"may have been detected by AV"*).

<img width="1917" height="1032" alt="image" src="../imagens/663136062-d9069dc5-7f80-44fc-ac5f-abe6675cc64e.png" />

<img width="1916" height="1033" alt="image" src="../imagens/663136148-ee02c00d-9185-4f31-afb8-713832abc1cc.png" />

<img width="1916" height="1033" alt="image" src="../imagens/663136361-b09e31d8-8290-4fab-ac02-c2ecdcfd17fe.png" />

> **Caça por IP de origem:** filtrando `data.win.eventdata.ipAddress:192.168.99.50` isolei **só** o que veio da Kali — é assim que um analista separa o atacante do ruído normal da rede.

---

**Competências demonstradas:** Kali (nmap, netexec, Responder), simulação de ataques (recon, brute force, spraying, persistência local e remota, LLMNR poisoning), caça a ameaças e triagem no Wazuh, leitura de Event IDs e do **IP de origem** (`data.win.eventdata.ipAddress` ≠ `agent.ip`), mapeamento MITRE ATT&CK e **defesa em profundidade** (detecção + prevenção em 3 camadas).
