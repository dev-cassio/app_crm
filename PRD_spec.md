<!-- Fonte: conversa compartilhada no ChatGPT -->
<!-- https://chatgpt.com/share/69f7a5e1-01c8-83e9-a323-f49122e73bd9 -->

# Conteúdo exportado da conversa

## Usuário

Me ajude a criar um PRD para um app de um CRM em python e django com as especificações que vou repassar no final. Este PRD deve ser usado como um guia para o modelo na construção do software. Forneça uma versão em que eu possa copiar depois de pronto. Este software vai ser desenvolvido em python e django e vai ser no formato de um SAAS ( Software as a Service ). Todos os nomes que estão em inglês devem ser traduzidos para português Brasileiro. todas as mensagens ao usuário, funções, variáveis deverão ser em português, com exceção de funções que vem das dependências, como o django, por exemplo, onde deve ser mantido o nome original. Você pode Analisar as funcionalidades descritas aqui e sugerir melhorias ou novas funcionalidades, mas estas melhorias e / ou novas funcionalidades deverão ficar em uma seção separada do documento. converta qualquer referencia ao php, pois essa aplicação será feita em outra linguagem, então deve ser agnóstica a linguagem de programação . Aqui está o documento base:

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

## Assistente

Vou transformar o material em um PRD limpo, orientado para desenvolvimento em Django/SaaS, removendo referências a PHP e deixando nomes, rotas conceituais, entidades e regras em português. Também vou separar claramente o escopo principal das sugestões pós-MVP.

Abaixo está uma versão pronta para copiar e usar como PRD para orientar um modelo/agente no desenvolvimento do CRM em **Python + Django**, no formato **SaaS**, com nomenclatura em **português brasileiro** e sem referências diretas a PHP.

# PRD - Sistema CRM SaaS em Python e Django

## 1. Visão Geral do Produto

O produto é um sistema CRM web, desenvolvido em Python e Django, voltado à gestão de leads, clientes e oportunidades comerciais. A proposta central é permitir que empresas organizem seu funil de vendas por meio de um painel visual em formato Kanban, onde leads podem ser movimentados entre etapas do processo comercial até a conversão em clientes.

O sistema será desenvolvido no formato SaaS, ou seja, uma mesma aplicação deverá permitir o uso por múltiplas empresas, com isolamento de dados entre organizações. Cada empresa terá seus próprios usuários, leads, clientes, estágios de funil, configurações visuais, configurações de e-mail e relatórios.

O produto deve atender pequenas e médias empresas que precisam de um CRM simples, direto, personalizável e fácil de operar, sem a complexidade de plataformas enterprise.

Embora o documento base tenha referências anteriores a estruturas imobiliárias, o escopo principal deste PRD será um CRM genérico. Qualquer módulo específico de mercado, como imobiliário, deverá ser tratado como extensão futura e não como parte obrigatória do MVP.

---

## 2. Objetivos do Produto

### 2.1 Objetivos para Usuários Comerciais

- Organizar oportunidades de venda em um funil visual.
- Acompanhar o histórico de interações com leads.
- Cadastrar, editar, pesquisar e acompanhar leads.
- Converter leads em clientes formalizados.
- Visualizar rapidamente o estágio de cada oportunidade.
- Reduzir perda de contatos e oportunidades por falta de acompanhamento.

### 2.2 Objetivos para Administradores da Empresa

- Configurar os estágios do funil comercial.
- Gerenciar usuários da empresa.
- Personalizar identidade visual básica da aplicação para a empresa.
- Configurar dados públicos de contato.
- Configurar envio de e-mails via SMTP.
- Acompanhar relatórios comerciais e demográficos.

### 2.3 Objetivos para o Negócio SaaS

- Permitir que múltiplas empresas utilizem o sistema com isolamento de dados.
- Padronizar a gestão comercial em uma aplicação simples.
- Criar uma base sólida para expansão futura com planos, assinaturas, permissões avançadas e integrações.
- Manter o sistema modular, seguro e escalável.

---

## 3. Premissas Gerais de Desenvolvimento

1. O sistema será desenvolvido em Python e Django.
2. O sistema deverá usar Django ORM para persistência de dados.
3. O sistema deverá usar o sistema nativo de autenticação do Django sempre que fizer sentido.
4. Nomes de aplicações, modelos, funções, variáveis, mensagens, labels, botões e textos visíveis ao usuário deverão estar em português brasileiro.
5. Nomes de funções, classes e métodos vindos do Django ou de bibliotecas externas devem permanecer no padrão original da dependência.
6. O produto será SaaS multiempresa.
7. Todos os dados de negócio deverão pertencer a uma empresa/organização.
8. Usuários só podem visualizar dados da empresa à qual pertencem, salvo usuários administradores globais do SaaS.
9. O sistema deve ter interface responsiva para desktop, tablet e dispositivos móveis.
10. O MVP deve priorizar simplicidade, segurança e clareza operacional.

---

## 4. Traduções e Padronização de Nomenclatura

Sempre que possível, utilizar nomenclatura em português brasileiro.

| Termo original | Termo recomendado no sistema |
|---|---|
| CRM | CRM |
| Lead | Lead |
| Customer / Client | Cliente |
| Pipeline | Funil de Vendas |
| Stage | Estágio |
| Kanban | Kanban |
| Source | Fonte |
| Assigned User | Responsável |
| Position | Posição |
| Dashboard | Painel |
| Settings | Configurações |
| Reports | Relatórios |
| Profile | Perfil |
| Login | Entrar |
| Logout | Sair |
| Forgot Password | Recuperar Senha |
| Reset Password | Redefinir Senha |
| User | Usuário |
| Company / Tenant | Empresa |
| Role | Perfil de Acesso |
| Permission | Permissão |

### 4.1 Orientação para Código

Exemplos de nomes aceitáveis em português:

```python
class Empresa(models.Model):
    nome = models.CharField(max_length=255)

class EstagioFunil(models.Model):
    empresa = models.ForeignKey(Empresa, on_delete=models.CASCADE)
    nome = models.CharField(max_length=100)
    ordem = models.PositiveIntegerField(default=0)

def mover_lead(request):
    pass

def converter_lead_em_cliente(request):
    pass
```

Exemplos de exceções aceitáveis por dependência:

```python
from django.db import models
from django.urls import path
from django.contrib.auth.models import AbstractUser
from django.views import View
```

---

## 5. Escopo do MVP

O MVP deverá conter:

1. Autenticação e recuperação de senha.
2. Cadastro e gestão de empresas.
3. Gestão de usuários por empresa.
4. Dashboard com funil de vendas em Kanban.
5. Gestão de leads.
6. Comentários e histórico básico do lead.
7. Conversão de lead em cliente.
8. Gestão de clientes.
9. Upload de documentos de clientes.
10. Configuração dos estágios do funil.
11. Relatórios básicos.
12. Configurações da empresa.
13. Perfil do usuário.
14. Isolamento de dados por empresa.
15. Interface responsiva.
16. Validações e mensagens em português brasileiro.

---

## 6. Fora do Escopo do MVP

Os itens abaixo não devem ser implementados no MVP, salvo decisão explícita do usuário:

1. Cobrança recorrente e integração com gateways de pagamento.
2. Planos e limites comerciais por assinatura.
3. Integrações com WhatsApp oficial.
4. Integrações com redes sociais.
5. Automação avançada de funil.
6. Módulo imobiliário completo.
7. Módulo de propostas comerciais.
8. Assinatura digital.
9. Inteligência artificial para classificação de leads.
10. API pública para terceiros.
11. Aplicativo mobile nativo.
12. Sistema avançado de auditoria.
13. Soft delete em todas as entidades.
14. Importação e exportação em massa.
15. Webhooks.

