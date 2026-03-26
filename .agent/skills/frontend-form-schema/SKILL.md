---
name: frontend-form-schema
description: "Criar, revisar ou orientar forms frontend e schemas de validação no padrão FGR-Ops web (Angular). Usar quando o pedido envolver formulários reativos, validação, `FormBuilder`/`FormGroup`, ou integração type-safe com schemas (ex.: Zod, Valibot) no cliente `apps/web`."
---

# Frontend Form Schema

## Overview

Aplicar o padrão de formulários do cliente web **Angular** (`apps/web`) utilizando formularios reativos (ou template-driven quando adequado), bibliotecas de schema validation modernas (ex.: Zod ou Valibot) onde fizer sentido na fronteira de dados, e validadores alinhados ao contrato DTO do backend.

## Guidelines

- Validar dados com schema forte (Zod/Valibot) ou validadores Angular, garantindo inferência type-safe onde o projeto o definir.
- Derivar tipos de payload a partir do schema ou dos DTOs partilhados no monorepo.
- Integrar validação com o ciclo de vida do formulario (`FormGroup`, `FormControl`, `valueChanges` ou abstracções equivalentes).
- Usar componentes visuais padronizados do sistema de design adoptado no projeto Angular.
- Exibir mensagens de erro inline e extrair labels, placeholder via dicionário/texto claro.

## Workflow

1. Analisar os requisitos do campo para o formulário (ex.: criar Demanda).
2. Modelar o schema que reflita os contratos DTO definidos no backend.
3. Integrar schema/validadores no formulario Angular.
4. Mapear loading states de requisição.
5. Renderizar o formulário compondo Field, Label, Input e Error message.

## References

Consultar `references/form-schema-pattern.md` para convenções de forms no front-end do projeto (quando existir no repositório de implementação).
