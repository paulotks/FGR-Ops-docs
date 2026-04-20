# UI Design & Design System (FGR-OPS)

Este documento especifica a **identidade visual, design system e tokens de design** para toda a suíte FGR-OPS. É a referência centralizada para paleta, tipografia, componentes e estados visuais. As especificações detalhadas de cada tela estão nos arquivos individuais por aplicação.

> **Referência técnica:** Regras de mapeamento visual e lógica de interface estão em [`docs/SPEC/07-design-ui-logica.md`](../SPEC/07-design-ui-logica.md).

---

## 1. Brand Identity

A identidade visual da plataforma FGR-OPS descende diretamente do **Brand Guide da empresa**. Toda interface deve transmitir autoridade, confiabilidade e presença industrial.

| Elemento | Cor | Uso |
|---|---|---|
| **Brand Primary** | `#ad0f0a` | Logotipo, acentos visuais, botões primários, headers |
| **Brand Neutral** | `#999999` | Elementos secundários, ícones inativos, dividers |
| **Brand White** | `#ffffff` | Superfícies, fundos claros, texto sobre primário |

### Logotipo

- O logotipo FGR deve aparecer no login, no header do App Shell e no favicon
- Sobre fundo escuro/primário: versão branca
- Sobre fundo claro: versão com cor primária `#ad0f0a`

---

## 2. Color Palette

### 2.1 Core Palette (derivada do Brand)

| Token | Valor | Descrição |
|---|---|---|
| `--color-primary` | `#ad0f0a` | Cor principal da marca — botões, FABs, links ativos |
| `--color-primary-hover` | `#8c0c08` | Hover/pressed sobre primário |
| `--color-primary-light` | `#f8e0df` | Background sutil para seleções, highlights |
| `--color-primary-foreground` | `#ffffff` | Texto/ícone sobre fundo primário |
| `--color-neutral` | `#999999` | Brand gray — textos auxiliares, placeholders, dividers |
| `--color-neutral-dark` | `#666666` | Texto secundário reforçado |
| `--color-neutral-light` | `#cccccc` | Bordas suaves, separadores leves |

### 2.2 Background & Surface

| Token | Valor | Descrição |
|---|---|---|
| `--color-background` | `#f5f5f5` | Fundo geral da aplicação (Light Mode) |
| `--color-surface` | `#ffffff` | Cards, modals, dropdowns |
| `--color-surface-border` | `#e5e5e5` | Borda padrão de cards e containers |
| `--color-surface-elevated` | `#ffffff` | Superfícies elevadas (shadow-md) |

### 2.3 Text

| Token | Valor | Descrição |
|---|---|---|
| `--color-text-primary` | `#1a1a1a` | Texto principal — alto contraste |
| `--color-text-secondary` | `#737373` | Texto auxiliar, legendas, timestamps |
| `--color-text-muted` | `#999999` | Placeholders, labels inativos |
| `--color-text-inverse` | `#ffffff` | Texto sobre fundo escuro/primário |

### 2.4 Status Indicators (Semânticos)

> As cores de status são **independentes do brand** para preservar semântica universal e evitar conflito com o vermelho da marca.

| Token | Valor | Significado | Uso na UI |
|---|---|---|---|
| `--status-danger` | `#D32F2F` | Crítico / SLA violado | Badges, bordas pulsantes, alertas |
| `--status-danger-bg` | `#FFEBEE` | Background danger | Fundo de cards em violação |
| `--status-warning` | `#ED6C02` | Pausado / Atenção | Badges, ícones de alerta |
| `--status-warning-bg` | `#FFF3E0` | Background warning | Fundo de cards pausados |
| `--status-success` | `#2E7D32` | Em execução / Concluído | Badges, indicadores ativos |
| `--status-success-bg` | `#E8F5E9` | Background success | Fundo de cards concluídos |
| `--status-info` | `#0288D1` | Informativo / Aguardando | Badges, estados pendentes |
| `--status-info-bg` | `#E1F5FE` | Background info | Fundo de cards informativos |

---

## 3. Typography

| Propriedade | Valor | Notas |
|---|---|---|
| **Font Family (Primary)** | `Inter` | Clean, altamente legível para dados numéricos e status |
| **Font Family (Fallback)** | `Plus Jakarta Sans`, `system-ui`, `sans-serif` | Stack progressivo |
| **Heading 1** | 28px / 700 / 1.2 | Títulos de página |
| **Heading 2** | 22px / 600 / 1.3 | Títulos de seção |
| **Heading 3** | 18px / 600 / 1.4 | Subtítulos, card headers |
| **Body** | 16px / 400 / 1.5 | Texto geral |
| **Body Small** | 14px / 400 / 1.5 | Legendas, labels |
| **Caption** | 12px / 400 / 1.4 | Timestamps, metadados |

### Hierarquia Mobile (Campo)

Para telas mobile de operador e empreiteiro, os tamanhos são escalados:

| Elemento | Tamanho | Justificativa |
|---|---|---|
| **Card Title** | 20px / 600 | Legibilidade a distância de braço |
| **Action Button Label** | 18px / 700 | Toque preciso com luvas |
| **Status Badge** | 14px / 600 UPPERCASE | Destaque visual imediato |