Esses itens poderão ser considerados na seção de Pós-MVP.

---

## 7. Áreas de Negócio

---

# 7.1 Autenticação e Segurança

## Propósito

Controlar o acesso ao sistema, proteger contas de usuários e garantir que cada usuário acesse apenas os dados da sua empresa.

## Usuários envolvidos

- Usuário não autenticado.
- Usuário autenticado.
- Administrador da empresa.
- Administrador global do SaaS.

## Telas/Rotas sugeridas

As rotas podem seguir o padrão de URLs do Django, mas devem usar nomes legíveis e consistentes:

- `/entrar/` - Tela de login.
- `/sair/` - Encerramento de sessão.
- `/recuperar-senha/` - Solicitação de recuperação de senha.
- `/redefinir-senha/<token>/` - Redefinição de senha.
- `/perfil/` - Perfil do usuário logado.

## Fluxo principal de login

1. Usuário acessa a tela de login.
2. Usuário informa e-mail e senha.
3. Sistema valida as credenciais.
4. Em caso de sucesso:
   - Inicia sessão.
   - Identifica a empresa ativa do usuário.
   - Redireciona para o painel principal.
5. Em caso de erro:
   - Exibe mensagem genérica: `E-mail ou senha inválidos.`

## Fluxo de recuperação de senha

1. Usuário informa o e-mail cadastrado.
2. Sistema verifica se existe usuário ativo com esse e-mail.
3. Sistema gera token seguro com validade limitada.
4. Sistema envia e-mail com link de redefinição.
5. Usuário acessa o link.
6. Usuário informa nova senha e confirmação.
7. Sistema valida token, validade e uso.
8. Sistema altera a senha.
9. Token é marcado como utilizado.
10. Usuário é redirecionado para login.

## Regras

1. Senhas devem usar os mecanismos seguros do Django.
2. Todas as páginas protegidas exigem autenticação.
3. Requisições de modificação devem usar proteção CSRF.
4. Tokens de redefinição devem expirar em 1 hora.
5. Tokens de redefinição devem ser de uso único.
6. Mensagens de erro de login não devem informar se o e-mail existe.
7. Usuários inativos não podem acessar o sistema.
8. Usuários devem estar vinculados a uma empresa ativa para acessar áreas do CRM.

---

# 7.2 Gestão de Empresas / Multiempresa

## Propósito

Permitir que o sistema funcione como SaaS, com múltiplas empresas utilizando a mesma aplicação, mas com dados isolados.

## Usuários envolvidos

- Administrador global do SaaS.
- Administrador da empresa.
- Usuário da empresa.

## Entidade principal

Empresa.

## Campos principais

- Nome da empresa.
- Nome fantasia.
- Documento da empresa, opcional.
- E-mail principal.
- Telefone.
- WhatsApp.
- Site.
- Status ativo/inativo.
- Data de criação.
- Data de atualização.

## Regras

1. Toda entidade de negócio deve estar vinculada a uma empresa.
2. Usuários comuns só podem acessar dados da própria empresa.
3. Administradores da empresa só podem gerenciar usuários e configurações da própria empresa.
4. Administradores globais podem gerenciar todas as empresas.
5. Empresas inativas bloqueiam o acesso dos seus usuários ao CRM.
6. O sistema deve impedir vazamento de dados entre empresas em consultas, formulários, APIs e relatórios.

## Observação técnica importante

Todas as consultas de leads, clientes, estágios, arquivos, relatórios e configurações devem filtrar obrigatoriamente pela empresa do usuário autenticado.

Exemplo conceitual:

```python
Lead.objects.filter(empresa=request.user.empresa)
```

---

# 7.3 Dashboard e Funil de Vendas em Kanban

## Propósito

Permitir a visualização e gestão das oportunidades em um funil comercial visual, organizado em colunas e cartões.

## Usuários envolvidos

- Usuário autenticado.
- Administrador da empresa.

## Tela principal

- `/painel/`

## Objetos principais

- Estágios do funil.
- Leads.
- Posição do lead dentro do estágio.
- Responsável pelo lead.
- Valor estimado.
- Fonte de origem.

## Fluxo principal

1. Usuário acessa o painel.
2. Sistema carrega os estágios ativos da empresa, ordenados pelo campo `ordem`.
3. Sistema carrega os leads da empresa associados a cada estágio.
4. Leads são exibidos como cartões.
5. Usuário pode arrastar um lead entre colunas.
6. Usuário pode reordenar leads dentro da mesma coluna.
7. Ao soltar o card:
   - Sistema atualiza o estágio.
   - Sistema atualiza a posição.
   - Sistema registra data de atualização.
8. Usuário pode abrir detalhes do lead.
9. Usuário pode editar, excluir ou converter o lead em cliente.

## Informações exibidas no cartão do lead

- Título da oportunidade.
- Nome do contato.
- Telefone.
- E-mail, se houver.
- Valor estimado, se houver.
- Fonte.
- Responsável.
- Data de criação.
- Indicador visual de prioridade, se implementado no MVP.

## Ações no cartão

- Ver detalhes.
- Editar lead.
- Mover lead.
- Converter em cliente.
- Excluir lead.

## Endpoints internos sugeridos

- `POST /api/leads/mover/`
- `GET /api/leads/<id>/detalhes/`
- `POST /api/leads/<id>/excluir/`
- `POST /api/leads/<id>/converter-em-cliente/`

## Regras

1. Apenas leads da empresa do usuário podem ser exibidos.
2. Leads devem sempre pertencer a um estágio.
3. Leads devem sempre pertencer a uma empresa.
4. Ao mover um lead, o sistema deve validar se o novo estágio pertence à mesma empresa.
5. A reordenação deve ser feita de forma transacional para evitar posições duplicadas ou inconsistentes.
6. Estágios inativos não devem aparecer no Kanban.
7. Leads em estágios inativos devem ser tratados com cuidado:
   - Opção recomendada: impedir desativação de estágio com leads ativos.
   - Alternativa: permitir desativação, mas mover os leads para outro estágio definido pelo usuário.

---

# 7.4 Gestão de Leads

## Propósito

Permitir o cadastro, edição, listagem, pesquisa e acompanhamento de oportunidades comerciais.

## Usuários envolvidos

- Usuário autenticado.
- Administrador da empresa.

## Telas/Rotas sugeridas

- `/leads/` - Listagem de leads.
- `/leads/novo/` - Cadastro de lead.
- `/leads/<id>/editar/` - Edição de lead.
- `/leads/<id>/detalhes/` - Detalhes do lead.

## Campos principais

- Empresa.
- Título da oportunidade.
- Nome do contato.
- Telefone.
- E-mail.
- Fonte de origem.
- Valor estimado.
- Estágio atual.
- Responsável.
- Observações.
- Posição no estágio.
- Data de criação.
- Data de atualização.

## Fontes sugeridas

- Site.
- Indicação.
- WhatsApp.
- Redes sociais.
- Telefone.
- E-mail.
- Evento.
- Prospecção ativa.
- Outro.

## Campos obrigatórios

- Empresa.
- Título da oportunidade.
- Nome do contato.
- Estágio.

## Validações

1. O título deve ser obrigatório.
2. O nome do contato deve ser obrigatório.
3. O estágio deve pertencer à mesma empresa do lead.
4. O responsável, quando informado, deve pertencer à mesma empresa.
5. Valor estimado deve aceitar apenas números válidos.
6. E-mail deve ter formato válido.
7. Telefone deve ser normalizado sempre que possível.
8. Leads não podem ser criados sem empresa.

## Listagem de leads

A listagem deverá permitir:

