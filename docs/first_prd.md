# PRD inicial — CRM SaaS multiempresa

**Versão:** 1.0  
**Idioma de produto:** português do Brasil nas mensagens ao usuário, rótulos e documentação voltada ao negócio.  
**Premissa:** este documento é **agnóstico de linguagem**, framework e tecnologias de interface. Não descreve telas, componentes nem bibliotecas de apresentação.

---

## 1. Visão geral

O produto é um **CRM na web**, em formato **SaaS multiempresa** (várias organizações isoladas na mesma instância da aplicação). O núcleo funcional é a gestão de **leads**, **oportunidades** exibidas como **fluxo tipo Kanban** (colunas por estágio do funil), **histórico e comentários**, **conversão de lead em cliente**, **cadastro de clientes**, **documentos anexados**, **relatórios**, **personalização institucional básica** e **envio de e-mails** (SMTP por empresa), incluindo campanhas simples para **aniversariantes**.

O foco inicial são **pequenas e médias empresas** que precisam de fluxo simples, sem funcionalidades enterprise. O CRM é **genérico**: verticais específicas (ex.: imobiliário integral) ficam como evoluções futuras, não obrigatórias no MVP.

---

## 2. Objetivos por público

| Público | Objetivos |
|--------|-----------|
| Equipe comercial | Organizar oportunidades em funil visual; registrar interações; buscar leads; mover oportunidades entre estágios; converter leads em clientes. |
| Administrador da empresa | Configurar estágios; gerenciar usuários; configurar marca e contatos públicos; configurar SMTP; acompanhar relatórios e demografia. |
| Operador da plataforma SaaS | Criar e inativar empresas; garantir isolamento de dados; disponibilizar acesso inicial (ex.: primeiro administrador da empresa). |

---

## 3. Atores e perfis de acesso (MVP)

- **Administrador global da plataforma:** gestão de empresas (criação, lista, inativação); criação do primeiro administrador da empresa quando aplicável; **não** manipula dados comerciais do dia a dia das empresas, salvo decisão futura documentada.

- **Administrador da empresa:** usuários da empresa; configurações da empresa e do funil; leads e clientes (CRUD conforme política interna); relatórios; envio para aniversariantes; arquivo em clientes.

- **Usuário comercial:** leads (inclusive movimentação no funil visual); comentários; conversão para cliente; clientes e anexos; relatórios básicos; edição do próprio perfil (dados próprios e senha onde previsto).

- **Visitante não autenticado:** apenas fluxos públicos permitidos pela política do produto (ex.: entrada no sistema e recuperação de senha quando existir).

Matriz consolidada:

| Capacidade | Admin global | Admin empresa | Usuário comercial | Não autenticado |
|------------|:------------:|:-------------:|:-----------------:|:---------------:|
| Autenticar-se / recuperar senha | sim | sim | sim | conforme público |
| Painel tipo Kanban (funil visual) | não por padrão | sim | sim | não |
| Leads (criar/editar/visualizar/excluir) | não por padrão | sim | criar/editar/visualizar | não |
| Mover leads entre estágios | não por padrão | sim | sim | não |
| Comentários no lead | não por padrão | sim | sim | não |
| Converter lead em cliente | não por padrão | sim | sim | não |
| Clientes e anexos | não por padrão | sim | sim | não |
| Configurar funil | não por padrão | sim | não | não |
| Relatórios | não por padrão | sim | básicos | não |
| Configurações da empresa (marca/SMTP) | não por padrão | sim | não | não |
| Usuários da empresa | não por padrão | sim | não | não |
| Gerenciar empresas (tenant) | sim | não | não | não |

**Exclusão (MVP):** **apenas o administrador da empresa** pode excluir **lead** ou **cliente** (e, em geral, remover **anexos** sensíveis). Usuário comercial **não** exclui — alinhado ao padrão de mercado em CRM B2B/PME (`docs/checklist_pre_codigo.md`).

---

## 4. Glossário essencial