---

## 4. Component Tokens

### 4.1 Roundness

| Componente | Border Radius | Notas |
|---|---|---|
| **Buttons** | `8px` | Moderno, profissional |
| **Cards** | `12px` | Leve destaque sobre a superfície |
| **Modals / Sheets** | `16px` (top) | BottomSheets arredondados no topo |
| **Inputs** | `8px` | Consistente com botões |
| **Badges / Chips** | `full` (pill) | Máxima distinção visual |
| **Avatars** | `full` (circle) | Padrão de identidade |

### 4.2 Elevation (Shadows)

| Nível | Valor CSS | Uso |
|---|---|---|
| `shadow-sm` | `0 1px 2px rgba(0,0,0,0.06)` | Inputs, chips |
| `shadow-md` | `0 4px 6px rgba(0,0,0,0.08)` | Cards, dropdowns |
| `shadow-lg` | `0 10px 25px rgba(0,0,0,0.12)` | Modals, FABs, popovers |

### 4.3 Spacing Scale

Base unit: `4px`. Escala: `4, 8, 12, 16, 24, 32, 48, 64px`.

### 4.4 Interactive States

| Estado | Tratamento Visual |
|---|---|
| **Hover** | `--color-primary-hover` em botões; `--color-primary-light` em cards/items |
| **Focus** | Ring `2px` com `--color-primary` + offset `2px` (acessibilidade) |
| **Active/Pressed** | Scale `0.97` + `--color-primary-hover` |
| **Disabled** | `opacity: 0.5`, `cursor: not-allowed`, `aria-disabled="true"` |
| **Loading** | Spinner integrado, botão desabilitado, sem duplo-submit |

---

## 5. Status Indicators — Mapeamento Visual

O sistema utiliza badges e cores para comunicar o estado das demandas de forma unificada:

| Estado da Demanda | Badge Label | Cor | Background |
|---|---|---|---|
| `AGENDADA` | Agendada | `--status-info` | `--status-info-bg` |
| `PENDENTE` | Pendente | `--status-info` | `--status-info-bg` |
| `PENDENTE_APROVACAO` | Aprovação | `--status-warning` | `--status-warning-bg` |
| `EM_ANDAMENTO` | Em Andamento | `--status-success` | `--status-success-bg` |
| `PAUSADA` | Pausada | `--status-warning` | `--status-warning-bg` |
| `RETORNADA` | Retornada | `--status-warning` | `--status-warning-bg` |
| `CONCLUIDA` | Concluída | `--status-success` | `--status-success-bg` |
| `CANCELADA` | Cancelada | `--status-danger` | `--status-danger-bg` |

### SLA Visual Escalation

| Nível SLA | Indicador | Comportamento |
|---|---|---|
| **Dentro do prazo** | Badge verde | Estático |
| **≥75% do tempo consumido** | Badge amarelo | Estático com ícone relógio |
| **SLA violado** | Badge vermelho com borda pulsante | Animação `pulse` CSS, borda `--status-danger` |

---

## 6. Accessibility

| Critério | Requisito |
|---|---|
| **Contraste texto** | WCAG AA (≥4.5:1 para texto normal, ≥3:1 para texto grande) |
| **Touch targets (mobile)** | Mínimo `48x48px` — operadores com luvas |
| **Focus indicators** | Ring visível `2px` em todos elementos interativos |
| **Color not sole indicator** | Todos os estados usam ícone + cor + texto |
| **Screen reader** | `aria-label` em botões de ação, `role="status"` em badges |
| **Motion** | Respeitar `prefers-reduced-motion` para animações opcionais |

---

## 7. Índice de Telas

As especificações detalhadas de layout, componentes e interações estão organizadas por aplicação:

### FGR Ops (Plataforma)

| # | Tela | Arquivo | Device |
|---|---|---|---|
| 1 | Portal Login | [01-login-portal.md](FGR-Ops/01-login-portal.md) | Desktop / Mobile |
| 2 | App Shell / Hub de Módulos | [02-app-shell-hub.md](FGR-Ops/02-app-shell-hub.md) | Desktop / Mobile |

### Machinery Link (Módulo Operacional)

| # | Tela | Arquivo | Device |
|---|---|---|---|
| 1 | Mobile Empreiteiro — Criação de Demandas | [01-mobile-empreiteiro.md](Machinery-Link/01-mobile-empreiteiro.md) | Mobile |
| 2 | Mobile Operador — Execução em Campo | [02-mobile-operador.md](Machinery-Link/02-mobile-operador.md) | Mobile |
| 3 | Dashboard Supervisor / Subordinado | [03-dashboard-supervisor.md](Machinery-Link/03-dashboard-supervisor.md) | Desktop |

### Próximos Passos (Fase Posterior)

> As telas de **cadastro administrativo** (CRUD) serão especificadas em iteração futura, incluindo:
> - Gestão de Setores Operacionais
> - Gestão de Quadras e Lotes
> - Gestão de Locais Externos e Adjacências
> - Catálogo de Materiais
> - Cadastro de Usuários e Perfis
> - Cadastro de Maquinários e Serviços
>
> Cada uma possui regras de negócio específicas que exigem planejamento dedicado.