- Paginação.
- Busca por título.
- Busca por nome do contato.
- Busca por e-mail.
- Busca por telefone.
- Filtro por estágio.
- Filtro por fonte.
- Filtro por responsável.
- Filtro por período de criação.
- Ordenação por data de criação, valor estimado ou nome.

## Mensagens ao usuário

- `Lead criado com sucesso.`
- `Lead atualizado com sucesso.`
- `Lead excluído com sucesso.`
- `Não foi possível encontrar o lead solicitado.`
- `O estágio informado não pertence à sua empresa.`
- `Preencha os campos obrigatórios.`

---

# 7.5 Comentários e Histórico do Lead

## Propósito

Registrar interações, observações e acontecimentos relevantes no acompanhamento de cada lead.

## Usuários envolvidos

- Usuário autenticado.

## Tela

- Dentro da tela de detalhes do lead.
- Opcionalmente dentro de modal no Kanban.

## Campos principais

- Lead.
- Usuário autor.
- Conteúdo.
- Data de criação.

## Fluxo

1. Usuário acessa os detalhes do lead.
2. Usuário escreve um comentário.
3. Sistema salva o comentário vinculado ao lead e ao usuário.
4. Comentário aparece no histórico do lead, em ordem cronológica decrescente ou crescente.

## Regras

1. Comentários pertencem à empresa por meio do lead.
2. Usuário só pode comentar em leads da própria empresa.
3. Conteúdo do comentário é obrigatório.
4. Comentários devem preservar o autor.
5. Ao excluir um lead, seus comentários também devem ser excluídos.

## Mensagens

- `Comentário adicionado com sucesso.`
- `Informe o conteúdo do comentário.`
- `Você não tem permissão para comentar neste lead.`

---

# 7.6 Conversão de Lead em Cliente

## Propósito

Permitir que uma oportunidade qualificada seja formalizada como cliente, evitando retrabalho e duplicidade.

## Usuários envolvidos

- Usuário autenticado.

## Fluxo

1. Usuário aciona a opção `Converter em cliente`.
2. Sistema verifica se o lead pertence à empresa do usuário.
3. Sistema valida se o lead possui e-mail e telefone.
4. Sistema verifica se já existe cliente com o mesmo e-mail ou telefone na mesma empresa.
5. Se já existir:
   - Sistema informa que o cliente já existe.
   - Sistema pode redirecionar para o cliente existente.
6. Se não existir:
   - Sistema cria novo cliente.
   - Sistema copia os dados principais do lead.
   - Sistema registra a origem.
   - Sistema mantém vínculo opcional entre lead e cliente.
7. Sistema exibe mensagem de sucesso.

## Dados copiados

- Nome do contato para nome do cliente.
- E-mail.
- Telefone.
- Fonte de origem.
- Observações.
- Empresa.

## Regras

1. Conversão só pode ocorrer para leads da empresa do usuário.
2. Conversão exige e-mail e telefone preenchidos.
3. Não pode haver dois clientes com mesmo e-mail dentro da mesma empresa.
4. Não pode haver dois clientes com mesmo telefone dentro da mesma empresa.
5. A duplicidade deve ser verificada dentro da empresa, não globalmente no SaaS.
6. Recomenda-se manter o lead original no funil, mas marcar que ele foi convertido.
7. O sistema não deve excluir automaticamente o lead após a conversão.

## Mensagens

- `Lead convertido em cliente com sucesso.`
- `Este lead precisa ter e-mail e telefone para ser convertido.`
- `Já existe um cliente cadastrado com este e-mail ou telefone.`
- `Não foi possível converter o lead informado.`

---

# 7.7 Gestão de Clientes

## Propósito

Manter uma base formal de clientes convertidos ou cadastrados diretamente.

## Usuários envolvidos

- Usuário autenticado.
- Administrador da empresa.

## Telas/Rotas sugeridas

- `/clientes/`
- `/clientes/novo/`
- `/clientes/<id>/editar/`
- `/clientes/<id>/detalhes/`

## Campos principais

- Empresa.
- Nome completo.
- E-mail.
- Telefone.
- Fonte de origem.
- Sexo.
- Data de nascimento.
- Observações.
- Data de criação.
- Data de atualização.

## Valores para sexo

- Masculino.
- Feminino.
- Outro.
- Não informado.

## Campos obrigatórios

- Empresa.
- Nome completo.

## Validações

1. Nome é obrigatório.
2. E-mail, quando informado, deve ter formato válido.
3. Telefone, quando informado, deve ser normalizado.
4. E-mail deve ser único por empresa.
5. Telefone deve ser único por empresa.
6. Data de nascimento não pode ser futura.
7. Cliente deve sempre pertencer a uma empresa.

## Listagem de clientes

A listagem deverá permitir:

- Paginação.
- Busca por nome.
- Busca por e-mail.
- Busca por telefone.
- Filtro por fonte.
- Filtro por sexo.
- Filtro por mês de aniversário.
- Ordenação por nome ou data de criação.

## Mensagens

- `Cliente criado com sucesso.`
- `Cliente atualizado com sucesso.`
- `Cliente excluído com sucesso.`
- `Já existe um cliente com este e-mail.`
- `Já existe um cliente com este telefone.`
- `Cliente não encontrado.`

---

# 7.8 Arquivos e Documentos de Clientes

## Propósito

Permitir anexar documentos relevantes ao cadastro de clientes.

## Usuários envolvidos

- Usuário autenticado.

## Locais de uso

- Tela de detalhes do cliente.
- Tela de edição do cliente.

## Campos principais

- Cliente.
- Título do arquivo.
- Arquivo.
- Tipo MIME.
- Tamanho.
- Data de envio.
- Usuário responsável pelo envio, se desejado.

## Fluxo de upload

1. Usuário acessa a tela do cliente.
2. Usuário seleciona um arquivo.
3. Usuário informa título, se necessário.
4. Sistema valida extensão, tamanho e tipo do arquivo.
5. Sistema armazena o arquivo.
6. Sistema registra os metadados no banco.
7. Arquivo aparece na lista de documentos do cliente.

## Regras de segurança

1. Bloquear arquivos executáveis e scripts.
2. Validar extensão e tipo MIME.
3. Não confiar apenas no nome do arquivo.
4. Renomear arquivos internamente para evitar conflito e exposição de nomes sensíveis.
5. Salvar metadados do arquivo no banco.
6. Usuário só pode acessar arquivos de clientes da própria empresa.
7. Arquivos devem ser servidos por rota protegida ou mecanismo seguro, nunca por caminho público desprotegido quando houver dados sensíveis.

## Extensões bloqueadas

- `.exe`
- `.bat`
- `.cmd`
- `.sh`
- `.js`
- `.cgi`
- `.pl`
- `.phtml`
- `.phar`
- `.php`
- `.py`
- `.rb`
- `.jar`
- `.msi`
- `.com`
- `.scr`

A referência a `.php` aqui é apenas uma regra de segurança para bloqueio de upload de arquivos perigosos. Não significa que a aplicação use PHP.

## Extensões permitidas sugeridas

- `.pdf`
- `.jpg`
- `.jpeg`
- `.png`
- `.webp`
- `.doc`
- `.docx`
- `.xls`
- `.xlsx`
- `.txt`

## Mensagens

- `Arquivo enviado com sucesso.`
- `Tipo de arquivo não permitido.`
- `Arquivo muito grande.`
- `Arquivo removido com sucesso.`
- `Você não tem permissão para acessar este arquivo.`

---

# 7.9 Configuração do Funil de Vendas

## Propósito

Permitir que cada empresa personalize seu processo comercial.

## Usuários envolvidos

- Administrador da empresa.
- Usuário com permissão para configurar funil.

