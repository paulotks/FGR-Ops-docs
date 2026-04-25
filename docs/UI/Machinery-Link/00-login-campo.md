# Tela: Login Campo — PWA Machinery Link

**Aplicação:** Machinery Link (PWA Campo)
**Device:** Mobile (PWA, `manifest.json` próprio)
**Design System:** [UI-DESIGN.md](../UI-DESIGN.md)

**Rastreio PRD:** `REQ-RBAC-005`, `REQ-RBAC-006`, `REQ-NFR-002`, `REQ-OBJ-005`
→ SPEC: [`docs/SPEC/01-modulos-plataforma.md` §Fluxo de autenticação](../../SPEC/01-modulos-plataforma.md) · DEC-030
→ SPEC: [`docs/SPEC/04-rbac-permissoes.md`](../../SPEC/04-rbac-permissoes.md) · D6

---

## 1. Objetivo

Ponto de entrada do **PWA Machinery Link** para perfis de campo — `Empreiteiro` e `Operador`. Autenticação via email + PIN de 6 dígitos (D6). UX mobile-first, mínimo de toques, instalável via "Add to Home Screen" com manifest próprio.

> **Escopo:** Esta tela não pertence ao FGR Ops. É o entrypoint da rota `/app` (campo). Funcionários FGR usam o portal `docs/UI/FGR-Ops/01-login-portal.md`. (DEC-030)

---

## 2. Layout

### Mobile (tela única)

```
┌──────────────────────────┐
│   BRAND HEADER           │
│   Gradient + Logo FGR    │
│   "Machinery Link"       │
│   (height: 180px)        │
├──────────────────────────┤
│                          │
│   FORM PANEL             │
│                          │
│   ┌──────────────────┐   │
│   │ Email / Matrícula│   │
│   └──────────────────┘   │
│                          │
│   PIN (6 dígitos)        │
│   ┌──┐ ┌──┐ ┌──┐        │
│   │ ○│ │ ○│ │ ○│        │
│   └──┘ └──┘ └──┘        │
│   ┌──┐ ┌──┐ ┌──┐        │
│   │ ○│ │ ○│ │ ○│        │
│   └──┘ └──┘ └──┘        │
│                          │
│   ┌──────────────────┐   │
│   │     Entrar       │   │
│   └──────────────────┘   │
│                          │
│   "Esqueci meu PIN"      │
│                          │
└──────────────────────────┘
```

- **Brand Header:** Gradient diagonal `#ad0f0a → #3a0302`, logo FGR branca + label "Machinery Link" abaixo. `height: 180px`.
- **Form Panel:** Fundo `--color-surface` (`#ffffff`), padding lateral `24px`, conteúdo centralizado verticalmente no espaço restante.

---

## 3. Componentes

### 3.1 Campo de Identificação

| Campo | Tipo | Validação | Placeholder |
|---|---|---|---|
| **Email / Matrícula** | `input[type=email]` ou texto | Obrigatório | "seu.email@empresa.com" |

- Height: `48px`, border-radius `8px`, font `16px` (previne zoom iOS)
- Focus: `2px solid --color-primary`

### 3.2 Input PIN 6 Dígitos

- **6 campos individuais** (`width: 44px`, `height: 52px`, border-radius `8px`, `text-align: center`, `font-size: 20px/700`)
- Foco avança automaticamente ao digitar cada dígito; backspace retrocede ao campo anterior
- Tipo `input[type=password]` — exibe `●` enquanto digita, com toggle de visibilidade por campo (ícone olho na borda do grupo)
- Suporte a colar string de 6 dígitos (distribui automaticamente nos campos)
- Em dispositivos com teclado numérico: `inputmode="numeric"` força teclado numérico no iOS/Android

### 3.3 Botão "Entrar"

- **Tipo:** Primary button, `width: 100%`
- **Background:** `--color-primary` (`#ad0f0a`)
- **Texto:** `--color-primary-foreground` (`#ffffff`), `16px/700`
- **Habilitado:** somente quando email preenchido E 6 dígitos inseridos
- **Loading state:** Spinner branco + "Entrando..." — sem duplo-submit
- **Height:** `48px`, border-radius `8px`

### 3.4 Link "Esqueci meu PIN"

- Cor: `--color-primary`, hover: underline
- Posição: abaixo do botão, centralizado
- Ação: abre fluxo de redefinição de PIN (via email de recuperação)

---

## 4. Estados e Interações

| Estado | Comportamento |
|---|---|
| **Idle** | Campos vazios; botão desabilitado |
| **Digitando PIN** | Foco avança campo a campo; botão habilita ao completar 6 dígitos |
| **Loading** | Botão com spinner, inputs desabilitados |
| **Erro de autenticação** | Banner inline: _"Email ou PIN incorretos"_ — genérico (sem distinguir campo errado) |
| **Conta bloqueada** | _"Conta temporariamente bloqueada. Tente novamente em X minutos."_ |
| **Sucesso — Empreiteiro** | Redirect para `/app/demandas` (lista de demandas da obra) |
| **Sucesso — Operador** | Redirect para `/app/fila` (fila do operador / check-in diário) |
| **Erro de rede** | _"Falha de conexão. Verifique sua internet."_ |

### Redirect pós-login por perfil

O redirect é determinado pelo `role` do token JWT retornado:

| Perfil | Destino |
|---|---|
| `Empreiteiro` | `/app/demandas` — lista de solicitações da obra |
| `Operador` | `/app/fila` — check-in diário / demanda ativa |

---

## 5. PWA — Manifest e Instalação

Este entrypoint possui `manifest.json` próprio, separado do FGR Ops:

| Propriedade | Valor |
|---|---|
| `name` | "Machinery Link" |
| `short_name` | "ML Campo" |
| `start_url` | `/app` |
| `display` | `standalone` |
| `theme_color` | `#ad0f0a` |
| `background_color` | `#ffffff` |
| `icons` | Ícone Machinery Link (192px / 512px) |

- Banner "Adicionar à tela inicial" nativo do navegador aparece após visitas recorrentes
- Service Worker gerencia cache offline para acesso em campo com sinal instável

---

## 6. Segurança

- Mensagem de erro genérica (não distingue "usuário não existe" de "PIN errado")
- Rate limiting visual: após 5 tentativas, exibir aviso de bloqueio temporário (15 min — conforme `REQ-NFR-006`)
- PIN nunca exibido em texto claro; toggle mostra/oculta por campo
- Sem "Lembrar-me" para perfis de campo (sessão expira ao fechar app ou por inatividade configurada)
- Rotação de PIN: 90 dias (D6)
