# Especificações do Produto - CRM

## 1. Visão Geral do Produto

O produto é um sistema CRM (Customer Relationship Management) web especializado na gestão de leads e clientes. A proposta central é organizar o funil de vendas através de um pipeline visual (Kanban), permitindo que equipes de vendas acompanhem oportunidades desde o primeiro contato até o fechamento. O sistema também oferece cadastro detalhado de clientes, anexação de documentos, relatórios analíticos e ferramentas de comunicação como envio de e-mails para aniversariantes.

Aparentemente, o sistema possui uma dualidade de branding: partes do código sugerem origem em um CRM para gestão de eventos (casamentos, festas, corporativos), enquanto outras partes indicam adaptação para o mercado imobiliário, incluindo estruturas de banco de dados para corretores e imóveis. No entanto, a implementação atual funcional concentra-se na gestão genérica de leads e clientes.

O produto parece ser uma ferramenta interna ou SaaS voltada para pequenas e médias empresas que precisam de um controle simples e direto de suas oportunidades de negócio sem a complexidade de plataformas enterprise.

## 2. Objetivos do Produto

- **Para corretores/vendedores**: Organizar visualmente as oportunidades de vendas em um funil, acompanhar o histórico de interações, converter leads em clientes formalizados e gerenciar documentação relacionada.
- **Para operadores/administradores**: Configurar os estágios do pipeline de vendas, personalizar a identidade da aplicação, gerar relatórios sobre desempenho e demografia, e manter a base de dados de contatos atualizada.
- **Para o negócio/organização**: Centralizar o controle de oportunidades em um único lugar, reduzir a perda de leads, obter visibilidade sobre fontes de lead mais efetivas, e automatizar comunicações rotineiras como mensagens de aniversário.

## 3. Áreas de Negócio

### 3.1 Autenticação e Segurança

**Propósito**: Controlar o acesso ao sistema e garantir a segurança das contas.

**Roles envolvidas**: Todos os usuários.

**Telas/Rotas**:
- `/crm/login` - Tela de login
- `/crm/forgot` - Recuperação de senha
- `/crm/reset` - Redefinição de senha via token
- `/crm/logout` - Encerramento de sessão

**Fluxo principal**:
1. Usuário informa e-mail e senha.
2. Sistema valida credenciais contra a base de usuários.
3. Em caso de sucesso, inicia sessão e redireciona para o dashboard.
4. Em caso de falha, exibe mensagem de erro genérica por segurança.

**Fluxo de recuperação de senha**:
1. Usuário solicita recuperação informando e-mail.
2. Sistema gera token único com validade de 1 hora.
3. Envia e-mail com link contendo o token.
4. Usuário acessa o link e define nova senha.
5. Token é marcado como utilizado.

**Restrições e validações**:
- Senhas são armazenadas com hash criptográfico.
- Todos os formulários possuem proteção CSRF.
- Tokens de redefinição expiram automaticamente.

### 3.2 Dashboard e Pipeline de Leads (Kanban)

**Propósito**: Visualizar e gerenciar o funil de vendas de forma intuitiva através de colunas e cards arrastáveis.

**Roles envolvidas**: Usuários autenticados.

**Telas/Rotas**:
- `/` ou `/crm` - Dashboard principal com visualização Kanban

**Campos ou objetos principais**:
- Estágios do funil (colunas)
- Leads (cards)
- Posição do lead dentro do estágio

**Etapas do fluxo**:
1. Sistema carrega todos os estágios ativos ordenados por `sort_order`.
2. Para cada estágio, carrega os leads associados ordenados por `position`.
3. Usuário pode arrastar um lead para outro estágio ou reordenar dentro do mesmo estágio.
4. Ao soltar, sistema atualiza `stage_id` e recalcula as `position` dos leads afetados.
5. É possível abrir detalhes do lead em modal, excluir lead ou convertê-lo em cliente.

**Status e estados de ciclo de vida**:
- Leads transitam entre estágios configuráveis (ex: Novo Lead, Contato Inicial, Qualificado, Proposta Enviada, Negociação, Fechado - Ganhou, Fechado - Perdeu).
- Estágios podem ser ativados ou desativados, mas não excluídos se contiverem leads vinculados.

