# Proposta — Redução da triplicação de UX de pop-up de notificação

## Resumo

O comportamento "nova demanda com fila vazia → pop-up + som + vibração" está descrito com detalhe de UX em quatro lugares simultâneos:

| Arquivo | Nível de detalhe atual | Papel correto |
|---|---|---|
| `PRD/02` REQ-JOR-004 | Labels de botão, regra de não-recusa, admin monitoring | Intenção de negócio |
| `PRD/03` REQ-FUNC-013 | 16 linhas: conteúdo do pop-up, labels, fluxo alternativo, admin | Intenção de negócio |
| `SPEC/07` §1.2 | UX completa (pop-up tela cheia, botões, Cenários A/B, dashboard) | **Fonte canônica de UX** ✓ |
| `SPEC/06` §Regras de deduplicação | Mecânica técnica (440Hz, [200,100,200], reconexão offline) | **Fonte canônica técnica** ✓ |

A triplicação entre PRD/02, PRD/03 e SPEC/07 já mostra divergência menor (PRD/02 não menciona "fila vazia" como critério para som/vibração — só "pop-up"; SPEC/06 inclui `prioridade = MAXIMA` como segundo gatilho além de `filaVazia`). Manter três descrições detalhadas garante drift futuro quando um arquivo for atualizado e os outros não.

## Motivação

Findings doc-review 2026-04-16: `prd-02` WARNING-003 e `prd-03` WARNING-002. Princípio: PRD declara **intenção de negócio**; SPEC/07 especifica **UX**; SPEC/06 especifica **mecânica técnica**.

## REQ-IDs afetados

- **`REQ-JOR-004`** (`PRD/02`) — texto reduzido sem alterar o requisito
- **`REQ-FUNC-013`** (`PRD/03`) — texto reduzido sem alterar o requisito

Nenhum REQ-ID novo, alterado (semântica) ou removido.

## Decisões

Nenhuma nova DEC necessária — refactoring documental que não altera comportamento definido. Última DEC aplicável: DEC-024 (escala de pesos).

## Riscos

Baixo. Toda a especificação de comportamento permanece intacta em SPEC/07 e SPEC/06; PRD/02 e PRD/03 passam a ser ponteiros ao invés de duplicatas. A rastreabilidade REQ-FUNC-013 ↔ SPEC/07 e SPEC/06 é preservada e fortalecida com links explícitos.
