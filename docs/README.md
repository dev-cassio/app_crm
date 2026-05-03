# Documentação do projeto

## Ordem de leitura para iniciar o desenvolvimento do MVP

1. **[`first_prd.md`](first_prd.md)** — fonte principal de produto: visão, escopo MVP, atores, regras, histórias, modelo conceitual, fluxos e roadmap pós-MVP.
2. **[`checklist_pre_codigo.md`](checklist_pre_codigo.md)** — decisões técnicas fechadas (stack, exclusões, limites numéricos, WhiteNoise, Docker/mídia) e itens que ainda passam pela implementação.
3. **[`README.md`](../README.md)** na raiz — comandos locais, dependências e variáveis de ambiente.

## Materiais complementares

| Arquivo | Uso |
|---------|-----|
| [`PRD_spec.md`](../PRD_spec.md) | Detalhamento extenso e histórico exportado; **não** substitui o `first_prd.md` como referência do MVP. Consultar quando precisar de granularidade extra. |
| [`app_specs.md`](app_specs.md) | Especificação herdada do documento base (rotas e stack antigos); **ver aviso no próprio arquivo** — alinhar sempre ao `first_prd.md`. |

## Antes da primeira sprint

- Responder o que fizer sentido em **«Perguntas pendentes»** no `checklist_pre_codigo.md` (hospedagem, LGPD, confirmação Bootstrap 5).

<a id="primeira-fatia-vertical"></a>

### Primeira fatia vertical (sugestão registrada)

Objetivo: ter um fluxo mínimo **ponta a ponta** com **dois tenants** e **sem vazamento de dados** entre empresas.

**Escopo sugerido da primeira entrega:**

1. Autenticação (login) com usuário vinculado a **uma empresa**.
2. Pelo menos **duas empresas** cadastradas no ambiente de desenvolvimento (ou fluxo mínimo para criar a segunda).
3. **Estágios padrão** visíveis para a empresa do usuário.
4. **Um lead** criado e exibido no **funil (Kanban)** no estágio correto.
5. Garantir, por teste automatizado ou script de verificação documentado, que um usuário da **empresa A** **não** acesse lead/dado da **empresa B**.

**Definição de pronto (DoD) sugerida para essa fatia:**

- [ ] Código revisado e integrado na branch acordada pelo time.
- [ ] Cobertura mínima: **pelo menos um teste** (ou checklist manual assinado) que prove **isolamento entre duas empresas** nas operações já implementadas.
- [ ] Variáveis e passos para reproduzir localmente descritos em `README.md` ou neste fluxo não geram erro em ambiente limpo (`cp .env-sample .env` + migrate + cenário registrado).

Ajustem datas e detalhes de implementação no planejamento da sprint; se mudarem esta fatia, **atualizem este trecho** para manter uma única fonte da verdade no repositório.