**Endpoints ou ações de API**:
- `POST /crm/api/move-lead` - Move lead entre estágios ou reordena
- `POST /crm/api/delete-lead` - Exclui lead permanentemente
- `GET /crm/api/lead-details` - Retorna detalhes de um lead para modal

### 3.3 Gestão de Leads

**Propósito**: Cadastrar, editar, listar e pesquisar leads com dados de contato e valor estimado.

**Roles envolvidas**: Usuários autenticados.

**Telas/Rotas**:
- `/crm/leads` - Listagem paginada de leads com filtros
- `/crm/lead/new` - Formulário de novo lead
- `/crm/lead/{id}` - Edição de lead existente

**Campos ou objetos principais**:
- Título da oportunidade
- Nome do cliente
- Telefone, e-mail
- Fonte de origem (Site, Indicação, WhatsApp, Redes Sociais, Telefone, etc.)
- Valor estimado (DECIMAL)
- Estágio atual
- Responsável/atribuído
- Anotações/observações

**Restrições e validações**:
- Campos obrigatórios: título, nome do cliente, estágio.
- Conversão para cliente exige que o lead possua e-mail e telefone preenchidos.

### 3.4 Gestão de Clientes

**Propósito**: Manter uma base formal de clientes convertidos ou cadastrados diretamente, com dados pessoais e documentação anexada.

**Roles envolvidas**: Usuários autenticados.

**Telas/Rotas**:
- `/crm/clients` - Listagem de clientes
- `/crm/client/new` - Novo cliente
- `/crm/client/{id}` - Editar cliente

**Campos ou objetos principais**:
- Nome completo
- E-mail (único)
- Telefone (único)
- Fonte de origem
- Sexo (M/F/O)
- Data de nascimento
- Anotações
- Arquivos/documentos anexados

**Etapas do fluxo**:
1. Usuário cadastra cliente manualmente ou converte a partir de um lead.
2. Sistema verifica duplicidade por e-mail ou telefone.
3. Usuário pode anexar documentos (bloqueados arquivos de risco como executáveis e scripts).
4. Arquivos são organizados em pasta dedicada ao cliente.
5. Exclusão de cliente remove também os arquivos físicos anexados.

**Ação de API**:
- `POST /crm/api/client-from-lead` - Converte lead em cliente, copiando dados e verificando duplicidade

### 3.5 Configuração do Funil (Estágios)

**Propósito**: Personalizar os estágios do pipeline de vendas conforme o processo comercial da empresa.

**Roles envolvidas**: Usuários autenticados (aparentemente todos têm acesso, sem restrição de role).

**Telas/Rotas**:
- `/crm/stages` - Gerenciamento de estágios

**Campos ou objetos principais**:
- Nome do estágio
- Ordem de exibição
- Cor identificativa (hexadecimal)
- Status ativo/inativo

**Restrições e validações**:
- Não é possível excluir um estágio que contenha leads vinculados.
- Ordem de exibição é controlada pelo campo `sort_order`.

### 3.6 Relatórios e Análises

**Propósito**: Gerar visões analíticas sobre leads, clientes e demografia para apoiar decisões de negócio.

**Roles envolvidas**: Usuários autenticados.

**Telas/Rotas**:
- `/crm/reports` - Relatório de leads por estágio e fonte
- `/crm/reports/birthdays` - Aniversariantes do mês
- `/crm/reports/demographics` - Distribuição por idade e sexo

**Funcionalidades**:
- Filtro por período de criação.
- Gráficos de leads por estágio e por fonte.
- Lista de aniversariantes do dia com possibilidade de envio de e-mail em massa.
- Distribuição demográfica por faixas etárias e sexo.

### 3.7 Configurações do Sistema

**Propósito**: Personalizar a identidade da aplicação e configurar integrações de e-mail.

**Roles envolvidas**: Usuários autenticados.

**Telas/Rotas**:
- `/crm/settings` - Configurações gerais

**Campos ou objetos principais**:
- Nome da aplicação
- E-mail público, site, WhatsApp
- Cores primária e secundária
- Logo (imagem quadrada, máximo 100x100px)
- Configuração SMTP completa (host, porta, segurança, usuário, senha, remetente)

**Funcionalidades**:
- Teste de envio de e-mail para validar configuração SMTP.
- Macros de template para comunicações (`{{nome}}`, `{{site}}`, `{{whatsapp}}`, `{{email}}`).

