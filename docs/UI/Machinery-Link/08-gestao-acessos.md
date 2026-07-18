# Tela: Gestão de Acessos

**Aplicação:** Machinery Link (Módulo)
**Device:** Desktop (≥ 1280px)
**Design System:** [UI-DESIGN.md](../UI-DESIGN.md)

**Rastreio PRD:** `REQ-RBAC-001`, `REQ-RBAC-002`, `REQ-RBAC-005`, `REQ-RBAC-006`
→ SPEC: [`docs/SPEC/01-modulos-plataforma.md` §Bootstrapping-de-obra](../../SPEC/01-modulos-plataforma.md)
→ SPEC: [`docs/SPEC/04-rbac-permissoes.md`](../../SPEC/04-rbac-permissoes.md)

---

## 1. Objetivo

Gerencia os atores de campo da obra dentro do módulo Machinery Link (escopo `tenant-scoped` por `obraId`): **Empreiteiras** (passo #13), **Empreiteiros** com PIN de acesso (passo #15), **Operadores** com habilitação por `TipoMaquinario` (passo #16) e **Ajudantes** (passo #17). Consolida os quatro cadastros em abas separadas, mantendo a responsabilidade do `AdminOperacional` de provisionar e gerenciar todos os perfis de campo da obra.

> **Contexto arquitetural:** Esta tela gerencia usuários de campo (`Empreiteiro`, `Operador`) e entidades operacionais (`Empreiteira`, `Ajudante`) — todos escopados por `obraId`. Usuários de plataforma (`AdminOperacional`, `UsuarioInternoFGR`, `Board`) são provisionados pelo `SuperAdmin` via FGR Ops. A política de autenticação D6/DEC-004 aplica-se aqui: perfis de campo usam PIN de 6 dígitos com rotação de 90 dias.

---

## 2. Layout

```
┌────────────────────────────────────────────────────────────────────────────┐
│  APP SHELL — TOP BAR                                                       │
│  Logo FGR Ops   [Machinery Link]    [Obra: Site Alpha ▾]    [👤 Admin ▾]  │
├────────┬───────────────────────────────────────────────────────────────────┤
│        │  BREADCRUMB: FGR Ops > Machinery Link > Acessos                   │
│  SIDE  ├──────────────────────────────────────────────────────────────────┤
│  BAR   │                                                                  │
│        │  TABS                                                            │
│        │  [🏢 Empreiteiras]  [👤 Empreiteiros]  [🚜 Operadores]  [🧑 Ajudantes]│
│  ┌──┐  │  ──────────────────────────────────────────────────────────────  │
│  │⚙│  │                                                                  │
│  │Cf│  │  CONTEÚDO DA ABA ATIVA (ver seções abaixo)                       │
│  └──┘  │                                                                  │
│        │                                                                  │
│  ┌──┐  │                                                                  │
│  │👥│  │                                                                  │
│  │Ac│  │                                                                  │
│  └──┘  │                                                                  │
└────────┴──────────────────────────────────────────────────────────────────┘
```

---

## 3. Componentes

### 3.1 Sidebar (Navegação do Módulo)

Item **Acessos** ativo:

| Item | Ícone | Rota | Perfis |
|---|---|---|---|
| **Fila de Demandas** | 📋 | `/machinery-link/fila` | AdminOperacional, UsuarioInternoFGR |
| **Dashboard** | 📊 | `/machinery-link/dashboard` | AdminOperacional, UsuarioInternoFGR, Board |
| **Auditoria** | 📝 | `/machinery-link/auditoria` | AdminOperacional, UsuarioInternoFGR, Board |
| **Operadores** | 👷 | `/machinery-link/operadores` | AdminOperacional, UsuarioInternoFGR |
| **Configurações** | ⚙ | `/machinery-link/configuracoes` | AdminOperacional, SuperAdmin |
| **Acessos** | 👥 | `/machinery-link/acessos` | AdminOperacional, SuperAdmin |

---

## 4. Aba 1: Empreiteiras

Passo #13 do bootstrapping. Cadastro das empresas terceirizadas que operam maquinário ou têm empreiteiros vinculados. Rastreio: `machinery:empreiteira:create/update/delete`.

```
┌──────────────────────────────────────────────────────────────────────────┐
│  EMPREITEIRAS                                    [+ Nova Empreiteira]    │
│  ──────────────────────────────────────────────────────────────────────  │
│  ┌──────────────────┬──────────────┬──────────────┬────────────────────┐ │
│  │  Razão Social    │   CNPJ       │ Empreiteiros │  Maquinários       │ │
│  ├──────────────────┼──────────────┼──────────────┼────────────────────┤ │
│  │  Construtora ABC │ 00.000.000/… │     3        │ 2 ativos           │ │
│  │  Terraplan Ltda  │ 11.111.111/… │     5        │ 1 ativo            │ │
│  └──────────────────┴──────────────┴──────────────┴────────────────────┘ │
└──────────────────────────────────────────────────────────────────────────┘
```

**Formulário de Empreiteira:**

| Campo | Tipo | Validação |
|---|---|---|
| Razão Social | `input[type=text]` | Obrigatório, único por obra |
| CNPJ | `input[type=text]` | Opcional, formato validado |
| Contato | `input[type=text]` | Opcional |

**Ação de exclusão:** bloqueada se houver empreiteiros ou maquinários vinculados ativos. Exibir aviso: _"Existem [N] empreiteiros e [M] maquinários vinculados. Desative-os antes de remover a empreiteira."_

---

## 5. Aba 2: Empreiteiros

Passo #15. Usuários com perfil `Empreiteiro` vinculados a uma `Empreiteira`. Autenticam via PIN de 6 dígitos (D6/DEC-004). Rastreio: `core:usuario:create/update/delete`.

```
┌──────────────────────────────────────────────────────────────────────────┐
│  EMPREITEIROS                                    [+ Novo Empreiteiro]    │
│  ──────────────────────────────────────────────────────────────────────  │
│  ┌──────────────────┬───────────────┬───────────┬────────┬────────────┐  │
│  │  Nome            │  Empreiteira  │  PIN      │ Status │  Ações     │  │
│  ├──────────────────┼───────────────┼───────────┼────────┼────────────┤  │
│  │  Carlos Mendes   │  Constr. ABC  │  ●●●●●● ↻ │ ✅ Ativo│  ✎  ⛔    │  │
│  │  Rafael Costa    │  Terraplan    │  ●●●●●● ↻ │ ✅ Ativo│  ✎  ⛔    │  │
│  └──────────────────┴───────────────┴───────────┴────────┴────────────┘  │
└──────────────────────────────────────────────────────────────────────────┘
```

**Formulário de Empreiteiro:**

| Campo | Tipo | Validação |
|---|---|---|
| Nome Completo | `input[type=text]` | Obrigatório |
| Empreiteira | Dropdown (`Empreiteira`) | Obrigatório — dependência #13 |
| PIN | Gerado automaticamente (6 dígitos) | Exibido uma vez na criação; não recuperável |

**Gestão de PIN:**
- Ao criar, o sistema gera o PIN aleatório de 6 dígitos e exibe em modal **uma única vez** com botão "📋 Copiar PIN".
- O admin não tem acesso ao PIN após fechar o modal — apenas pode **resetar** via ícone ↻ (gera novo PIN).
- Expiração: 90 dias. Sistema exibe badge 🔴 _"PIN expirado"_ na coluna PIN quando vencido.

**Ações por linha:**
| Ação | Ícone | Comportamento |
|---|---|---|
| Editar | ✎ | Edita nome e empreiteira vinculada; não expõe PIN |
| Resetar PIN | ↻ | Gera novo PIN com diálogo de confirmação |
| Desativar | ⛔ | Bloqueia acesso sem excluir o registro; preserva histórico |

---

## 6. Aba 3: Operadores

Passo #16. Usuários com perfil `Operador` habilitados por `TipoMaquinario`. Autenticam via PIN de 6 dígitos (D6/DEC-004). Rastreio: `machinery:operador:create/update/delete`.

```
┌──────────────────────────────────────────────────────────────────────────┐
│  OPERADORES                                      [+ Novo Operador]       │
│  ──────────────────────────────────────────────────────────────────────  │
│  ┌──────────────────┬────────────────────────┬──────────┬─────────────┐  │
│  │  Nome            │  Maquinários Habilitados│ PIN      │  Ações      │  │
│  ├──────────────────┼────────────────────────┼──────────┼─────────────┤  │
│  │  José da Silva   │  Retro, Caminhão        │ ●●●●●● ↻ │  ✎  ⛔     │  │
│  │  Ana Ferreira    │  Pá Carregadeira        │ ●●●●●● ↻ │  ✎  ⛔     │  │
│  └──────────────────┴────────────────────────┴──────────┴─────────────┘  │
└──────────────────────────────────────────────────────────────────────────┘
```

**Formulário de Operador:**

| Campo | Tipo | Validação |
|---|---|---|
| Nome Completo | `input[type=text]` | Obrigatório |
| CPF | `input[type=text]` | **Obrigatório** — login de campo (ADR 0003); dígito verificador validado; máscara normalizada p/ 11 dígitos |
| E-mail | `input[type=email]` | Opcional |
| Tipos de Maquinário Habilitados | Checkbox group (`TipoMaquinario`) | Mínimo 1 (FE) — dependência #10 |
| Máquinas Liberadas | Checkbox group agrupado por tipo habilitado (`Maquinario`), **cascata visual** — ADR 0004 | Opcional (0+); só exibe unidades cujo tipo está marcado acima |
| PIN | Gerado automaticamente (6 dígitos) no servidor | Exibido uma vez na criação (não recuperável) |

> **T4.4 (2026-06-26):** implementação canônica em **`/machinery-link/operadores`** (shell mínimo
> `/machinery-link`; entrada via nav do `/admin`). A tela 4-abas consolidada (`/machinery-link/acessos`) e as
> demais entradas da sidebar ficam diferidas (pós-MVP). **Campos CPF (obrigatório) + E-mail (opcional)** entram
> por força do ADR 0003 / SPEC-08 §4 (a versão anterior listava só Nome/Tipos/PIN). **"Multi-select" → checkbox
> group** (não há multi-select no app; catálogo de baixa cardinalidade). A **lista** mostra a ação **"Resetar
> PIN"** por linha + colunas **CPF (mascarado)** e **Status** (em vez da coluna "PIN ●●●●●● ↻" do mock). O aviso
> de edição com expediente ativo é **estático** (`OperadorView` não expõe a flag de expediente).
>
> **Elegibilidade por MÁQUINA (ADR 0004 — feat/operador-maquinario-elegibilidade):** abaixo do checkbox-group
> de **Tipos Habilitados**, nova seção **Máquinas Liberadas** agrupada por tipo — cascata visual: só aparecem
> unidades cujo tipo está marcado. Desmarcar um tipo remove suas máquinas da seleção (mantém a invariante no
> cliente antes do submit). Submit envia `tiposMaquinarioIds` **e** `maquinariosIds` juntos (`PATCH
> /operadores/:id` combinado, replace-whole-set dos dois conjuntos). A coluna **"Maquinários Habilitados"** da
> tabela acima (mock) passa a exibir as **máquinas liberadas** (badges), não mais os tipos — reflete a cascata.

**Habilitações — dois níveis em cascata (ADR 0004):**
- **Tipo (`TipoMaquinario`)** — competência: exibida como badges na tabela: `[Retroescavadeira] [Caminhão Basculante]`. Alimenta o hard-filter de compatibilidade do motor de fila (allocator) — o operador só recebe demandas cujo maquinário corresponda a um `TipoMaquinario` de sua habilitação.
- **Máquina (`OperadorMaquinario`)** — unidade específica liberada para o **check-in**; tipo sozinho **nunca** libera check-in (motivo: máquinas frequentemente alugadas — dois operadores do mesmo tipo podem ter unidades diferentes liberadas). Toda máquina liberada deve pertencer a um tipo habilitado (cascata, validada no backend no write — `422 OPR-012` se violada).
- Ao editar habilitações (tipo ou máquina), exibir aviso se o operador tiver expediente ativo: _"Alterar habilitações de um operador com expediente aberto afetará sua fila imediatamente."_

**Gestão de PIN:** idêntica à dos Empreiteiros (geração única, reset).

---

## 7. Aba 4: Ajudantes

Passo #17. Recurso humano sem credencial própria — vinculado ao expediente do Operador no campo. Rastreio: `machinery:ajudante:create/update/delete`.

```
┌──────────────────────────────────────────────────────────────────────────┐
│  AJUDANTES                                        [+ Novo Ajudante]      │
│  ──────────────────────────────────────────────────────────────────────  │
│  ┌──────────────────────────────────────────┬────────┬──────────────┐    │
│  │  Nome                                    │ Status │  Ações       │    │
│  ├──────────────────────────────────────────┼────────┼──────────────┤    │
│  │  Paulo Rodrigues                         │ ✅ Ativo│  ✎  ⛔      │    │
│  │  Marcos Lima                             │ ✅ Ativo│  ✎  ⛔      │    │
│  └──────────────────────────────────────────┴────────┴──────────────┘    │
└──────────────────────────────────────────────────────────────────────────┘
```

**Formulário de Ajudante:**

| Campo | Tipo | Validação |
|---|---|---|
| Nome Completo | `input[type=text]` | Obrigatório |
| Observações | `textarea` | Opcional |

> Ajudantes não têm credencial de acesso. Eles são selecionados pelo `Operador` no momento do check-in do expediente para compor a equipe. Sem PIN, sem login.

---

## 8. Modal de Criação com PIN (Empreiteiro / Operador)

Exibido imediatamente após o cadastro bem-sucedido. Fecha apenas via botão explícito.

```
┌──────────────────────────────────────────────────────────┐
│  ✅ Operador cadastrado com sucesso!               [✕]   │
│  ────────────────────────────────────────────────────── │
│  José da Silva                                          │
│                                                          │
│  PIN de Acesso (6 dígitos)                              │
│  ┌──────────────────────────────────────────────────┐   │
│  │  4 8 2 1 7 3                    [📋 Copiar PIN]  │   │
│  └──────────────────────────────────────────────────┘   │
│                                                          │
│  ⚠ Este PIN não será exibido novamente.                 │
│    Compartilhe-o com o operador em segurança.            │
│                                                          │
│                        [Entendido — Fechar Modal]        │
└──────────────────────────────────────────────────────────┘
```

> **T4.4 (2026-06-26):** a copy **"O PIN expira em 90 dias" foi removida** do modal: T4.3/T4.4 **não** rastreiam
> rotação de PIN (sem `senhaTrocadaEm`), então prometer expiração não-aplicada engana o admin. A política de
> rotação 90d (D6/DEC-004) permanece como intenção até ser enforçada. O reset (↻) usa o mesmo modal.

---

## 9. RBAC — Controle de Acesso

| Ação | AdminOperacional | SuperAdmin | UsuarioInternoFGR | Board |
|---|---|---|---|---|
| **Criar/editar Empreiteiras** | ✅ | ✅ | ✗ | ✗ |
| **Criar/editar Empreiteiros** | ✅ | ✅ | ✗ | ✗ |
| **Resetar PIN (Empreiteiro/Operador)** | ✅ | ✅ | ✗ | ✗ |
| **Criar/editar Operadores** | ✅ | ✅ | ✗ | ✗ |
| **Gerenciar habilitações do Operador** | ✅ | ✅ | ✗ | ✗ |
| **Criar/editar Ajudantes** | ✅ | ✅ | ✗ | ✗ |
| **Desativar qualquer ator de campo** | ✅ | ✅ | ✗ | ✗ |
| **Visualizar lista (somente leitura)** | ✅ | ✅ | ✅ | ✅ |
| **Acessar sidebar "Acessos"** | ✅ | ✅ | ✗ | ✗ |

Permissões aplicadas: `core:usuario:create/update`, `machinery:operador:create/update/delete`, `machinery:empreiteira:create/update/delete`, `machinery:ajudante:create/update/delete`.

---

## 10. Estados e Interações

| Estado | Comportamento |
|---|---|
| **Aba sem registros** | Ilustração + mensagem contextual por aba + botão primário de criação |
| **Salvando** | Botão com spinner; formulário desabilitado |
| **PIN expirado** | Badge 🔴 + tooltip _"PIN expirou em [data]. Clique em ↻ para resetar."_ |
| **Operador com expediente ativo sendo editado** | Banner de aviso antes de confirmar edição de habilitações |
| **Exclusão bloqueada** | Diálogo com lista de dependências ativas |

---

## 11. Responsividade

| Breakpoint | Comportamento |
|---|---|
| **≥ 1280px** | Tabelas completas com todas as colunas |
| **1024–1279px** | Colunas secundárias ocultadas; scroll horizontal |
| **< 1024px** | Sidebar collapsa; tabelas viram lista de cards; formulários em tela cheia |