## Tela

- `/configuracoes/funil/`

## Campos principais

- Empresa.
- Nome do estágio.
- Ordem.
- Cor.
- Status ativo/inativo.
- Indicador de estágio final, opcional.
- Tipo de resultado, opcional: ganho, perdido ou neutro.

## Estágios padrão sugeridos

1. Novo lead.
2. Contato inicial.
3. Qualificado.
4. Proposta enviada.
5. Negociação.
6. Fechado - ganho.
7. Fechado - perdido.

## Regras

1. Estágios pertencem a uma empresa.
2. Cada empresa deve ter seus próprios estágios.
3. Não é possível excluir estágio com leads vinculados.
4. Ordem de exibição deve ser configurável.
5. Cor deve ser hexadecimal válida.
6. Estágios inativos não aparecem no Kanban.
7. O sistema deve impedir que uma empresa fique sem nenhum estágio ativo.
8. Novos leads devem ser inseridos no primeiro estágio ativo, salvo estágio informado.

## Mensagens

- `Estágio criado com sucesso.`
- `Estágio atualizado com sucesso.`
- `Estágio excluído com sucesso.`
- `Não é possível excluir um estágio que possui leads vinculados.`
- `A empresa precisa ter pelo menos um estágio ativo.`
- `Informe uma cor válida.`

---

# 7.10 Relatórios e Análises

## Propósito

Fornecer visões analíticas sobre leads, clientes, fontes de origem, desempenho do funil e aniversariantes.

## Usuários envolvidos

- Usuário autenticado.
- Administrador da empresa.

## Telas/Rotas sugeridas

- `/relatorios/`
- `/relatorios/leads/`
- `/relatorios/aniversariantes/`
- `/relatorios/demografia/`

## Relatórios do MVP

### 7.10.1 Leads por Estágio

Exibir quantidade de leads por estágio.

Filtros:

- Período de criação.
- Responsável.
- Fonte.

Visualizações:

- Tabela.
- Gráfico de barras ou pizza.

### 7.10.2 Leads por Fonte

Exibir quantidade de leads por origem.

Filtros:

- Período de criação.
- Estágio.
- Responsável.

### 7.10.3 Valor Estimado por Estágio

Exibir soma do valor estimado dos leads agrupados por estágio.

### 7.10.4 Clientes por Período

Exibir quantidade de clientes cadastrados em determinado período.

### 7.10.5 Aniversariantes

Exibir clientes aniversariantes:

- Do dia.
- Do mês.
- De um período selecionado.

### 7.10.6 Demografia

Exibir distribuição por:

- Sexo.
- Faixa etária.

## Regras

1. Relatórios devem considerar apenas dados da empresa do usuário.
2. Relatórios devem permitir filtro por período quando aplicável.
3. Gráficos devem ser responsivos.
4. Valores monetários devem ser exibidos no formato brasileiro.
5. Datas devem ser exibidas no formato brasileiro.
6. Relatórios não devem expor dados de outras empresas.

## Mensagens

- `Nenhum dado encontrado para os filtros selecionados.`
- `Relatório gerado com sucesso.`
- `Informe um período válido.`

---

# 7.11 Comunicação com Aniversariantes

## Propósito

Permitir envio de e-mails personalizados para clientes aniversariantes.

## Usuários envolvidos

- Usuário autenticado.
- Administrador da empresa.

## Tela

- `/relatorios/aniversariantes/`

## Fluxo

1. Usuário acessa relatório de aniversariantes.
2. Sistema lista clientes que fazem aniversário no período selecionado.
3. Usuário seleciona clientes.
4. Usuário escreve assunto e mensagem.
5. Sistema substitui macros da mensagem.
6. Sistema envia e-mails usando SMTP configurado pela empresa.
7. Sistema informa resultado do envio.

## Macros disponíveis

- `{{nome}}` - Nome do cliente.
- `{{empresa}}` - Nome da empresa.
- `{{site}}` - Site público configurado.
- `{{whatsapp}}` - WhatsApp público configurado.
- `{{email}}` - E-mail público configurado.

## Regras

1. Apenas clientes da empresa do usuário podem ser selecionados.
2. Cliente precisa ter e-mail válido para receber mensagem.
3. SMTP da empresa precisa estar configurado.
4. O envio deve tratar falhas individuais sem interromper todo o lote.
5. O sistema deve exibir resumo com enviados e falhas.

## Mensagens

- `E-mails enviados com sucesso.`
- `Alguns e-mails não puderam ser enviados.`
- `Configure o SMTP antes de enviar e-mails.`
- `Selecione pelo menos um cliente.`
- `Informe o assunto e a mensagem.`

---

# 7.12 Configurações da Empresa

## Propósito

Permitir que cada empresa personalize dados básicos, identidade visual e envio de e-mails.

## Usuários envolvidos

- Administrador da empresa.

## Tela

- `/configuracoes/empresa/`

## Campos principais

- Nome da aplicação para a empresa.
- Nome da empresa.
- E-mail público.
- Site público.
- WhatsApp público.
- Cor primária.
- Cor secundária.
- Logo.
- Configuração SMTP.

## Configuração SMTP

Campos:

- Servidor SMTP.
- Porta.
- Segurança: nenhuma, SSL ou TLS.
- Usuário SMTP.
- Senha SMTP.
- E-mail remetente.
- Nome do remetente.

## Regras de logo

1. Logo deve ser imagem.
2. Formatos aceitos: PNG, JPG, JPEG ou WEBP.
3. Tamanho máximo recomendado: 100x100 pixels para uso compacto.
4. Proporção recomendada: quadrada.
5. O sistema pode redimensionar automaticamente a imagem.

## Regras de cores

1. Cores devem ser valores hexadecimais válidos.
2. Cor primária será usada em botões, links e elementos principais.
3. Cor secundária será usada em menus, cabeçalhos ou elementos de apoio.
4. A interface deve garantir contraste mínimo adequado para leitura.

## Teste de SMTP

Fluxo:

1. Usuário preenche configurações SMTP.
2. Usuário informa e-mail de teste.
3. Sistema tenta enviar mensagem.
4. Sistema informa sucesso ou erro.

## Mensagens

- `Configurações salvas com sucesso.`
- `Informe uma cor válida.`
- `Logo enviado com sucesso.`
- `Não foi possível enviar o e-mail de teste.`
- `E-mail de teste enviado com sucesso.`

---

# 7.13 Perfil do Usuário

## Propósito

Permitir que o usuário gerencie seus próprios dados e senha.

## Usuários envolvidos

- Usuário autenticado.

## Tela

- `/perfil/`

## Campos principais

- Nome.
- E-mail.
- Senha atual.
- Nova senha.
- Confirmação da nova senha.

## Regras

1. Usuário pode alterar seu próprio nome.
2. Usuário pode alterar seu próprio e-mail, desde que não exista outro usuário com o mesmo e-mail.
3. Para alterar senha, deve informar a senha atual.
4. Nova senha e confirmação devem ser iguais.
5. Nova senha deve respeitar as validações configuradas no Django.

## Mensagens

- `Perfil atualizado com sucesso.`
- `Senha alterada com sucesso.`
- `Senha atual inválida.`
- `A confirmação da senha não confere.`
- `Já existe um usuário com este e-mail.`

---

# 7.14 Gestão de Usuários da Empresa

## Propósito

Permitir que administradores da empresa cadastrem e gerenciem usuários que acessarão o CRM.

## Usuários envolvidos

- Administrador da empresa.

## Telas/Rotas sugeridas

- `/usuarios/`
- `/usuarios/novo/`
- `/usuarios/<id>/editar/`

## Campos principais