### 3.8 Perfil do Usuário

**Propósito**: Permitir que o usuário logado gerencie seus próprios dados e senha.

**Roles envolvidas**: Usuário autenticado (próprio perfil).

**Telas/Rotas**:
- `/crm/profile` - Edição de perfil

**Campos ou objetos principais**:
- Nome
- E-mail
- Alteração de senha (senha atual + nova senha + confirmação)

## 4. Modelos de Dados

### 4.1 crm_users

Representa os usuários que têm acesso ao sistema.

```text
- id (INT, PK, Auto Increment)
- name (VARCHAR 120)
- email (VARCHAR 255, UNIQUE)
- password_hash (VARCHAR 255)
- created_at (DATETIME)
```

### 4.2 crm_lead_stages

Representa as colunas/etapas do funil de vendas.

```text
- id (INT, PK, Auto Increment)
- name (VARCHAR 100)
- sort_order (INT)
- is_active (TINYINT, default 1)
- color (CHAR 7, default '#64748b')
```

### 4.3 crm_leads

Representa as oportunidades de negócio no funil.

```text
- id (INT, PK, Auto Increment)
- title (VARCHAR 255)
- client_name (VARCHAR 255)
- phone (VARCHAR 50, NULL)
- email (VARCHAR 255, NULL)
- source (VARCHAR 100, NULL) - ex: Site, Indicação, WhatsApp, Redes Sociais, Telefone
- value (DECIMAL 12,2, NULL)
- stage_id (INT, FK -> crm_lead_stages)
- assigned_user_id (INT, NULL, FK -> crm_users)
- notes (TEXT, NULL)
- position (INT, default 0)
- created_at (DATETIME)
- updated_at (DATETIME, NULL)
```

**Relacionamentos**:
- `stage_id` -> `crm_lead_stages.id` (RESTRICT)
- `assigned_user_id` -> `crm_users.id` (ON DELETE SET NULL)

### 4.4 crm_lead_comments

Representa as interações/comentários associados a um lead.

```text
- id (INT, PK, Auto Increment)
- lead_id (INT, FK -> crm_leads)
- user_id (INT, NULL, FK -> crm_users)
- content (TEXT)
- created_at (DATETIME)
```

**Relacionamentos**:
- `lead_id` -> `crm_leads.id` (ON DELETE CASCADE)
- `user_id` -> `crm_users.id` (ON DELETE SET NULL)

### 4.5 crm_clients

Representa clientes formalizados na base.

```text
- id (INT, PK, Auto Increment)
- name (VARCHAR 255)
- email (VARCHAR 255, NULL, UNIQUE)
- phone (VARCHAR 50, NULL, UNIQUE)
- source (VARCHAR 100, NULL)
- sex (ENUM: 'M','F','O', NULL)
- birth_date (DATE, NULL)
- notes (TEXT, NULL)
- created_at (DATETIME)
- updated_at (DATETIME, NULL)
```

**Constraints**:
- UNIQUE em `email`
- UNIQUE em `phone`

### 4.6 crm_client_files

Representa documentos e arquivos anexados a um cliente.

```text
- id (INT, PK, Auto Increment)
- client_id (INT, FK -> crm_clients)
- title (VARCHAR 255)
- path (VARCHAR 500)
- mime (VARCHAR 100, NULL)
- size (INT, NULL)
- created_at (DATETIME)
```

**Relacionamentos**:
- `client_id` -> `crm_clients.id` (ON DELETE CASCADE)

### 4.7 crm_config

Configuração singleton da aplicação (registro único com id=1).

```text
- id (TINYINT, PK, default 1)
- app_name (VARCHAR 255, default 'CRM Imobiliária')
- public_email (VARCHAR 255, NULL)
- public_site_url (VARCHAR 255, NULL)
- public_whatsapp (VARCHAR 50, NULL)
- primary_color (CHAR 7, default '#0ea5e9')
- secondary_color (CHAR 7, default '#0f172a')
- logo_path (VARCHAR 500, NULL)
- smtp_host (VARCHAR 255, NULL)
- smtp_port (INT, NULL)
- smtp_secure (ENUM: 'none','ssl','tls', default 'none')
- smtp_user (VARCHAR 255, NULL)
- smtp_pass (VARCHAR 255, NULL)
- smtp_from_email (VARCHAR 255, NULL)
- smtp_from_name (VARCHAR 255, NULL)
- created_at (DATETIME)
- updated_at (DATETIME, NULL)
```

