# Evidências — Fase 1 (Construindo o Projeto)

## Rede e ingresso no domínio

**1. Cliente pega IP do Domain Controller via DHCP Relay,**
O WS-RH01 recebeu `192.168.20.100`, gateway `192.168.20.1` e **Servidor DHCP `192.168.10.10`** (o DC), com DNS `192.168.10.10` e sufixo `nexora.local`. Prova que firewall + DHCP + relay funcionam juntos.

<img width="1912" height="1035" alt="image" src="../imagens/662272422-dde2d6b4-3732-458d-8c1a-06f59416ab6f.png" />


**2. Estação autenticada no domínio**
`whoami` no WS-RH01 retorna `nexora\administrator` — a máquina está no domínio.

<img width="1916" height="1033" alt="image" src="../imagens/662272710-fbda1a46-cfec-400b-b67a-40920be4d2a2.png" />


**3. Tela de login com conta de domínio**

<img width="1917" height="1034" alt="image" src="../imagens/662272829-89f13434-63f0-4bfb-ae15-60f0c8f78e8a.png" />


**4. Usuário de domínio logado na estação**
Configurações do Windows mostrando `maria.silva@nexora.local` conectada.

<img width="1918" height="1033" alt="image" src="../imagens/662272949-4fa5ad9f-2235-46c4-856f-fc355f06a5ee.png" />


## Active Directory — Estrutura

**5. Árvore de OUs (ADUC)**
`nexora.local → Nexora → Admins, Computadores (Servidores/Workstations), ContasServico, Grupos, Usuarios (Comercial/Diretoria/Financeiro/RH/TI)`.

<img width="1916" height="1031" alt="image" src="../imagens/662273046-de5036f2-08f9-4c6b-b478-d783e9392d42.png" />


**6. Usuários criados por script**
`Get-ADUser` listando os usuários da OU Usuarios: Maria Silva, Joao Souza, Ana Costa, Carlos Lima, Paula Rocha.

<img width="1916" height="1038" alt="image" src="../imagens/662273146-3689792f-1870-44fa-91bb-d140ab07bf1a.png" />


**7. Usuário pertence ao grupo do departamento**
`whoami /groups` da maria.silva mostrando **NEXORA\GRP-RH** — base do RBAC.

<img width="1917" height="1028" alt="image" src="../imagens/662273259-d02b2a5a-546b-472f-975e-b753a6c6fdbc.png" />


**8. Computador movido para a OU correta**
WS-RH01 dentro de `OU=Workstations` (para receber GPOs na Fase 2).

<img width="1917" height="1031" alt="image" src="../imagens/662273530-e680f98f-dc96-4ad1-a032-e9119e727253.png" />


## Servidor de arquivos e RBAC

> **Observação: Boas Práticas** - Porque não hospedar o File Server no Domain Controller.
> 
> Neste Laboratório, por limitações de recursos (RAM/CPU do Host), O compartilhamento de arquivos foi colocado no próprio SRV-DC01. Isso é só aceitável em Lab, em produção é uma má prática. 

**9. Compartilhamentos criados (Server Manager)**
7 shares: NETLOGON, SYSVOL, RH, Comercial, Diretoria, Financeiro, TI — cada um em `C:\Compartilhado\...`.

<img width="1912" height="1041" alt="image" src="../imagens/662273662-6860353e-2434-493f-af3a-3ed7ffe6a39c.png" />


**10. Acesso PERMITIDO à própria pasta**
maria.silva (RH) abre `\\srv-dc01\rh` normalmente.

<img width="1917" height="1031" alt="image" src="../imagens/662273765-7160afa9-247a-4024-b375-499e9f2d82dd.png" />


**11. Acesso NEGADO à pasta de outro setor (a prova de ouro)**
A mesma maria.silva é **bloqueada** em `\\srv-dc01\Financeiro`: *"Você não tem permissão para acessar"*. A segregação por grupo funciona.

<img width="1911" height="1033" alt="image" src="../imagens/662273943-cbade774-a15a-403c-9799-b271679d06be.png" />

---