- **Empresa:** unidade tenant; todo dado comercial pertence a exatamente uma empresa.
- **Lead:** oportunidade em andamento associada a um estágio do funil.
- **Cliente:** cadastro formal, após conversão ou cadastro direto.
- **Estágio:** coluna ordenada no funil; pertence à empresa.
- **Posição:** ordem relativa do lead dentro do mesmo estágio.
- **Funil/Kanban:** representação onde estágios são colunas e leads são cartões movíveis dentro da empresa.
- **Fonte:** origem declarada do lead ou cliente (ex.: site, indicação).

---

## 5. Escopo do MVP — capacidades

1. Autenticação de usuários vinculados a empresa e **isolamento obrigatório** de dados por empresa.
2. Recuperação e redefinição de senha com **credencial de uso único** e **prazo curtíssimo de validade** (ver regras de negócio).
3. Gestão administrativa da **empresa** pelo operador SaaS e **inatividade da empresa bloqueando acesso** aos usuários vinculados.
4. **Painel tipo Kanban** com estágios ativos ordenados; arrastar/similar deve atualizar estágio e posição de forma **consistente**.
5. **Gestão completa do ciclo do lead**: cadastro, edição, listagem com filtros (estágio, fonte, responsável, período, buscas textuais), exclusão onde permitido.
6. **Comentários** ligados ao lead, com autor e data; removidos com o lead.
7. **Conversão** de lead em cliente com validações de duplicidade e campos obrigatórios.
8. **Clientes**: CRUD com unicidade de e-mail/telefone **por empresa** quando preenchidos.
9. **Arquivos** em clientes: tipos permitidos, tamanho máximo definido na implantação, bloqueio de formatos perigosos, acesso só após autorização e **sem exposição pública desprotegida** de documentos sensíveis.
10. **Configuração do funil** por empresa: nome, ordem, cor, ativo/inativo, tipo de resultado opcional (neutro/ganho/perdido); **não excluir estágio com leads**; **manter ao menos um estágio ativo**.
11. **Relatórios** (dados apenas da empresa): leads por estágio; leads por fonte; soma de valor estimado por estágio; clientes por período; aniversariantes (dia/mês/período); demografia (sexo, faixa etária).
12. **E-mail para aniversariantes** com macros substituíveis e envio via **SMTP configurado pela empresa**, com resumo de sucessos e falhas.
13. **Configurações da empresa**: nome exibido, contatos públicos, cores da identidade, logo, parâmetros SMTP e teste de envio.
14. **Perfil do usuário**: dados básicos e alteração de senha com confirmação da senha atual quando aplicável.
15. **Gestão de usuários** da empresa com e-mail **único globalmente**; **pelo menos um administrador ativo** por empresa.
16. **Provisionamento inicial** de nova empresa: configuração padrão, estágios padrão do funil e usuário administrador inicial quando o fluxo de onboarding previr.

### 5.1 Estágios padrão sugeridos (ao criar empresa)

1. Novo lead  
2. Contato inicial  
3. Qualificado  
4. Proposta enviada  
5. Negociação  
6. Fechado — ganho  
7. Fechado — perdido  

### 5.2 Fontes de lead sugeridas (enumeradas)

Site; indicação; WhatsApp; redes sociais; telefone; e-mail; evento; prospecção ativa; outro.

---

## 6. Fora do escopo do MVP (explícito no material de origem)

Itens não exigidos no MVP salvo decisão explícita de produto ou de um projeto paralelo:

- Cobrança recorrente e gateway de pagamento.
- Planos comerciais e limites por assinatura.
- Integrações oficiais com WhatsApp/redes sociais.
- Automação avançada de funil.
- Módulo imobiliário completo ou propostas comerciais/assinatura digital.
- IA para classificação de leads.
- API pública para terceiros.
- App mobile nativo.
- Auditoria avançada.
- Soft delete obrigatório em todas entidades.
- Importação/exportação em massa.
- Webhooks.

---

## 7. Histórias de usuário

### Autenticação e sessão

- Como **usuário**, quero **entrar no sistema com e-mail e senha**, para que **eu acesse apenas os dados da minha empresa**.
- Como **usuário**, quero **recuperar minha senha por e-mail**, para que **eu recupere acesso sem intervenção de suporte**, respeitando política de segurança (mensagens genéricas no login).
- Como **visitante**, quero **redefinir senha com um link de uso limitado**, para que **só eu consiga concluir a troca dentro do prazo**.