### 4.8 crm_password_resets

Tokens para recuperação de senha.

```text
- id (INT, PK, Auto Increment)
- user_id (INT, FK -> crm_users)
- token (CHAR 64, UNIQUE)
- expires_at (DATETIME)
- used_at (DATETIME, NULL)
- created_at (DATETIME)
```

**Relacionamentos**:
- `user_id` -> `crm_users.id` (ON DELETE CASCADE)

### 4.9 Tabelas Imobiliárias (Estruturas Reservadas)

Aparentemente, o sistema possui estruturas de banco para módulo imobiliário, mas sem implementação funcional de rotas ou telas no momento:

**corretores**:
```text
- id (INT, PK)
- nome (VARCHAR)
- foto (VARCHAR)
- creci (VARCHAR)
- email (VARCHAR)
- whatsapp (VARCHAR)
- created_at (DATETIME)
- updated_at (DATETIME)
```

**imoveis**:
```text
- id (INT, PK)
- titulo (VARCHAR)
- descricao (TEXT)
- tipo (VARCHAR)
- finalidade (ENUM: venda/aluguel/temporada)
- preco (DECIMAL)
- area (DECIMAL)
- quartos, suites, banheiros, vagas_garagem (INT)
- endereco, cidade, estado, cep (VARCHAR)
- latitude, longitude (DECIMAL)
- status (ENUM: ativo/inativo/vendido/alugado)
- condominio, iptu, andar, ano_construcao (VARCHAR/INT)
- caracteristicas (JSON)
- corretor_id (FK -> corretores)
- data_criacao (DATETIME)
- data_atualizacao (DATETIME)
```

**imoveis_imagens**:
```text
- id (INT, PK)
- imovel_id (FK -> imoveis)
- arquivo (VARCHAR)
- ordem (INT)
- principal (TINYINT)
- created_at (DATETIME)
```

## 4.1 Banco de Dados e Persistência

- **Tipo/vendor**: MySQL/MariaDB (InnoDB, utf8mb4).
- **Engine e charset**: InnoDB com charset utf8mb4, permitindo caracteres Unicode completos.
- **Migrations/Seed data**: O schema é definido em `schema.sql` e replicado em `setup.php`. O seed inclui um usuário administrador inicial, 7 estágios de vendas padrão, 5 leads de exemplo e configuração padrão.
- **Relacionamentos e cardinalidade**:
  - Um estágio possui muitos leads (1:N).
  - Um usuário pode ter muitos leads atribuídos (1:N).
  - Um lead possui muitos comentários (1:N).
  - Um cliente possui muitos arquivos (1:N).
  - Um corretor pode ter muitos imóveis (1:N) - estrutura reservada.
  - Um imóvel pode ter muitas imagens (1:N) - estrutura reservada.
- **Constraints e índices**:
  - UNIQUE em `crm_users.email`.
  - UNIQUE em `crm_clients.email`.
  - UNIQUE em `crm_clients.phone`.
  - UNIQUE em `crm_password_resets.token`.
  - Foreign keys com RESTRICT, CASCADE ou SET NULL conforme apropriado.
- **Regras de posse e visibilidade**: Não há isolamento de dados por usuário ou equipe. Todos os usuários autenticados visualizam e manipulam todos os leads e clientes.
- **Ciclo de vida e retenção**:
  - Leads podem ser excluídos permanentemente (hard delete).
  - Clientes excluídos provocam cascade nos arquivos anexados.
  - Tokens de redefinição de senha expiram em 1 hora (`expires_at`) e são marcados como usados (`used_at`).
  - Timestamps `created_at` e `updated_at` são mantidos nas principais entidades.
- **Soft delete**: Não há implementação de soft delete. Todas as exclusões são permanentes.
- **Padrões de leitura/escrita**: Queries diretas com prepared statements. Leituras são feitas com JOINs quando necessário (ex: listagem de leads com nome do estágio). Escritas de movimentação de leads envolvem atualização de `stage_id` e recálculo de `position`.