- Empresa.
- Nome.
- E-mail.
- Perfil de acesso.
- Status ativo/inativo.
- Data de criação.

## Perfis de acesso do MVP

### Administrador da empresa

Permissões:

- Gerenciar usuários da empresa.
- Gerenciar configurações da empresa.
- Gerenciar funil.
- Gerenciar leads.
- Gerenciar clientes.
- Ver relatórios.
- Enviar e-mails.

### Usuário comercial

Permissões:

- Gerenciar leads.
- Gerenciar clientes.
- Converter leads.
- Comentar em leads.
- Ver relatórios básicos.
- Editar próprio perfil.

## Regras

1. Usuários pertencem a uma empresa.
2. E-mail de usuário deve ser único globalmente.
3. Administrador da empresa só pode gerenciar usuários da própria empresa.
4. Usuário inativo não pode acessar o sistema.
5. Deve existir pelo menos um administrador ativo por empresa.

## Mensagens

- `Usuário criado com sucesso.`
- `Usuário atualizado com sucesso.`
- `Usuário inativado com sucesso.`
- `Não é possível inativar o único administrador ativo da empresa.`
- `Já existe um usuário com este e-mail.`

---

## 8. Modelagem de Dados Sugerida

A modelagem abaixo deve ser implementada com Django ORM. Os nomes das classes e campos devem estar em português, exceto quando houver forte convenção do Django ou dependência externa.

---

# 8.1 Empresa

Representa uma empresa/tenant do SaaS.

Campos sugeridos:

```text
- id
- nome
- nome_fantasia
- documento
- email
- telefone
- whatsapp
- site
- ativa
- data_criacao
- data_atualizacao
```

Relacionamentos:

- Uma empresa possui muitos usuários.
- Uma empresa possui muitos leads.
- Uma empresa possui muitos clientes.
- Uma empresa possui muitos estágios de funil.
- Uma empresa possui uma configuração.

---

# 8.2 Usuario

Representa usuário autenticado do sistema.

Recomendação:

- Criar modelo customizado baseado em `AbstractUser` ou `AbstractBaseUser`.
- Usar e-mail como identificador principal de login.

Campos sugeridos:

```text
- id
- empresa
- nome
- email
- senha
- perfil_acesso
- ativo
- is_staff
- is_superuser
- data_criacao
- data_atualizacao
```

Perfis:

```text
- administrador_empresa
- usuario_comercial
```

Observação:

Campos técnicos obrigatórios do Django podem manter os nomes esperados pelo framework quando necessário.

---

# 8.3 EstagioFunil

Representa uma coluna do funil de vendas.

Campos sugeridos:

```text
- id
- empresa
- nome
- ordem
- ativo
- cor
- tipo_resultado
- data_criacao
- data_atualizacao
```

Valores sugeridos para `tipo_resultado`:

```text
- neutro
- ganho
- perdido
```

Relacionamentos:

- Um estágio possui muitos leads.
- Um estágio pertence a uma empresa.

---

# 8.4 Lead

Representa uma oportunidade comercial.

Campos sugeridos:

```text
- id
- empresa
- titulo
- nome_contato
- telefone
- email
- fonte
- valor_estimado
- estagio
- responsavel
- observacoes
- posicao
- convertido_em_cliente
- cliente_convertido
- data_conversao
- data_criacao
- data_atualizacao
```

Relacionamentos:

- Lead pertence a uma empresa.
- Lead pertence a um estágio.
- Lead pode ter um responsável.
- Lead pode ter muitos comentários.
- Lead pode ser convertido em um cliente.

---

# 8.5 ComentarioLead

Representa comentários ou interações registradas no lead.

Campos sugeridos:

```text
- id
- lead
- usuario
- conteudo
- data_criacao
```

Relacionamentos:

- Comentário pertence a um lead.
- Comentário pode estar vinculado a um usuário.

---

# 8.6 Cliente

Representa cliente formalizado.

Campos sugeridos:

```text
- id
- empresa
- nome
- email
- telefone
- fonte
- sexo
- data_nascimento
- observacoes
- data_criacao
- data_atualizacao
```

Valores sugeridos para sexo:

```text
- masculino
- feminino
- outro
- nao_informado
```

Regras de unicidade:

- E-mail deve ser único por empresa quando preenchido.
- Telefone deve ser único por empresa quando preenchido.

---

# 8.7 ArquivoCliente

Representa documentos anexados ao cliente.

Campos sugeridos:

```text
- id
- empresa
- cliente
- titulo
- arquivo
- nome_original
- tipo_mime
- tamanho
- enviado_por
- data_criacao
```

Relacionamentos:

- Arquivo pertence a uma empresa.
- Arquivo pertence a um cliente.
- Arquivo pode ter usuário responsável pelo envio.

---

# 8.8 ConfiguracaoEmpresa

Representa configurações específicas da empresa.

Campos sugeridos:

```text
- id
- empresa
- nome_aplicacao
- email_publico
- site_publico
- whatsapp_publico
- cor_primaria
- cor_secundaria
- logo
- smtp_servidor
- smtp_porta
- smtp_seguranca
- smtp_usuario
- smtp_senha
- smtp_email_remetente
- smtp_nome_remetente
- data_criacao
- data_atualizacao
```

Valores sugeridos para `smtp_seguranca`:

```text
- nenhuma
- ssl
- tls
```

Regras:

- Deve existir apenas uma configuração por empresa.

---

# 8.9 TokenRedefinicaoSenha

Caso o sistema não utilize integralmente o fluxo nativo do Django, poderá existir modelo próprio para tokens.

Campos sugeridos:

```text
- id
- usuario
- token
- data_expiracao
- data_utilizacao
- data_criacao
```

Regras:

- Token único.
- Expiração em 1 hora.
- Uso único.

---

## 9. Banco de Dados e Persistência

## 9.1 Banco recomendado

Para o MVP, recomenda-se usar PostgreSQL.

Motivos:

- Excelente suporte com Django.
- Bom suporte a constraints, índices e transações.
- Boa escalabilidade para SaaS.
- Suporte robusto a campos JSON, se necessário futuramente.

Também é possível usar MySQL ou MariaDB, desde que a aplicação permaneça compatível com Django ORM e não dependa de SQL específico sem necessidade.

## 9.2 Migrations

1. Toda estrutura de banco deve ser criada por migrations do Django.
2. Não utilizar scripts externos de schema como fonte principal da verdade.
3. Dados iniciais devem ser criados por:
   - migrations de dados;
   - comandos customizados do Django;
   - fixtures;
   - rotina de criação da empresa inicial.

## 9.3 Dados iniciais

Ao criar uma nova empresa, o sistema deve gerar:

1. Configuração padrão da empresa.
2. Estágios padrão do funil.
3. Usuário administrador da empresa, quando aplicável.

Estágios padrão:

```text
1. Novo lead
2. Contato inicial
3. Qualificado
4. Proposta enviada
5. Negociação
6. Fechado - ganho
7. Fechado - perdido
```

## 9.4 Regras de isolamento

Toda tabela de negócio deve conter vínculo direto ou indireto com empresa.

Entidades com vínculo direto obrigatório:

- Usuário.
- Lead.
- Cliente.
- Estágio do funil.
- Arquivo de cliente.
- Configuração da empresa.

Entidades com vínculo indireto:

- Comentário de lead, por meio do lead.

## 9.5 Exclusões

No MVP, exclusões podem ser permanentes, desde que confirmadas pelo usuário.

Regras:

1. Excluir lead remove seus comentários.
2. Excluir cliente remove seus arquivos vinculados.
3. Excluir estágio só é permitido se não houver leads vinculados.
4. Excluir empresa não deve ser uma ação comum no painel da empresa.
5. Administrador global pode inativar empresa em vez de excluir.