### Multiempresa e governança

- Como **administrador global**, quero **cadastrar uma nova empresa e seu administrador inicial**, para que **o tenant exista com configuração e funil padrão**.
- Como **administrador global**, quero **inativar uma empresa**, para que **ninguém daquela organização acesse o CRM** até reativação.
- Como **administrador da empresa**, quero **cadastrar e inativar usuários com perfil adequado**, para que **a equipe opere com o mínimo de privilégio**.

### Funil e leads

- Como **usuário comercial**, quero **ver o funil com colunas por estágio e cartões de leads**, para que **eu entenda o estágio de cada oportunidade de relance**.
- Como **usuário comercial**, quero **mover um lead para outro estágio e reordenar dentro da coluna**, para que **o funil reflita o estado real da negociação**, sem inconsistência de posição.
- Como **usuário comercial**, quero **criar e editar leads com validações claras**, para que **dados mínimos existam antes de avançar** (título, contato, estágio da mesma empresa).
- Como **usuário comercial**, quero **filtrar e buscar leads**, para que **eu encontre oportunidades rapidamente**.

### Interação e conversão

- Como **usuário comercial**, quero **registrar comentários no histórico do lead**, para que **a equipe tenha contexto das interações**.
- Como **usuário comercial**, quero **converter um lead em cliente quando estiver qualificado**, para que **o cadastro formal exista sem duplicar e-mail/telefone na mesma empresa**.
- Como **administrador da empresa**, quero **definir e ordenar estágios, cores e ativação**, para que **o funil represente o processo comercial da minha empresa**, sem apagar estágio com leads vinculados.

### Clientes e documentos

- Como **usuário comercial**, quero **cadastrar e manter clientes**, para que **a base formal esteja disponível para relacionamento e relatórios**.
- Como **usuário comercial**, quero **anexar documentos permitidos ao cliente**, para que **comprovantes e contratos fiquem centralizados**, com acesso controlado.

### Relatórios e comunicação

- Como **administrador ou usuário comercial**, quero **relatórios agregados só da minha empresa**, para que **eu tome decisões sem vazar dados de outros tenants**.
- Como **administrador da empresa**, quero **enviar e-mail personalizado a aniversariantes com substituição de macros**, para que **a comunicação seja ágil** desde que o SMTP esteja configurado.

### Configuração e perfil

- Como **administrador da empresa**, quero **configurar SMTP e testar envio**, para que **e-mails transacionais e de aniversário funcionem**.
- Como **administrador da empresa**, quero **ajustar identidade (nome, cores, logo, contatos públicos)**, para que **a aplicação reflita a marca da empresa** onde o produto prever.
- Como **qualquer usuário autenticado**, quero **atualizar meu perfil e senha com regras claras**, para que **eu mantenha meus dados corretos**.

---

## 8. Regras de negócio críticas

1. Toda entidade de negócio relevante está vinculada **direta ou indiretamente** à **empresa**; consultas e exportações **nunca** misturam tenants.
2. Usuário comum só acessa dados da **própria empresa**; usuário **inativo** ou empresa **inativa** não acessa áreas do CRM.
3. Lead **sempre** pertence a um **estágio** e a uma **empresa**; não mover lead para estágio de outra empresa.
4. Responsável pelo lead, quando existir, deve ser **usuário da mesma empresa**.
5. **Conversão** exige **e-mail e telefone** preenchidos no lead; verificar duplicidade de cliente por **e-mail ou telefone dentro da empresa**; manter o lead marcado como convertido **sem** apagar o lead automaticamente (recomendado).
6. **Comentários** são removidos em cascata lógica com o lead.
7. **Exclusão de estágio** somente se **não houver leads** vinculados; manter **pelo menos um estágio ativo** por empresa.
8. **Upload:** bloquear executáveis e scripts e validar tipo de conteúdo de forma confiável (não confiar só na extensão); limitar tamanho; servir download por **controle de autorização**.
9. **Recuperação de senha:** token **único**, **uso único**, **expiração curta** (referência de projeto: **1 hora**).
10. **Login com falha:** mensagem **genérica** (não revelar se o e-mail existe).
11. **Proteção de formularações mutáveis:** exigir mecanismo contra **requisição cruzada forjada** nos fluxos que alteram estado (ex.: campos de validação de sessão/formulário).
12. **Relatórios** e listagens respeitam **moeda e datas no padrão brasileiro** na apresentação ao usuário final.
13. **E-mail em lote (aniversariantes):** continuar processando destinatários mesmo com falhas pontuais; apresentar **resumo** de enviados e falhas.
14. **Usuários:** e-mail único no sistema; **não inativar o único administrador ativo** da empresa.