## 5. Fluxos de Usuário

### 5.1 Fluxo de Cadastro/Primeiro Acesso

1. Administrador executa o setup inicial acessando `/crm/setup`.
2. Sistema cria as tabelas no banco de dados e insere dados iniciais.
3. Usuário acessa `/crm/login` e utiliza as credenciais padrão criadas no setup.
4. Após login, é redirecionado para o dashboard Kanban.

### 5.2 Fluxo de Gestão de Leads no Kanban

1. Usuário acessa o dashboard (`/` ou `/crm`).
2. Sistema exibe colunas correspondentes aos estágios ativos ordenados.
3. Em cada coluna, exibe os leads ordenados por posição.
4. Usuário pode:
   - Arrastar um lead para outra coluna para mudar de estágio.
   - Reordenar leads dentro da mesma coluna.
   - Clicar em um lead para visualizar detalhes em modal.
   - Excluir um lead (com confirmação).
   - Converter o lead em cliente (se houver e-mail e telefone).
5. Ao mover um lead, o sistema atualiza `stage_id` e recalcula `position` via API AJAX.

### 5.3 Fluxo de Conversão Lead -> Cliente

1. No Kanban ou na listagem de leads, usuário aciona a conversão.
2. Sistema verifica se o lead possui `email` e `phone` preenchidos.
3. Se sim, verifica se já existe cliente com o mesmo e-mail ou telefone.
4. Se cliente já existir, retorna o cliente existente.
5. Se não existir, cria novo registro em `crm_clients` copiando `client_name`, `email`, `phone`, `source` e `notes`.
6. Ícone/status de conversão é atualizado visualmente.

### 5.4 Fluxo de Cadastro e Gestão de Clientes

1. Usuário acessa `/crm/clients` e clica em "Novo Cliente".
2. Preenche nome, e-mail, telefone, sexo, data de nascimento, fonte e anotações.
3. Sistema valida unicidade de e-mail e telefone.
4. Usuário pode anexar documentos na edição do cliente.
5. Arquivos são validados contra extensões perigosas e salvos em pasta dedicada.
6. Usuário pode excluir cliente, o que remove o registro e todos os arquivos físicos associados.

### 5.5 Fluxo de Relatório e Comunicação com Aniversariantes

1. Usuário acessa `/crm/reports/birthdays`.
2. Sistema lista clientes com aniversário no dia atual.
3. Usuário pode selecionar aniversariantes e redigir mensagem de e-mail.
4. Sistema utiliza configuração SMTP para envio em massa.
5. Macros como `{{nome}}`, `{{site}}`, `{{whatsapp}}` e `{{email}}` são substituídas por valores reais.

### 5.6 Fluxo de Configuração do Sistema

1. Usuário acessa `/crm/settings`.
2. Altera nome da aplicação, dados de contato público, cores e logo.
3. Configura parâmetros SMTP para envio de e-mails.
4. Realiza teste de envio para validar configuração.
5. Alterações são persistidas na tabela `crm_config` (registro único id=1).

## 6. Regras de Negócio

1. **Pipeline de Leads**: Leads devem sempre estar vinculados a um estágio ativo. A ordenação dentro do estágio é controlada pelo campo `position`.
2. **Exclusão de Estágios**: Um estágio que contenha um ou mais leads vinculados não pode ser excluído.
3. **Conversão Lead-Cliente**: A conversão só é permitida se o lead possuir e-mail e telefone preenchidos.
4. **Unicidade de Clientes**: Não é permitido cadastrar dois clientes com o mesmo e-mail ou o mesmo telefone.
5. **Duplicidade na Conversão**: Se já existir cliente com o e-mail ou telefone do lead, o sistema retorna o cliente existente em vez de criar um novo.
6. **Segurança de Upload**: Arquivos com extensões consideradas de risco (`php`, `phtml`, `phar`, `exe`, `bat`, `cmd`, `sh`, `js`, `cgi`, `pl`) são bloqueados no upload.
7. **Logo**: A imagem do logo deve ser quadrada (proporção 1:1) e ter dimensões máximas de 100x100 pixels.
8. **Proteção CSRF**: Todas as requisições de modificação (POST, APIs AJAX) devem incluir token CSRF válido.
9. **Recuperação de Senha**: Tokens de redefinição têm validade de 1 hora e só podem ser utilizados uma vez.
10. **Envio de E-mail em Massa**: Aniversariantes do dia podem receber e-mails personalizados com macros substituídas dinamicamente.
11. **Acesso a Dados**: Todos os usuários autenticados têm acesso a todos os dados do sistema; não há isolamento por usuário, equipe ou role.
12. **Soft Delete Inexistente**: Exclusões de leads, clientes, estágios e arquivos são permanentes e irreversíveis.

