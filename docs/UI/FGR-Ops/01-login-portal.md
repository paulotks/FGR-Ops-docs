# Tela: Portal Login FGR Ops

**Aplicação:** FGR Ops (Plataforma)
**Device:** Desktop / Mobile (Responsivo)
**Design System:** [UI-DESIGN.md](../UI-DESIGN.md)

**Rastreio PRD:** `REQ-RBAC-001`
→ SPEC: [`docs/SPEC/07-design-ui-logica.md` §1.4](../../SPEC/07-design-ui-logica.md)
→ SPEC: [`docs/SPEC/04-rbac-permissoes.md`](../../SPEC/04-rbac-permissoes.md)

---

## 1. Objetivo

Hub seguro de entrada para a plataforma FGR Ops. Primeira impressão do sistema — deve transmitir **confiança corporativa, solidez e modernidade**. Autenticação padrão com branding institucional.

---

## 2. Layout

### 2.1 Desktop (≥ 1024px) — Split Screen

```
┌──────────────────────────────────────────────────────────────┐
│                                                              │
│   ┌────────────────────────┐  ┌────────────────────────┐     │
│   │                        │  │                        │     │
│   │   BRAND PANEL          │  │   FORM PANEL           │     │
│   │                        │  │                        │     │
│   │  • Gradient escuro     │  │  • Logo FGR (primary)  │     │
│   │    (#ad0f0a → #3a0302) │  │  • "Bem-vindo ao       │     │
│   │  • Logo FGR (branca)   │  │    FGR Ops"            │     │
│   │  • Tagline             │  │  • Input Email         │     │
│   │  • Imagem industrial   │  │  • Input Senha         │     │
│   │    (overlay com        │  │  • Checkbox "Lembrar"  │     │
│   │     opacidade)         │  │  • Botão "Entrar"      │     │
│   │                        │  │  • Link "Esqueci minha │     │
│   │                        │  │    senha"              │     │
│   │         50%            │  │         50%            │     │
│   └────────────────────────┘  └────────────────────────┘     │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

- **Brand Panel (esquerda — 50%):** Gradient diagonal de `#ad0f0a` para `#3a0302` com sobreposição de imagem industrial em baixa opacidade (15-20%). Logotipo FGR na versão branca, centralizado verticalmente. Abaixo, tagline em branco: _"Plataforma de Operações"_.
- **Form Panel (direita — 50%):** Fundo `--color-surface` (`#ffffff`). Conteúdo centralizado vertical e horizontalmente com `max-width: 400px`.

### 2.2 Mobile (< 1024px) — Stacked

```
┌──────────────────────┐
│   BRAND HEADER       │
│   Gradient + Logo    │
│   (height: 200px)    │
├──────────────────────┤
│                      │
│   FORM PANEL         │
│   (full width)       │
│   • Logo (sm)        │
│   • Título           │
│   • Inputs           │
│   • Botão            │
│                      │
└──────────────────────┘
```

- Brand panel reduz para um **header fixo** com 200px de altura
- Form ocupa o restante da viewport com padding lateral `24px`

---

## 3. Componentes

### 3.1 Formulário de Login

| Campo | Tipo | Validação | Placeholder |
|---|---|---|---|
| **Email** | `input[type=email]` | Obrigatório, formato email válido | "seu.email@empresa.com" |
| **Senha** | `input[type=password]` | Obrigatório, mín. 8 caracteres | "Sua senha" |
| **Lembrar-me** | `checkbox` | Opcional | — |

**Estilo dos inputs:**
- Border: `1px solid --color-surface-border`
- Focus: `2px solid --color-primary` (ring)
- Border radius: `8px`
- Height: `48px`
- Font: `16px` (previne zoom no iOS)

### 3.2 Botão "Entrar"

- **Tipo:** Primary button, `width: 100%`
- **Background:** `--color-primary` (`#ad0f0a`)
- **Texto:** `--color-primary-foreground` (`#ffffff`), `16px/700`
- **Hover:** `--color-primary-hover` (`#8c0c08`)
- **Disabled:** `opacity: 0.5` durante loading
- **Loading state:** Spinner branco + "Entrando..." (sem duplo-submit)
- **Height:** `48px`, border-radius `8px`

### 3.3 Link "Esqueci minha senha"

- Cor: `--color-primary`
- Hover: underline
- Posição: abaixo do botão, centralizado

---

## 4. Estados e Interações

| Estado | Comportamento |
|---|---|
| **Idle** | Form vazio, botão habilitado |
| **Validação em tempo real** | Borda vermelha (`--status-danger`) + mensagem abaixo do input inválido |
| **Loading** | Botão com spinner, inputs desabilitados |
| **Erro de autenticação** | Toast ou banner inline acima do form: _"Email ou senha incorretos"_ com ícone de alerta, cor `--status-danger` |
| **Sucesso** | Redirect para App Shell (`/hub`) |

### Mensagens de Erro

| Situação | Mensagem |
|---|---|
| Email vazio | "Informe seu email" |
| Email inválido | "Formato de email inválido" |
| Senha vazia | "Informe sua senha" |
| Credenciais incorretas | "Email ou senha incorretos" |
| Conta bloqueada | "Conta temporariamente bloqueada. Tente novamente em X minutos." |
| Erro de rede | "Falha de conexão. Verifique sua internet." |

---

## 5. Visual Polish

- **Animação de entrada:** Form panel com fade-in + slide-up suave (300ms, ease-out)
- **Background gradient:** Transição suave via gradient CSS, sem imagem pesada
- **Imagem industrial:** Opcional, carregada de forma lazy, com fallback para gradient puro
- **Favicon e title:** `<title>FGR Ops — Login</title>`

---

## 6. Segurança Visual

- Campo de senha com toggle de visibilidade (ícone olho)
- Sem hints de "usuário não encontrado" vs. "senha errada" (mensagem genérica)
- Rate limiting visual: após 5 tentativas, exibir captcha ou delay progressivo
- Indicador de segurança: ícone de cadeado no header do form (trust signal)