---

## 9. Modelo conceitual de dados (sem implementação)

Entidades principais e relações (texto):

- **Empresa** 1—N **Usuário**; 1—N **Estágio**; 1—N **Lead**; 1—N **Cliente**; 1—1 **Configuração da empresa** (exatamente uma por empresa).
- **Lead** N—1 **Estágio**; opcional N—1 **Usuário responsável**; 1—N **Comentário**; opcional vínculo ao **Cliente** após conversão e flags de conversão.
- **Cliente** 1—N **Arquivo do cliente** (metadados + referência ao armazenamento).
- **Token de redefinição de senha** (se modelado): N—1 **Usuário**, com expiração e carimbo de uso.

Atributos conceituais alinhados ao MVP (não normativos de tipos técnicos):

- **Empresa:** nome, nome fantasia, documento opcional, contatos, site, ativa, auditoria de criação/atualização.
- **Usuário:** empresa, nome, e-mail, perfil, ativo, credenciais geridas com boas práticas de armazenamento de segredo.
- **Estágio:** empresa, nome, ordem, cor, ativo, tipo de resultado opcional.
- **Lead:** empresa, título, contato, telefone, e-mail, fonte, valor estimado, estágio, responsável, observações, posição, indicadores de conversão e datas.
- **Comentário:** lead, autor, conteúdo, data.
- **Cliente:** empresa, nome, e-mail, telefone, fonte, sexo, data de nascimento, observações, datas.
- **Arquivo do cliente:** empresa, cliente, título, referência ao binário, tipo, tamanho, opcional enviado por, data.
- **Configuração da empresa:** identidade visual, contatos públicos, parâmetros SMTP (armazenar segredos com proteção adequada).

---

## 10. Fluxos do produto (independentes de UI)

**Onboarding de empresa:** operador cria empresa → sistema cria configuração padrão e estágios padrão → cria administrador inicial → administrador ajusta SMTP, usuários e identidade.

**Login:** credenciais válidas + usuário ativo + empresa ativa → acesso ao painel principal do produto.

**Movimentação no funil:** carregar estágios ativos ordenados e leads por estágio → alterar estágio/posição com validação de pertencimento ao tenant → persistir de forma transacional para evitar posições duplicadas.

**Conversão:** validar lead do tenant → exigir e-mail e telefone → checar duplicidade de cliente → criar cliente e marcar lead convertido.

**Aniversariantes:** filtrar clientes do período **da empresa** → selecionar destinatários com e-mail → substituir macros → enviar via SMTP da empresa → resumo.

---

## 11. Requisitos não funcionais (alto nível, agnósticos)

- **Segurança:** isolamento por tenant em todas as operações; gestão segura de segredos (SMTP, chaves); política de senha e bloqueio de conta podem ser definidas na camada de implementação sem contrariar as regras acima.
- **Consistência:** operações que envolvem reordenação de leads devem ser **atômicas** no sentido de negócio (sem estados intermediários visíveis que quebrem ordenação).
- **Confiabilidade:** falhas de envio de e-mail não devem corromper dados já persistidos; registrar falhas para exibição ao operador.
- **Rastreabilidade mínima:** comentários e metadados de conversão fornecem histórico operacional; auditoria forense completa fica fora do MVP (ver roadmap pós-MVP na seção 12).
- **Desempenho:** listagens e relatórios devem suportar paginação ou equivalente quando o volume crescer (detalhes de infra ficam para o projeto de engenharia).

---

## 12. Roadmap geral (pós-MVP)

Este roadmap ordena **o trabalho depois do MVP** descrito nas seções **5**, **6** e **8**. Ele consolida a priorização implícita do material de produto mais detalhado (`PRD_spec.md`, seção «Sugestões de Melhorias Pós-MVP») com itens já explicitados como **fora do escopo do MVP** (seção 6 deste documento).