## 7. Tipos de Usuário e Permissões

### 7.1 Usuário Autenticado

Atualmente, o sistema possui apenas um tipo de usuário. Não há distinção de roles, papéis ou permissões granulares.

**Permissões**:
- Criar, visualizar, editar e excluir leads.
- Criar, visualizar, editar e excluir clientes.
- Converter leads em clientes.
- Anexar e excluir arquivos de clientes.
- Configurar estágios do funil.
- Visualizar relatórios e enviar e-mails para aniversariantes.
- Configurar parâmetros do sistema (SMTP, branding).
- Gerenciar seu próprio perfil e senha.

**Matriz de Permissões Simplificada**:

| Recurso | Usuário Autenticado | Não Autenticado |
|---------|---------------------|-----------------|
| Login/Recuperar senha | Sim | Sim |
| Dashboard Kanban | Sim | Não |
| CRUD de Leads | Sim | Não |
| CRUD de Clientes | Sim | Não |
| Configurar Estágios | Sim | Não |
| Relatórios | Sim | Não |
| Configurações do Sistema | Sim | Não |
| Perfil Próprio | Sim | Não |

## 8. Arquitetura e Design System do Backend

### 8.1 Limites e Responsabilidades de Módulos

O sistema é organizado como um monolito sem separação estrita em camadas. Os limites funcionais são definidos por arquivos de rota:

- **Autenticação e sessão**: `login.php`, `logout.php`, `forgot.php`, `reset.php`.
- **Pipeline/Kanban**: `index.php`, `api_move_lead.php`, `api_delete_lead.php`, `api_lead_details.php`.
- **Leads**: `leads.php`, `lead_form.php`.
- **Clientes**: `clients.php`, `client_form.php`, `api_client_from_lead.php`.
- **Configurações**: `settings.php`, `stages.php`, `profile.php`.
- **Relatórios**: `reports.php`, `reports_birthdays.php`, `reports_demographics.php`.
- **Setup/Inicialização**: `setup.php`, `schema.sql`.

### 8.2 Padrões de Contrato de API

- **Formato**: APIs internas retornam JSON.
- **Métodos**: Predominantemente POST para ações de modificação, GET para consultas.
- **Autenticação**: Verificação de sessão ativa em todas as rotas protegidas.
- **CSRF**: APIs AJAX exigem token CSRF no header `X-CSRF` ou no body da requisição.
- **Paginação e filtros**: Implementados nas listagens de leads e clientes via parâmetros GET (`page`, `search`, `source`, `stage`, `period_start`, `period_end`).
- **Respostas de erro**: Retornam objeto JSON com campo `success: false` e mensagem descritiva.
- **Respostas de sucesso**: Retornam objeto JSON com campo `success: true` e dados adicionais quando aplicável.

### 8.3 Organização de Domínio/Services/Use Cases

Não há classes de serviço, repositories ou uso de padrão MVC estrito. A lógica de negócio está contida diretamente nos arquivos de rota, com queries PDO executadas no mesmo local. Helpers globais centralizam funções transversais como conexão com banco, geração de tokens CSRF, redirecionamentos e sanitização de saída.

### 8.4 Arquitetura de Persistência

- **Padrão de acesso**: Singleton de conexão PDO com prepared statements em todas as operações de banco observadas.
- **Transações**: Movimentação de leads (reordenação/mudança de estágio) aparentemente utiliza transação para garantir consistência das posições.
- **Ownership**: Não há controle de posse ou tenancy. Todos os registros são visíveis globalmente.
- **Integração com arquivos**: Arquivos de clientes são persistidos em sistema de arquivos local, organizados por ID do cliente. Metadados (nome, caminho, mime, tamanho) ficam no banco.

### 8.5 Padrões de Validação

