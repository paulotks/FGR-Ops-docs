---
name: frontend-form-schema
description: "Criar, revisar ou orientar forms frontend e schemas de validação no padrão FGR-Ops web. Usar quando o pedido envolver componentes de formulário React Hook Form, arquivos `data/schemas/*`, integrações de type-safety para schemas Next.js."
---

# Frontend Form Schema

## Overview

Aplicar o padrão de formulários React (Next.js) do projeto utilizando bibliotecas modernas de schema validation (ex: Zod ou Valibot) e React Hook Form.

## Guidelines

- O frontend deve validar dados com um schema forte (Zod/Valibot) garantindo inferência Type-safe.
- Derivar Payload de Form a partir do schema de validação (`infer<typeof schema>`).
- Integrar os Resolvers nos Hooks do RHF (`useForm`).
- Usar componentes visuais padronizados do Sistema de Design (Shadcn/UI ou equivalente em Tailwind).
- Exibir mensagens de erro inline e extrair labels, placeholder via dicionário/texto claro.

## Workflow

1. Analisar os requisitos do campo para o formulário (ex: criar Demanda).
2. Modelar o schema que reflita os contratos DTO definidos no backend.
3. Integrar schema no RHF resolver.
4. Mapear loading states de requisição.
5. Renderizar o formulário compondo Field, Label, Input e Error message.

## References

Consultar `references/form-schema-pattern.md` para convenções de forms no front-end do projeto.