**Princípios de ordenação:** (1) **monetização e governança** antes de criar forte dependência externa em integrações; (2) **dados exportáveis e API** antes de automações pesadas; (3) **canais de conversa e produtividade** em seguida; (4) **documentos formais e verticais** depois da base estar madura; (5) **inteligência e experiências avançadas** por último.

As fases são **guias**, não cronogramas fixos — podem sobrepor dentro de uma release desde que isolamento entre tenants e regras de negócio críticas sejam preservados.

### 12.1 Fase P1 — Monetização, permissões e rastre

Centraliza **o que precisa existir para o SaaS ser comercializado e supervisionado**: planos/limites, gateway (quando houver cobrança), permissões mais finas que o MVP, soft delete, auditoria e endurecimento de segurança. Parte desses temas aparece também na seção **6** («fora do escopo do MVP»).

| Tema | Conteúdo esperado |
|------|-------------------|
| **Planos SaaS** | Planos diferenciados, limites (usuários, leads, armazenamento ou equivalente), integração com gateway de pagamento e bloqueio por inadimplência. |
| **Permissões granulares** | Permissões finas (excluir lead, exportar dados, ver só leads próprios, relatórios sensíveis, alterar configurações). |
| **Soft delete** | Exclusão lógica com recuperação e política de retenção, priorizando lead, cliente, usuário, arquivo e estágio. |
| **Auditoria** | Log de alterações relevantes e eventos de acesso exportável (criação/movimento de lead, conversão, configurações, login e falhas). |
| **Hardening** | MFA onde fizer sentido; políticas de sessão e bloqueios; SMTP de **homologação** para testes sem afetar clientes reais. |

### 12.2 Fase P2 — Portabilidade, API e modelo de dados extensível

| Tema | Conteúdo esperado |
|------|-------------------|
| **Importação / exportação** | CSV ou equivalente para leads e clientes, com pré-visualização e validação antes de gravar massa. |
| **API para integrações** | API estável/versionada para receber ou consultar leads, status e integrações com formulários e landing pages. |
| **Webhooks** | Notificações assíncronas por eventos (ex.: movimentação ou conversão de lead), alinhadas à segurança multiempresa. |
| **Campos personalizados** | Atributos configuráveis por empresa em lead/cliente onde o produto suportar. |

### 12.3 Fase P3 — Canais externos, automação e operação diária

| Tema | Conteúdo esperado |
|------|-------------------|
| **WhatsApp / mensagens** | Evolução de deep link até integrações oficiais, templates e registro manual de contato quando necessário (**LGPD** e consentimento). |
| **Automação comercial** | Regras (ex.: mensagem ao mudar estágio, alertas de lead parado, ajustes de prioridade quando existirem). |
| **Tarefas e lembretes** | Tarefas ligadas a lead/cliente com vencimento, responsável e notificações internas. |
| **Desempenho operacional** | Fila/processamento **assíncrono** para envio em massa e retentativa; metas por usuário ou equipe e visões por tempo médio por estágio. |

### 12.4 Fase P4 — Propostas, documentos formais e verticais

| Tema | Conteúdo esperado |
|------|-------------------|
| **Propostas comerciais** | Documento ligado ao lead: itens, valor, validade, status; geração de PDF opcional envio por e-mail. |
| **Módulos verticais** | Ex.: **imobiliário** (corretores, imóveis, vínculos com leads) como extensão do CRM genérico, não substituto dele. |
| **Escopo já excluído do MVP relacionado** | Assinatura digital e propostas “enterprise” ficam próximos desta fase ou seguinte conforme estratégia. |

### 12.5 Fase P5 — Inteligência e experiência diferenciada

| Tema | Conteúdo esperado |
|------|-------------------|
| **Inteligência comercial** | Score de lead, previsão de fechamento, próximas ações sugeridas, detecção de leads parados, resumos de histórico; **classificação automática** alinhada a governança de dados e transparência. |

### 12.6 Fase P6 — Mobilidade nativa e ecossistema alargado (longo prazo)

| Tema | Conteúdo esperado |
|------|-------------------|
| **Apps nativos** | Aplicações móveis dedicadas apenas quando há demanda estável ou requisitos de hardware (push, offline). |