---

## 10. Fluxos de Usuário

---

# 10.1 Primeiro Acesso da Empresa

1. Administrador global cria uma empresa.
2. Sistema cria configurações padrão da empresa.
3. Sistema cria estágios padrão do funil.
4. Sistema cria usuário administrador da empresa.
5. Administrador da empresa recebe dados de acesso ou convite.
6. Administrador acessa o sistema.
7. Administrador ajusta dados da empresa, cores, SMTP e usuários.

---

# 10.2 Login

1. Usuário acessa `/entrar/`.
2. Informa e-mail e senha.
3. Sistema autentica.
4. Sistema valida se usuário está ativo.
5. Sistema valida se empresa está ativa.
6. Sistema redireciona para `/painel/`.

---

# 10.3 Gestão de Leads no Kanban

1. Usuário acessa o painel.
2. Sistema exibe estágios ativos.
3. Sistema exibe leads em seus respectivos estágios.
4. Usuário arrasta lead para outro estágio.
5. Sistema valida a ação.
6. Sistema atualiza estágio e posição.
7. Sistema exibe confirmação discreta.

---

# 10.4 Cadastro de Lead

1. Usuário acessa `/leads/novo/`.
2. Preenche dados obrigatórios.
3. Seleciona estágio, fonte e responsável, se desejado.
4. Sistema valida os dados.
5. Sistema cria lead vinculado à empresa do usuário.
6. Sistema redireciona para detalhes ou listagem.

---

# 10.5 Conversão de Lead em Cliente

1. Usuário abre o lead.
2. Clica em `Converter em cliente`.
3. Sistema valida e-mail e telefone.
4. Sistema verifica duplicidade na empresa.
5. Sistema cria cliente ou retorna cliente existente.
6. Sistema marca o lead como convertido.
7. Sistema exibe mensagem de sucesso.

---

# 10.6 Cadastro de Cliente

1. Usuário acessa `/clientes/novo/`.
2. Preenche dados do cliente.
3. Sistema valida unicidade por empresa.
4. Sistema cria cliente.
5. Usuário pode anexar documentos.

---

# 10.7 Envio de E-mail para Aniversariantes

1. Usuário acessa relatório de aniversariantes.
2. Sistema exibe clientes com aniversário no período.
3. Usuário seleciona destinatários.
4. Usuário escreve assunto e mensagem.
5. Sistema substitui macros.
6. Sistema envia e-mails.
7. Sistema exibe resumo.

---

# 10.8 Configuração do Sistema

1. Administrador acessa configurações da empresa.
2. Atualiza dados públicos.
3. Atualiza cores e logo.
4. Configura SMTP.
5. Realiza teste de envio.
6. Salva alterações.

---

## 11. Regras de Negócio

1. Toda informação de negócio deve pertencer a uma empresa.
2. Usuários comuns só acessam dados da própria empresa.
3. Leads devem sempre pertencer a um estágio.
4. Estágios pertencem a uma empresa.
5. Não é permitido mover lead para estágio de outra empresa.
6. Não é permitido atribuir lead a usuário de outra empresa.
7. Não é permitido excluir estágio com leads vinculados.
8. Lead só pode ser convertido em cliente se possuir e-mail e telefone.
9. Clientes não podem ter e-mail duplicado dentro da mesma empresa.
10. Clientes não podem ter telefone duplicado dentro da mesma empresa.
11. A duplicidade de clientes deve ser verificada por empresa.
12. Arquivos perigosos devem ser bloqueados no upload.
13. Todas as operações de modificação devem exigir CSRF.
14. Tokens de recuperação de senha devem expirar em 1 hora.
15. Tokens de recuperação de senha devem ser de uso único.
16. Empresas inativas bloqueiam acesso dos seus usuários.
17. Usuários inativos não podem acessar o sistema.
18. Deve existir pelo menos um administrador ativo por empresa.
19. Relatórios devem considerar apenas dados da empresa do usuário.
20. Configurações visuais e SMTP são específicas por empresa.

---

## 12. Tipos de Usuário e Permissões

---

# 12.1 Administrador Global do SaaS

Usuário interno da plataforma.

Permissões:

- Criar empresas.
- Inativar empresas.
- Visualizar lista de empresas.
- Criar administrador inicial de empresa.
- Acessar painel administrativo global.
- Gerenciar configurações globais, se houver.

Não deve, por padrão, manipular dados comerciais das empresas, salvo funcionalidade administrativa específica.

---

# 12.2 Administrador da Empresa

Permissões:

- Gerenciar usuários da própria empresa.
- Gerenciar configurações da empresa.
- Gerenciar estágios do funil.
- Criar, editar e excluir leads.
- Criar, editar e excluir clientes.
- Converter leads em clientes.
- Anexar e excluir arquivos.
- Visualizar relatórios.
- Enviar e-mails para aniversariantes.
- Editar próprio perfil.

---

# 12.3 Usuário Comercial

Permissões:

- Criar, editar e visualizar leads.
- Mover leads no Kanban.
- Comentar em leads.
- Converter leads em clientes.
- Criar, editar e visualizar clientes.
- Anexar arquivos a clientes.
- Visualizar relatórios básicos.
- Editar próprio perfil.

Restrições:

- Não pode gerenciar usuários.
- Não pode alterar configurações da empresa.
- Não pode alterar estágios do funil, salvo permissão futura.
- Não pode acessar painel global.

---

# 12.4 Não Autenticado

Permissões:

- Acessar login.
- Solicitar recuperação de senha.
- Redefinir senha com token válido.

Restrições:

- Não pode acessar dados do CRM.

---

## 13. Matriz de Permissões

| Recurso | Admin Global | Admin Empresa | Usuário Comercial | Não Autenticado |
|---|---:|---:|---:|---:|
| Login | Sim | Sim | Sim | Sim |
| Recuperar senha | Sim | Sim | Sim | Sim |
| Painel Kanban | Não por padrão | Sim | Sim | Não |
| Criar lead | Não por padrão | Sim | Sim | Não |
| Editar lead | Não por padrão | Sim | Sim | Não |
| Excluir lead | Não por padrão | Sim | Opcional | Não |
| Converter lead | Não por padrão | Sim | Sim | Não |
| Criar cliente | Não por padrão | Sim | Sim | Não |
| Editar cliente | Não por padrão | Sim | Sim | Não |
| Excluir cliente | Não por padrão | Sim | Opcional | Não |
| Anexar arquivos | Não por padrão | Sim | Sim | Não |
| Configurar funil | Não por padrão | Sim | Não | Não |
| Ver relatórios | Não por padrão | Sim | Sim | Não |
| Configurar empresa | Não por padrão | Sim | Não | Não |
| Gerenciar usuários | Não por padrão | Sim | Não | Não |
| Gerenciar empresas | Sim | Não | Não | Não |

---

## 14. Arquitetura Sugerida

## 14.1 Tipo de arquitetura

Aplicação web monolítica modular com Django.

O sistema deve ser organizado em apps Django por domínio de negócio.

## 14.2 Apps Django sugeridos

```text
- contas
- empresas
- leads
- clientes
- funil
- relatorios
- configuracoes
- arquivos
- comunicacoes
```

## 14.3 Responsabilidade dos apps

### contas

- Autenticação.
- Usuários.
- Perfis de acesso.
- Recuperação de senha.
- Perfil do usuário.

### empresas

- Cadastro de empresas.
- Status da empresa.
- Vínculo dos usuários com empresas.
- Criação inicial da estrutura da empresa.

### funil

- Estágios do funil.
- Ordenação dos estágios.
- Regras de ativação/inativação.

### leads

