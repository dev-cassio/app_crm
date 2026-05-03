# Checklist pré-código — antes da primeira sprint

Objetivo: fechar **lacunas entre produto e implementação** antes de codar o MVP. Referência principal de negócio: `docs/first_prd.md`.

**Última atualização:** stack e padrões de mercado registrados conforme alinhamento com o produto.

---

## Stack e padrões já definidos

| Tema | Decisão registrada |
|------|-------------------|
| **Linguagem / framework** | **Python** + **Django** (servidor: templates SSR). |
| **UI** | **Bootstrap** (recomendação de mercado atual: **Bootstrap 5**) nos templates Django. |
| **Banco — desenvolvimento** | **SQLite** (rápido para local; já compatível com o projeto). |
| **Banco — produção** | **PostgreSQL** (padrão de mercado para Django em SaaS: transações, concorrência, evolução de schema). |
| **Arquivos estáticos** | **WhiteNoise** para servir CSS/JS (incl. Bootstrap) em produção, sem depender de servidor web separado só para `static/` — padrão comum em Django containerizado. |
| **Uploads (mídia / `MEDIA`)** | **Disco local** (`MEDIA_ROOT`), inclusive no **Docker**: usar **volume nomeado** (ou bind mount) para **persistir** logos e documentos de cliente entre restarts do container. **S3/objeto fica para uma fase futura** quando houver necessidade de escala ou multi-instância sem storage compartilhado. |
| **Autenticação** | Modelo de **usuário customizado** com **e-mail como identificador de login** (`USERNAME_FIELD`), alinhado ao PRD. |
| **Isolamento multiempresa** | **Um esquema de banco compartilhado** com `empresa_id` (ou equivalente) em entidades de negócio; **toda** leitura/escrita filtra pela empresa do usuário (serviço, managers ou política única documentada no código). |
| **Proteção CSRF** | Formulários Django com token (padrão do framework). |
| **Recuperação de senha** | Token **uso único**, validade **1 hora** (conforme `first_prd.md` / `PRD_spec`). |
| **Upload — tamanho máximo** | **10 MB** por arquivo (equilíbrio comum para PDFs/imagens em CRM). Ajustar `DATA_UPLOAD_MAX_MEMORY_SIZE` / limites do servidor conforme documentação Django. |
| **Upload — tipos** | Lista **permitida** alinhada ao PRD (pdf, imagens, office comum, txt); **bloqueio** de executáveis e scripts conforme `first_prd.md` §8. |
| **Paginação** | **25** itens por página nas listagens (padrão comum em painéis). |
| **Senha** | Validadores **padrão do Django** + comprimento mínimo típico (**8** caracteres); reforços (complexidade) podem ser ativados depois. |
| **Estágio com leads vinculados** | **Impedir desativação/exclusão** enquanto houver leads no estágio (opção recomendada no material de origem; menos ambiguidade operacional). |
| **Conversão de lead** | Manter o lead; marcar como convertido; **não** apagar o lead automaticamente. |
| **Exclusão de leads e clientes (MVP)** | **Padrão de mercado:** exclusão **definitiva** restrita ao **administrador da empresa**. Usuário **comercial** cria/edita/visualiza, mas **não** exclui lead nem cliente (reduz perda acidental, litígio e necessidade de auditoria; alinhado a CRMs B2B e PME). *Arquivos anexados:* mesma lógica de quem pode remover, em geral só admin no MVP. |
| **SMTP por empresa** | Em **produção**, tratar senha SMTP como **segredo**: **criptografia em repouso** no banco ou armazenamento em cofre — padrão de mercado. Em **dev**, aceitar configuração local (ex.: backend `console` ou serviço tipo Mailpit/MailHog) sem exigir o mesmo rigor. |
| **E-mail em desenvolvimento** | Backend **console** ou **file** do Django, ou container **Mailpit**/**MailHog** (padrão de mercado para não enviar e-mail real). |

---

## 1. Fonte da verdade e escopo

- [x] **`docs/first_prd.md`** é a referência do MVP (índice em `docs/README.md`). Detalhes extras só em `PRD_spec.md` quando não conflitarem.
- [x] **Exclusão de lead/cliente:** apenas **administrador da empresa** (padrão de mercado; ver tabela acima).
- [ ] Listar **fora do primeiro incremento** apenas o que já está em pós-MVP (`first_prd.md` §12) — **decisão de backlog da sprint 0**.

---

## 2. Decisões técnicas — o que ainda falta **implementar ou documentar no repositório**

- [x] Stack registrada no **`README.md`** e no **`docs/README.md`** (**Python + Django + Bootstrap 5**, **Postgres** em produção, **WhiteNoise** + volume para `MEDIA`).
- [ ] Garantir **`.env-sample`** com variáveis para Postgres, `SECRET_KEY`, caminhos de **`MEDIA_ROOT`** e documentação do **volume Docker** para mídia.
- [ ] No **Docker Compose** (ou equivalente): volume persistente montado em `MEDIA_ROOT`; **`collectstatic`** + **WhiteNoise** para arquivos estáticos.
- [ ] Quando surgir **multi-instância** ou necessidade de backup geográfico de mídia, reavaliar **objeto/S3** (pós-MVP ou fase de escala).
- [ ] Implementar **usuário customizado** e política **única** de filtro por empresa (revisão em code review para não vazar queryset).

---

## 3. Limites e políticas numéricas

- [ ] Aplicar no código e na configuração do servidor os limites de **upload (10 MB)** e **paginação (25)**.
- [ ] Revisar validação de **MIME/extensão** frente à lista do `first_prd.md` §8.
- [ ] Confirmar **1 hora** e **uso único** do token de recuperação nos testes.
- [ ] Opcional pós-MVP imediato: **rate limiting** em login (ex.: proteção contra força bruta) — não bloqueia início do MVP, mas é boa prática em produção.

---

## 4. Modelo de dados e integridade

- [ ] Mapear **entidades** da §9 do `first_prd.md` para modelos/migrações (incluindo `ConfiguracaoEmpresa` **1:1** com empresa).
- [ ] **Constraints**: cliente (e-mail/telefone únicos **por empresa** quando preenchidos); usuário (e-mail **único global**); FKs estágio/leads/empresa.
- [ ] Regra **estágio com leads**: bloquear exclusão/desativação que deixe dados inconsistentes — conforme tabela “Stack e padrões já definidos”.
- [ ] Fluxo de **conversão** alinhado ao PRD (lead permanece, marcado convertido).

---

## 5. Segurança e conformidade multiempresa

- [ ] CSRF em todas as mutações (form Django).
- [ ] Mensagem de login **genérica** em falha.
- [ ] Download de arquivo apenas com **autorização** e tenant correto; evitar URL pública direta a caminho sensível.
- [ ] Segredos só em **ambiente** / cofre.
- [ ] Teste com **dois tenants** (leitura/escrita) o mais cedo possível.

---

## 6. Operador SaaS (admin global) e empresas

- [ ] Bootstrap do **primeiro admin global** (comando documentado ou migração de dados controlada).
- [ ] Fluxo **nova empresa**: configuração padrão + estágios padrão + primeiro admin da empresa (`first_prd.md` §5.1 e §10).
- [ ] **Empresa inativa** / **usuário inativo**: bloquear acesso conforme PRD.

---

## 7. E-mail (SMTP por empresa)

- [ ] Tratamento de SMTP **não configurado** (mensagens claras; sem envio de aniversariantes).
- [ ] **Macros** conforme PRD.
- [ ] Lote de aniversariantes: **resumo** sucesso/falha.
- [ ] Implementar **criptografia em repouso** (ou estratégia equivalente) para credenciais SMTP antes de produção com dados reais.

---

## 8. Primeiro incremento de entrega (fatia vertical)

**Fatia vertical e DoD sugeridos (texto íntegro):** [`docs/README.md` § Primeira fatia vertical](README.md#primeira-fatia-vertical) — ajuste com o time e **mantenha essa secção atualizada** se mudar o escopo.

- [ ] Ordem sugerida mantida: **tenant + auth + empresa + usuários → estágios → leads + Kanban → clientes + arquivos → relatórios + SMTP + aniversariantes**.
- [ ] Alinhar a **primeira PR** ao escopo e DoD do link acima (ou documentar divergência no `README.md`).
- [ ] Confirmar que testes/cenários mínimos cobrem **isolamento entre duas empresas**, conforme o DoD registrado em `README.md`.

---

## 9. Observabilidade e ambientes

- [ ] Ambientes nomeados (local / staging / produção) e `.env-sample` completo para onboarding.
- [ ] Logs estruturados ou, no mínimo, nível de log definido para produção.
- [ ] Plano de **backup** Postgres + **volume de mídia** (ou diretório `MEDIA` no host) antes de dados reais.

---

## 10. Checklist rápido “pode começar a codar?”

- [ ] **§1** escopo e exclusões de produto definidos.
- [ ] **§2** stack registrada no repositório (README ou doc técnica).
- [ ] **§3** limites aplicados (upload, paginação, token).
- [ ] **§4** modelo e regras de estágio/conversão implementáveis sem dúvida.
- [ ] **§5** teste de dois tenants na roadmap da sprint.
- [ ] **§8** primeira fatia escolhida.
- [ ] Respostas às **perguntas pendentes** abaixo, quando aplicável.

---

## Perguntas pendentes (para você)

1. **Provedor de hospedagem em produção** já está escolhido (ex.: VPS, Railway, Fly.io, AWS)? Se ainda não, seguimos genérico até o deploy — só confirma se quer manter assim.

2. **Bootstrap:** padrão assumido como **Bootstrap 5** no `README.md`. Só há pendência se o cliente **exigir outra versão** — nesse caso, atualizar README e checklist.

3. Há exigência de **LGPD** explícita no MVP (termo de consentimento, exportação de dados do titular, DPO)? Se sim, isso vira item de produto além do escopo técnico mínimo atual.

Quando todos os itens da caixa da **§10** estiverem OK, a equipe pode seguir a sprint sem reabrir esses pontos informalmente.

---

## Nota técnica: WhiteNoise × mídia

**WhiteNoise** serve a pasta **`STATIC_ROOT`** (CSS, JS, assets do projeto). **Não** substitui o armazenamento de **uploads** (`MEDIA_ROOT`): logos e documentos continuam em disco, com **volume Docker** para não perder dados ao recriar o container.
