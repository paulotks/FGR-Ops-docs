# PROJECT: [Nome do Projeto]

> INSTRUÇÃO: Substitua todos os campos [entre colchetes] com as informações reais do seu projeto.
> Depois de personalizar, DELETE esta linha.

## STACK
```
Backend: [Ex: Node.js 22 + TypeScript + Express 5]
Database: [Ex: PostgreSQL + Drizzle ORM]
Frontend: [Ex: React 19 + Vite + Tailwind CSS]
Auth: [Ex: JWT]
Tests: [Ex: Vitest + Supertest]
Deploy: [Ex: Railway / Vercel / AWS]
```

## PROJECT STRUCTURE
```
[Cole aqui a árvore de diretórios do seu projeto — máx 3 níveis]
src/
├── controllers/
├── services/ 
├── repositories/
└── routes/
```

## ARCHITECTURE RULES
- Pattern: [Ex: Layered — route → controller → service → repository]
- [Regra importante #2 do seu projeto]
- [Regra importante #3 do seu projeto]
- NEVER put business logic in [onde não deve: controllers, routes, etc.]
- ALWAYS use [prática obrigatória: Zod para validação, etc.]

## ROUTING TABLE
*Quando você encontrar um desses triggers, tome a ação correspondente:*

| Trigger | Action |
|---------|--------|
| New endpoint needed | Create route → controller → service → repository |
| Bug in [componente] | Check [onde verificar primeiro] |
| Performance issue | Check [onde olhar: N+1 queries, bundle size, etc.] |
| Auth issue | Check [middleware de auth, token expiry, etc.] |
| [Situação específica do projeto] | [Ação específica] |
| [Outra situação] | [Outra ação] |

## CURRENT STATE
*Atualize esta seção ao final de cada sessão*

Last session: [Data] — [O que foi feito]
In progress: [O que está em andamento]
Next: [Próxima prioridade]
Blockers: [Impedimentos atuais, se houver]

## MANDATORY RULES
1. Antes de adicionar qualquer endpoint → criar schema Zod de validação PRIMEIRO
2. Antes de fazer qualquer mudança no banco → verificar se existe migração pendente
3. [Regra crítica #3 do seu projeto]
4. [Regra crítica #4]

## FORBIDDEN
- NEVER use `any` in TypeScript without comment explaining why
- NEVER skip input validation
- NEVER commit .env files (use .env.example)
- NEVER log passwords, tokens, or PII
- [NEVER — regra específica do projeto]
- [NEVER — outra regra]

## QUALITY GATES
*Checklist obrigatório antes de considerar qualquer tarefa concluída:*

□ `npx tsc --noEmit` — 0 errors
□ `npm test` — all tests pass
□ `npm run lint` — 0 errors
□ [Verificação específica do projeto: ex. endpoint tem teste de integração]
□ [Outra verificação]

## ENV VARS
*Variáveis de ambiente usadas neste projeto:*

```env
DATABASE_URL=           # conexão com o banco
JWT_SECRET=             # secret para JWT
[OUTRA_VAR]=           # descrição
```

## HOOKS
*Ações que o Claude deve executar automaticamente em certas situações:*

| Trigger | Ação Automática |
|---------|----------------|
| Antes de criar endpoint | Gerar schema Zod de validação primeiro |
| Antes de merge mental | Rodar Quality Gates e listar violações |
| Quando encontrar bug | Documentar causa, fix e prevenção no CURRENT STATE |
| Ao criar novo componente | Verificar se existe similar antes de criar |
| Ao finalizar tarefa | Atualizar CURRENT STATE com progresso |

## COMMANDS
*Atalhos para tarefas repetitivas — digite o nome e Claude executa:*

```
/review → Analise todos os arquivos alterados nesta sessão. Liste cada violação de CLAUDE.md. Sugira fix para cada uma.

/status → Leia CURRENT STATE e responda: (1) o que está pronto, (2) o que está em andamento, (3) blockers, (4) prioridade recomendada para hoje.

/test → Execute `npm test`. Se falhar, analise o erro, proponha fix, e re-execute. Repita até verde.

/deploy-check → Execute TODOS os Quality Gates. Se algum falhar, liste os itens pendentes e ofereça fix automático.

/refactor [arquivo] → Analise o arquivo contra as Architecture Rules. Proponha refatorações alinhadas ao pattern do projeto.
```

## PERSONA
*Opcional — define o "tom" do Claude para este projeto:*

```
Você é um senior engineer na equipe de [Nome do Projeto].
Estilo: direto, sem rodeios, código > explicações longas.
Quando em dúvida, pergunte antes de assumir.
Quando completar uma tarefa, mostre o diff e pergunte se pode continuar.
```

---

## Exemplos de Personalização

### Para um projeto Next.js + Prisma:
```markdown
## STACK
Backend: Next.js 15 App Router + TypeScript
Database: PostgreSQL + Prisma ORM
Frontend: React 19 + Tailwind CSS + shadcn/ui
Auth: NextAuth v5 (Auth.js)
Tests: Vitest + Playwright
Deploy: Vercel

## ARCHITECTURE RULES
- Pattern: Server Components por padrão → 'use client' APENAS quando precisa de interatividade
- Data fetching: Server Components usam Prisma diretamente, NUNCA em Client Components
- Mutations: Server Actions com Zod validation
- ALWAYS use `revalidatePath` ou `revalidateTag` após mutations
```

### Para um projeto Python FastAPI:
```markdown
## STACK
Backend: Python 3.12 + FastAPI + SQLAlchemy 2.0
Database: PostgreSQL + Alembic migrations
Auth: OAuth2 + JWT (python-jose)
Tests: Pytest + HTTPX
Deploy: Docker + Railway

## ARCHITECTURE RULES
- Pattern: Router → Service → Repository (dependency injection via FastAPI Depends)
- ALWAYS use Pydantic models for request/response schemas
- NEVER import from routers inside services (dependency inversion)
- ALWAYS add type hints — mypy strict mode is enforced
```

### Para um projeto mobile React Native:
```markdown
## STACK
Mobile: React Native 0.76 + Expo SDK 52
State: Zustand + TanStack Query
Navigation: Expo Router (file-based)
Backend: Supabase (Auth + Database + Storage)
Tests: Jest + React Native Testing Library

## ARCHITECTURE RULES
- Pattern: Screen → Hook → Service → Supabase client
- ALWAYS use `useQuery`/`useMutation` for server state (NEVER useState for API data)
- ALWAYS test on both iOS and Android before marking task done
- NEVER use inline styles — use StyleSheet.create
```

---

## Checklist de Personalização

Antes de usar este template, certifique-se de ter configurado:

- [ ] **STACK** — tecnologias reais do seu projeto (não genéricas)
- [ ] **PROJECT STRUCTURE** — árvore de diretórios atualizada
- [ ] **ARCHITECTURE RULES** — mínimo 3 regras específicas do seu projeto
- [ ] **ROUTING TABLE** — mínimo 4 triggers com ações específicas
- [ ] **MANDATORY RULES** — mínimo 3 (as que causam bugs quando violadas)
- [ ] **FORBIDDEN** — mínimo 4 (as que causam incidentes quando violadas)
- [ ] **QUALITY GATES** — comandos reais do seu projeto (não placeholders)
- [ ] **ENV VARS** — todas as variáveis reais (sem valores!)
- [ ] **Deletar todas as linhas de instrução** (as que começam com `> INSTRUÇÃO:`)

---
*Claude Code Elite — Pack CLAUDE.md | Atualizado em: [Data]*