- Cadastro de leads.
- Kanban.
- Movimentação de leads.
- Comentários.
- Conversão em cliente.

### clientes

- Cadastro de clientes.
- Dados demográficos.
- Relacionamento com arquivos.

### arquivos

- Upload.
- Validação.
- Armazenamento.
- Download protegido.

### relatorios

- Leads por estágio.
- Leads por fonte.
- Valor estimado por estágio.
- Clientes por período.
- Aniversariantes.
- Demografia.

### configuracoes

- Configurações visuais.
- Dados públicos.
- SMTP.
- Logo.

### comunicacoes

- Envio de e-mails.
- Substituição de macros.
- Teste SMTP.
- E-mails para aniversariantes.

---

## 15. Padrões de Backend

## 15.1 Views

O sistema pode usar:

- Class-Based Views do Django.
- Function-Based Views quando forem mais simples.
- Django REST Framework, se houver APIs internas mais estruturadas.

## 15.2 Services

A lógica de negócio mais importante deve ficar fora das views, em serviços de domínio.

Exemplos:

```text
- servico_lead.py
- servico_cliente.py
- servico_funil.py
- servico_email.py
- servico_arquivo.py
```

Exemplos de funções:

```python
def mover_lead(*, lead, novo_estagio, nova_posicao, usuario):
    pass

def converter_lead_em_cliente(*, lead, usuario):
    pass

def enviar_email_aniversariantes(*, clientes, assunto, mensagem, empresa):
    pass
```

## 15.3 Forms

Usar Django Forms ou ModelForms para validação server-side.

Exemplos:

```text
- FormularioLead
- FormularioCliente
- FormularioEstagioFunil
- FormularioConfiguracaoEmpresa
- FormularioPerfilUsuario
```

## 15.4 Templates

Templates devem usar textos em português brasileiro.

Botões exemplos:

```text
- Salvar
- Cancelar
- Excluir
- Editar
- Novo lead
- Novo cliente
- Converter em cliente
- Enviar e-mail
- Testar SMTP
```

## 15.5 APIs internas

APIs internas devem retornar JSON padronizado.

Resposta de sucesso:

```json
{
  "sucesso": true,
  "mensagem": "Lead movido com sucesso.",
  "dados": {}
}
```

Resposta de erro:

```json
{
  "sucesso": false,
  "mensagem": "Não foi possível mover o lead."
}
```

---

## 16. Padrões de Frontend

## 16.1 Requisitos gerais

1. Interface responsiva.
2. Textos em português brasileiro.
3. Feedback visual para ações do usuário.
4. Confirmação para exclusões.
5. Máscaras para telefone, datas e valores monetários.
6. Kanban com arrastar e soltar.
7. Layout simples, limpo e comercial.

## 16.2 Componentes principais

- Menu lateral ou superior.
- Painel com indicadores.
- Kanban.
- Cards de lead.
- Formulários.
- Tabelas com filtros.
- Modais de detalhe.
- Alertas de sucesso e erro.
- Gráficos.
- Área de configurações.

## 16.3 Acessibilidade

1. Garantir contraste adequado.
2. Botões devem ter labels claros.
3. Formulários devem ter labels visíveis.
4. Erros devem ser exibidos próximos aos campos.
5. A navegação básica deve funcionar por teclado sempre que possível.

---

## 17. Requisitos Não Funcionais

## 17.1 Segurança

1. Usar autenticação segura do Django.
2. Usar hash de senha nativo do Django.
3. Usar proteção CSRF.
4. Usar validação server-side em todos os formulários.
5. Usar permissões por empresa.
6. Impedir acesso cruzado entre empresas.
7. Validar uploads.
8. Proteger download de arquivos.
9. Não expor caminhos físicos de arquivos.
10. Não registrar senhas ou dados sensíveis em logs.
11. Proteger configurações SMTP, especialmente senha.
12. Usar variáveis de ambiente para segredos de aplicação.

## 17.2 Performance

1. Listagens devem ser paginadas.
2. Consultas devem usar filtros por empresa.
3. Usar `select_related` e `prefetch_related` quando necessário.
4. Dashboard Kanban deve ser otimizado para volume moderado de leads.
5. Para empresas com muitos leads, considerar filtros por responsável, período ou estágio.
6. Índices devem ser criados para campos frequentemente filtrados.

Campos recomendados para índice:

```text
- empresa
- email
- telefone
- estagio
- responsavel
- fonte
- data_criacao
```

## 17.3 Confiabilidade

1. Movimentação de leads deve usar transação.
2. Conversão de lead em cliente deve usar transação.
3. Upload de arquivos deve tratar falhas de escrita.
4. Exclusão de cliente deve tratar banco e arquivo de forma consistente.
5. Envio em massa deve registrar falhas individuais.

## 17.4 Manutenibilidade

1. Separar regras de negócio em services.
2. Evitar lógica complexa diretamente nos templates.
3. Evitar views muito grandes.
4. Criar testes para regras críticas.
5. Usar nomes em português de forma consistente.
6. Documentar decisões importantes.

## 17.5 Compatibilidade

1. Aplicação deve funcionar nos navegadores modernos.
2. Interface deve ser responsiva.
3. Backend deve ser compatível com ambiente Linux.
4. Banco recomendado: PostgreSQL.

---

## 18. Requisitos de Testes

## 18.1 Testes obrigatórios do MVP

### Autenticação

- Login com credenciais válidas.
- Login com credenciais inválidas.
- Recuperação de senha.
- Token expirado.
- Token já utilizado.
- Bloqueio de usuário inativo.

### Multiempresa

- Usuário não pode acessar lead de outra empresa.
- Usuário não pode acessar cliente de outra empresa.
- Usuário não pode mover lead para estágio de outra empresa.
- Relatórios não misturam dados entre empresas.

### Leads

- Criar lead válido.
- Impedir lead sem campos obrigatórios.
- Editar lead.
- Excluir lead.
- Mover lead entre estágios.
- Reordenar lead dentro do estágio.
- Comentar lead.

### Clientes

- Criar cliente.
- Impedir duplicidade de e-mail na mesma empresa.
- Impedir duplicidade de telefone na mesma empresa.
- Permitir mesmo e-mail em empresas diferentes, se a regra de negócio permitir.
- Editar cliente.
- Excluir cliente.

### Conversão

- Converter lead válido.
- Impedir conversão sem e-mail.
- Impedir conversão sem telefone.
- Retornar cliente existente em caso de duplicidade.
- Marcar lead como convertido.

### Arquivos

- Upload de arquivo permitido.
- Bloqueio de arquivo perigoso.
- Download apenas por usuário da mesma empresa.
- Exclusão de arquivo.

### Configurações

- Atualizar dados da empresa.
- Validar cor inválida.
- Upload de logo.
- Teste SMTP.

---

## 19. Mensagens Padrão do Sistema

Todas as mensagens devem estar em português brasileiro.

## 19.1 Mensagens de sucesso

```text
Operação realizada com sucesso.
Lead criado com sucesso.
Lead atualizado com sucesso.
Lead movido com sucesso.
Lead excluído com sucesso.
Cliente criado com sucesso.
Cliente atualizado com sucesso.
Cliente excluído com sucesso.
Lead convertido em cliente com sucesso.
Configurações salvas com sucesso.
Usuário criado com sucesso.
Senha alterada com sucesso.
Arquivo enviado com sucesso.
E-mail enviado com sucesso.
```

## 19.2 Mensagens de erro

```text
Não foi possível realizar a operação.
Preencha os campos obrigatórios.
Você não tem permissão para acessar este recurso.
Registro não encontrado.
E-mail ou senha inválidos.
Arquivo não permitido.
Arquivo muito grande.
Já existe um cliente com este e-mail.
Já existe um cliente com este telefone.
Não é possível excluir este registro porque existem dados vinculados.
Configure o SMTP antes de enviar e-mails.
```