### 12.7 Relação rápida: seção 6 × fases deste roadmap

| Item fora do escopo do MVP (seção 6) | Fase típica no roadmap |
|-------------------------------------|-------------------------|
| Cobrança/gateway/planos/limites | P1 |
| Integrações WhatsApp/redes sociais | P3 |
| Automação avançada / tarefas lembretes | P3 |
| Imobiliário / propostas / assinatura digital | P4 |
| IA classificação de leads | P5 |
| API pública + webhooks | P2–P4 (contrato público na P2; webhooks já na maturação da API) |
| Soft delete | P1 |
| Importação/exportação em massa | P2 |
| App mobile nativo | P6 |

---

## 13. Instruções de execução e implantação (agnósticas)

Esta seção descreve **o que precisa existir e em que ordem** para a aplicação cumprir o PRD, **sem** prescrever linguagem, provedor cloud ou ferramentas específicas.

### 13.1 Pré-requisitos de ambiente

- **Instância da aplicação** acessível por HTTPS em produção (recomendado para qualquer ambiente com dados reais).
- **Banco de dados relacional** com suporte a transações para operações de funil e cadastros.
- **Armazenamento de arquivos** (disco gerenciado, objeto ou serviço equivalente) para logos e documentos de clientes, com backup.
- **Serviço de envio de e-mail** acessível via **SMTP** ou abstração equivalente, configurável **por empresa** no produto.
- **Segredos** (senhas SMTP, chaves de assinatura de tokens, credenciais de banco) fora do código-fonte, injetados por variáveis ou cofre de segredos da organização que implanta.

### 13.2 Configuração mínima antes do primeiro uso

1. Provisionar infraestrutura (aplicação, banco, armazenamento, fila apenas se adotada).
2. Executar migrações de esquema ou equivalentes para criar entidades conceituais da seção 9.
3. Definir política de **tamanho máximo de upload** e lista de tipos/extensões **bloqueados** compatível com a seção 8.
4. Criar o **primeiro administrador global** (ou usuário técnico de bootstrap seguro política da organização).
5. Registrar a **primeira empresa** pelo fluxo oficial; validar que estágios padrão e configuração padrão foram criados.
6. Entregar credenciais do **administrador da empresa** por canal seguro.

### 13.3 Checklist por empresa (tenant) em go-live

- [ ] Empresa marcada como ativa e dados cadastrais conferidos.
- [ ] Pelo menos **um estágio ativo**; estágios alinhados ao processo comercial real da empresa.
- [ ] Perfis dos usuários revistos; **pelo menos um administrador ativo**.
- [ ] SMTP testado com envio de prova **para endereço controlado**.
- [ ] Logo e cores validados (contraste aceitável — critérios de marca ficam com o cliente).
- [ ] Procedimento de **backup/restauração** do banco e do armazenamento de arquivos definido pela operação de TI.
- [ ] Política de **exclusões** comunicada aos usuários (permanentes no MVP, salvo projeto decidir diferente).

### 13.4 Operação contínua

- Monitorar falhas de envio de e-mail e consumo de armazenamento.
- Rever periodicamente usuários inativos e permissões após mudanças de equipe.
- Ao **inativar empresa**, garantir revogação imediata de sessões válidas conforme capacidade da implementação.

### 13.5 Critérios de aceite globais (“pronto para considerar MVP atendido”)

- Dois tenants distintos com dados sem possibilidade de leitura cruzada em todas as operações cobertas pelo escopo (testes automatizados ou manuais documentados pela equipe técnica).
- Fluxos de login, recuperação de senha, funil completo até conversão em cliente documentados e repetíveis.
- Upload de arquivo bloqueando ao menos categorias equivalentes aos executáveis listados na origem (ajustável por projeto mantendo princípio de segurança).
- Relatórios respondendo apenas dados do tenant atual.
- Envio para aniversariantes produzindo resumo de sucessos e falhas sem corromper cadastros.

---

**Referência:** consolidação a partir das especificações detalhadas em `PRD_spec.md`; trechos tecnológicos (framework, ORM, banco nominado, rotas exemplo) foram **generalizados** para este PRD inicial.
