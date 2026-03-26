# UI Design & Design System (FGR-OPS)

This document specifies the visual identity, design system, and screen specifications for the FGR-OPS platform. It is derived from the technical rules mapping defined in `docs/SPEC/07-design-ui-logica.md`.

## 1. Visual Identity & Design System

The system requires a premium, modern, and highly usable interface tailored for both field workers (mobile) and supervisors (web dashboard).

*   **Design Theme / Moodboard**: Modern Industrial, Light Mode preferred (clean, high visibility in daylight), with high contrast.
*   **Color Palette**:
    *   **Primary Accent**: `#ecb613` (Industrial Yellow/Gold - implies machinery, action, warning)
    *   **Background (Light Mode)**: `#f4f5f7` to `#ffffff` (Clean, well-lit spaces)
    *   **Surface / Cards**: `#ffffff` with subtle borders (`#e0e0e0`)
    *   **Text**: Primary `#1a1a1a` (Near black for strong contrast), Secondary `#5f6368` (Clean gray)
    *   **Status Indicators**: 
        *   Critical/Violation (Danger): `#ff3b3b` (Red)
        *   Running/Executing (Success): `#00e676` (Green)
        *   Paused/Warning (Warning): `#ff9800` (Orange)
*   **Typography**:  
    *   **Primary Font**: `Inter` or `Plus Jakarta Sans` for clean, highly legible numerical data and statuses.
    *   **Hierarchy**: Large, readable headers for field operators.
*   **Component Roundness**: `ROUND_EIGHT` (8px border radius) for a modern, slightly softened but still professional look.
*   **Interactive Elements**: High-contrast ActionButtons, floating action buttons (FABs) for mobile, and dense data tables for web.

## 2. Screen Specifications

These are the 4 main screens to be generated:

### 2.1. Mobile do Empreiteiro (Criação de Demandas)
**Device**: Mobile
**Description**: The field contractor's view to request machinery.
*   **Header**: Clean top bar with "Minhas Solicitações" and user profile avatar.
*   **Main Content**: A view showing active demands (cards).
*   **FAB (Floating Action Button)**: Prominent primary color (`#ecb613`) button to "Nova Demanda".
*   **Form (BottomSheet/Modal)**: When open, it shows a sleek form with:
    *   Dropdown for "Serviço"
    *   Toggle for "Urgência" (ASAP vs Scheduled)
    *   Location map snippet.
*   **Aesthetic**: Simple, minimal inputs, large touch targets.

### 2.2. Mobile do Operador (Execução no Campo)
**Device**: Mobile
**Description**: The machinery operator's view. Focuses ONLY on the highest priority task.
*   **Header**: Current shift status (e.g., "Turno Ativo").
*   **Main Card (Center Stage)**: A massive, highly visible card showing the current `EM_EXECUCAO` or `PENDENTE_OPERADOR` demand.
    *   **Content**: Service type, location, and contractor name.
    *   **Primary Action**: Giant green button "Iniciar Deslocamento" or "Finalizar".
    *   **Secondary Action**: Outline button "Pausar" (Orange).
*   **Footer**: A subtle list showing the next 2 demands in the queue (read-only, no actions).
*   **Aesthetic**: High contrast, foolproof, giant buttons for gloved hands or shaky environments.

### 2.3. Dashboard Web Subordinado/Supervisor
**Device**: Desktop
**Description**: The control room for monitoring all machinery and SLA conditions.
*   **Sidebar**: Navigation menu (Fila, Auditoria, Relatórios).
*   **Main Content**: A dense, Kanban-style or high-data table view.
    *   **Columns**: Pendente, Em Execução, Pausada, Concluída.
    *   **Cards**: Each demand card must show real-time SLA badges (Green, Yellow, Red). 
    *   **Visual Highlights**: Cards violating SLA should throb or have a red glowing border (`status-danger`).
*   **Top Bar**: Global filters and active operator count.
*   **Aesthetic**: Professional, data-heavy, dashboard layout with clear color-coding for rapid incident response.

### 2.4. Portal Login FGR Interno (Web)
**Device**: Desktop/Mobile Agnostic
**Description**: The secure entry hub for FGR operations.
*   **Layout**: Split screen. Left side: Beautiful industrial image or dark gradient with FGR logo. Right side: Login form.
*   **Form**: Email, Password, and "Entrar" button.
*   **Aesthetic**: Corporate, highly polished, premium introduction to the software suite.