- Validação de formulários ocorre no server-side antes da persistência.
- Campos obrigatórios são verificados manualmente (ex: título e nome do cliente em leads).
- Unicidade é verificada por queries de existência antes de inserções (clientes).
- Upload de arquivos é validado por extensão e tipo MIME.

### 8.6 Modelo de Permissão/Autenticação

- Baseado em sessão de usuário. Após login bem-sucedido, o ID do usuário é armazenado na sessão.
- Todas as páginas protegidas verificam a existência da sessão válida.
- Não há distinção de roles ou níveis de acesso. Qualquer usuário autenticado tem acesso total.

### 8.7 Ciclo de Vida de Status

- **Leads**: Transitam entre estágios configuráveis. Não há status fechado/finalizado formal; o funil pode conter estágios como "Fechado - Ganhou" e "Fechado - Perdeu" como convenção.
- **Estágios**: Podem ser ativados/desativados (`is_active`). Estágios desativados não aparecem no Kanban.
- **Tokens de senha**: `created_at` -> `expires_at` (1h) -> `used_at` (quando consumido).

### 8.8 Limites de Integração

- **E-mail**: Configuração SMTP genérica para envio de notificações e comunicações em massa.
- **Storage local**: Armazenamento de logos e documentos de clientes em disco local.
- **Impressão/PDF**: Relatórios utilizam conversão client-side para PDF com canvas de gráficos convertidos para imagens PNG.

## 9. Requisitos Não-Funcionais

### 9.1 Performance

- Listagens de leads e clientes são paginadas para evitar carregamento excessivo de dados.
- O dashboard Kanban carrega todos os leads e estágios ativos de uma vez; em bases muito grandes, isso pode impactar performance.

### 9.2 Segurança

- Senhas armazenadas com hash criptográfico (bcrypt).
- Proteção CSRF em todos os formulários e requisições AJAX.
- Prepared statements em todas as queries para mitigar injeção SQL.
- Validação de extensão de arquivos para prevenir upload de arquivos maliciosos.
- Tokens de redefinição de senha possuem tempo de expiração e uso único.

### 9.3 Confiabilidade

- Transações de banco de dados são utilizadas em operações críticas de reordenação de leads para manter consistência.
- Exclusão de clientes utiliza CASCADE para garantir que arquivos anexados também sejam removidos do banco (o sistema também remove arquivos físicos).

### 9.4 Deploy/Operação

- Sistema possui instalador web (`setup.php`) que cria as tabelas e insere dados iniciais.
- Arquivo de configuração não é versionado; um template de exemplo é fornecido.
- Logo e arquivos de upload são persistidos em diretórios locais do servidor.

### 9.5 Observabilidade

- Não há evidência de sistema centralizado de logging ou métricas.
- Erros de envio de e-mail são armazenados em variável de sessão para exibição ao usuário.

## 10. Glossário

- **CRM**: Customer Relationship Management. Sistema para gestão do relacionamento com clientes e oportunidades.
- **Lead**: Potencial cliente ou oportunidade de negócio em um estágio inicial do funil.
- **Cliente**: Pessoa ou entidade formalizada na base de dados, convertida a partir de um lead ou cadastrada diretamente.
- **Estágio / Stage**: Coluna do pipeline que representa uma fase do processo de vendas.
- **Pipeline / Funil de Vendas**: Sequência de estágios que um lead percorre desde o primeiro contato até o fechamento.
- **Kanban**: Visualização em colunas e cards utilizada no dashboard para representar o pipeline.
- **Position**: Ordem de exibição de um lead dentro de um estágio específico.
- **Source / Fonte**: Origem do lead (ex: Site, Indicação, WhatsApp, Redes Sociais, Telefone).
- **Assigned User / Responsável**: Usuário do sistema atribuído como responsável por um lead.
- **CSRF**: Cross-Site Request Forgery. Mecanismo de segurança para garantir que requisições sejam intencionais.
- **SMTP**: Protocolo para envio de e-mails. Configurado nas preferências do sistema.
- **Macro**: Marcador de template (ex: `{{nome}}`) substituído dinamicamente no envio de comunicações.
- **Token de redefinição**: Código temporário para permitir que um usuário redefina sua senha.
- **Soft delete**: Exclusão lógica (não implementada neste sistema; todas as exclusões são permanentes).