## 19.3 Mensagens de confirmação

```text
Tem certeza que deseja excluir este registro?
Esta ação não poderá ser desfeita.
Deseja converter este lead em cliente?
Deseja enviar e-mail para os clientes selecionados?
```

---

## 20. Critérios de Aceite do MVP

O MVP será considerado concluído quando:

1. Uma empresa puder ser criada.
2. Um administrador da empresa puder acessar o sistema.
3. Usuários forem vinculados a empresas.
4. Dados forem isolados entre empresas.
5. O usuário puder criar, editar, listar e excluir leads.
6. O usuário puder visualizar leads no Kanban.
7. O usuário puder mover leads entre estágios.
8. O usuário puder configurar estágios do funil.
9. O usuário puder comentar em leads.
10. O usuário puder converter lead em cliente.
11. O usuário puder criar, editar, listar e excluir clientes.
12. O usuário puder anexar arquivos seguros a clientes.
13. O usuário puder visualizar relatórios básicos.
14. O usuário puder listar aniversariantes.
15. O usuário puder configurar SMTP.
16. O usuário puder enviar e-mail para aniversariantes.
17. O usuário puder editar o próprio perfil.
18. Administrador da empresa puder gerenciar usuários.
19. Todas as mensagens visíveis estiverem em português brasileiro.
20. Não houver referências técnicas obrigatórias a PHP ou stack anterior.
21. O sistema usar migrations do Django.
22. O sistema possuir testes para as regras críticas.

---

## 21. Sugestões de Melhorias Pós-MVP

As funcionalidades abaixo são sugestões e não fazem parte do escopo principal do MVP.

---

# 21.1 Planos e Assinaturas SaaS

Criar controle de planos comerciais.

Possíveis recursos:

- Plano gratuito.
- Plano básico.
- Plano profissional.
- Plano empresarial.
- Limite de usuários por plano.
- Limite de leads por plano.
- Limite de armazenamento por plano.
- Integração com gateway de pagamento.
- Bloqueio automático por inadimplência.

---

# 21.2 Permissões Granulares

Criar permissões mais detalhadas.

Exemplos:

- Pode excluir lead.
- Pode exportar dados.
- Pode ver relatórios financeiros.
- Pode alterar configurações.
- Pode gerenciar usuários.
- Pode ver leads de todos.
- Pode ver apenas leads próprios.

---

# 21.3 Soft Delete

Implementar exclusão lógica.

Benefícios:

- Recuperação de registros excluídos.
- Histórico mais seguro.
- Menor risco operacional.

Entidades candidatas:

- Leads.
- Clientes.
- Usuários.
- Arquivos.
- Estágios.

---

# 21.4 Auditoria de Ações

Registrar ações importantes.

Exemplos:

- Criação de lead.
- Alteração de estágio.
- Conversão em cliente.
- Exclusão de cliente.
- Alteração de configurações.
- Login.
- Falha de login.

---

# 21.5 Importação e Exportação

Permitir:

- Importação de leads por CSV ou Excel.
- Importação de clientes.
- Exportação de relatórios.
- Exportação da base de clientes.
- Exportação de leads filtrados.

---

# 21.6 Integração com WhatsApp

Possíveis recursos:

- Botão para abrir conversa no WhatsApp.
- Templates de mensagem.
- Histórico manual de contato.
- Integração futura com WhatsApp Business API.

---

# 21.7 Automação Comercial

Permitir automações como:

- Criar tarefa ao mover lead.
- Enviar e-mail automático após conversão.
- Alertar responsável após lead parado por muitos dias.
- Mudar prioridade automaticamente.
- Criar lembretes de follow-up.

---

# 21.8 Tarefas e Lembretes

Criar agenda comercial básica:

- Tarefa vinculada ao lead.
- Tarefa vinculada ao cliente.
- Data de vencimento.
- Responsável.
- Status da tarefa.
- Notificações internas.

---

# 21.9 Módulo de Propostas

Permitir criação de propostas comerciais:

- Proposta vinculada ao lead.
- Itens da proposta.
- Valor.
- Validade.
- Status.
- Geração de PDF.
- Envio por e-mail.

---

# 21.10 API Pública

Criar API para integrações externas.

Possíveis usos:

- Receber leads de sites.
- Integrar formulários externos.
- Integrar landing pages.
- Consultar status de leads.
- Criar webhooks.

---

# 21.11 Módulo Imobiliário

Como o documento base possuía estruturas imobiliárias, este módulo pode ser retomado futuramente como extensão específica.

Funcionalidades possíveis:

- Cadastro de corretores.
- Cadastro de imóveis.
- Imagens de imóveis.
- Características do imóvel.
- Finalidade: venda, aluguel ou temporada.
- Status do imóvel.
- Associação entre lead e imóvel de interesse.
- Funil específico para venda ou locação.

Este módulo não faz parte do CRM genérico do MVP.

---

# 21.12 Inteligência Comercial

Recursos futuros:

- Score de lead.
- Previsão de fechamento.
- Sugestão de próxima ação.
- Identificação de leads parados.
- Resumo automático do histórico do lead.
- Classificação automática por fonte ou interesse.

---

## 22. Glossário

| Termo | Definição |
|---|---|
| CRM | Sistema de gestão de relacionamento com clientes. |
| Lead | Potencial cliente ou oportunidade comercial. |
| Cliente | Pessoa ou empresa formalizada na base de dados. |
| Funil de vendas | Sequência de etapas comerciais percorridas por um lead. |
| Estágio | Uma etapa do funil de vendas. |
| Kanban | Visualização em colunas e cartões usada para representar o funil. |
| Fonte | Origem do lead, como site, indicação ou WhatsApp. |
| Responsável | Usuário encarregado pelo acompanhamento do lead. |
| Posição | Ordem do lead dentro de um estágio do Kanban. |
| SaaS | Software como serviço, usado por múltiplas empresas em uma mesma plataforma. |
| Empresa | Organização cliente do SaaS, também chamada de tenant. |
| Administrador da empresa | Usuário com permissão para configurar e gerenciar a própria empresa. |
| Administrador global | Usuário interno com acesso administrativo ao SaaS. |
| SMTP | Configuração usada para envio de e-mails. |
| Macro | Marcador substituído dinamicamente em mensagens, como `{{nome}}`. |
| CSRF | Proteção contra requisições maliciosas não autorizadas. |
| Soft delete | Exclusão lógica, em que o registro fica oculto mas não é removido definitivamente. |

---

## 23. Instruções Finais para o Agente Desenvolvedor

1. Desenvolva a aplicação em Python e Django.
2. Use Django ORM e migrations como fonte principal da estrutura de banco.
3. Use português brasileiro para nomes de domínio, funções próprias, variáveis próprias, mensagens, botões e labels.
4. Preserve nomes originais apenas quando forem exigidos pelo Django ou bibliotecas externas.
5. Não use referências à stack anterior do documento base.
6. Não implemente arquivos, rotas, padrões ou instaladores específicos de outra linguagem.
7. Estruture o sistema como SaaS multiempresa desde o início.
8. Garanta isolamento de dados por empresa em todas as consultas.
9. Priorize o MVP antes de funcionalidades pós-MVP.
10. Sempre que houver decisão ambígua, pergunte ao usuário antes de implementar.
11. Implemente validações server-side mesmo que existam validações no frontend.
12. Crie testes para regras críticas de segurança, multiempresa, conversão e permissões.
13. Mantenha a aplicação modular, legível e fácil de evoluir.
