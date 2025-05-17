# Guia Técnico - Virtual BookShelf

Este documento fornece uma visão técnica detalhada do projeto "Minha Estante Virtual", explicando a arquitetura, fluxo de dados e principais componentes técnicos.

## Arquitetura do Sistema

O projeto segue o padrão MVC (Model-View-Controller) característico do Ruby on Rails, com algumas camadas adicionais para melhorar a organização e a modularidade.

### Camadas da Aplicação

```
Cliente (Browser) ⟷ Controllers ⟷ Services ⟷ Models ⟷ Database
                     ↓
                    Views
```

1. **Controllers**: Gerenciam as requisições HTTP e delegam as operações lógicas
2. **Services**: Encapsulam lógica de negócios complexa (como integração com APIs externas)
3. **Models**: Representam os dados e as regras de negócio
4. **Views**: Apresentam os dados ao usuário final

## Modelos de Dados

### Diagrama de Entidade-Relacionamento

```
User (1) ------ (N) Bookshelf (1) ------ (N) BookshelfItem (N) ------ (1) Book
```

### Descrição dos Modelos

#### User

- Representa um usuário do sistema
- Atributos: email, password_digest, first_name, last_name
- Relacionamentos: tem muitas estantes (bookshelves)

#### Book

- Representa um livro na biblioteca
- Atributos: title, isbn, authors, publisher, published_date, language, description, page_count, thumbnail_url, preview_link, etc.
- Relacionamentos: pertence a muitas estantes através de bookshelf_items

#### Bookshelf

- Representa uma estante de livros do usuário
- Atributos: name, user_id
- Relacionamentos: pertence a um usuário, tem muitos livros através de bookshelf_items

#### BookshelfItem

- Representa a associação entre um livro e uma estante
- Atributos: bookshelf_id, book_id, status
- Relacionamentos: pertence a uma estante e a um livro

## Integração com a API do Google Books

A integração com a API do Google Books é feita através do serviço `GoogleBooksApiService`. Este serviço é responsável por:

1. Realizar buscas de livros por título, autor ou ISBN
2. Buscar detalhes de um livro específico por ID ou ISBN
3. Parsear e normalizar os dados recebidos da API

### Fluxo de busca e importação de livros:

```
1. Usuário faz uma busca na interface
2. Controller recebe a solicitação e chama o serviço GoogleBooksApiService
3. Serviço faz a requisição à API do Google Books
4. API retorna os resultados em formato JSON
5. Serviço processa e formata os dados
6. Controller renderiza os resultados na view
7. Usuário seleciona um livro para visualização e adiciona a estante
8. O livro é armazenado no banco de dados local
```

## Autenticação com JWT

A autenticação utiliza JSON Web Tokens (JWT) seguindo o fluxo:

```
1. Usuário fornece credenciais (email/senha)
2. Sistema valida as credenciais
3. Se válidas, gera um token JWT assinado
4. Token é retornado ao cliente
5. Cliente armazena o token e o inclui em requisições subsequentes
6. Sistema valida o token em cada requisição autenticada
```

### Implementação

- Utilizamos a gem `jwt` para codificar e decodificar tokens
- O segredo para assinar tokens é armazenado na variável de ambiente `JWT_SECRET_KEY`
- O tempo de expiração é configurado em `JWT_EXPIRATION_TIME` (em horas)

## Front-end e UI

### Tecnologias principais:

- **Bootstrap 5.3.3**: Framework CSS para layout e componentes responsivos
- **Turbo & Hotwire**: Para atualizações dinâmicas da interface sem recarregar a página
- **ERB**: Engine de templates padrão do Rails

### Estrutura de Views

- **Layouts**: Contém o template base da aplicação
- **Partials**: Componentes reutilizáveis como `_book_card.html.erb` e `_search_form.html.erb`
- **Views específicas**: Organizadas por controlador (books, bookshelves, etc.)

## API RESTful

O projeto expõe uma API RESTful para permitir integrações com outras aplicações:

### Autenticação da API

```ruby
# Exemplo de como autenticar via API:
POST /login
Content-Type: application/json

{
  "email": "usuario@exemplo.com",
  "password": "senha123"
}

# Resposta:
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "exp": "2023-12-31T23:59:59Z",
  "user": {
    "id": 1,
    "email": "usuario@exemplo.com",
    "first_name": "Nome",
    "last_name": "Sobrenome"
  }
}
```

### Uso do Token

```
GET /bookshelves
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

## Configuração de Ambiente

### Variáveis de Ambiente

O arquivo `.env` deve conter:

```
# Chaves API
GOOGLE_BOOKS_API_KEY=sua_chave_api_google_books

# Configurações JWT
JWT_SECRET_KEY=use_uma_chave_segura_e_aleatoria_aqui
JWT_EXPIRATION_TIME=24  # em horas
```

### Banco de Dados

O projeto utiliza PostgreSQL como banco de dados principal. A configuração do banco de dados está no arquivo `config/database.yml`.

## Fluxos de Usuário Principais

### Fluxo 1: Busca e Adição de Livro à Estante

```
1. Usuário acessa /books/search
2. Usuário insere termos de busca e seleciona o tipo (título/autor/ISBN)
3. Sistema exibe resultados da API do Google Books
4. Usuário clica em "Ver detalhes" de um livro específico
5. Sistema chama GoogleBooksApiService.find_by_id(id)
6. Book.find_or_create_from_api_data converte dados da API em um modelo Book
7. Usuário seleciona um livro para ver detalhes
8. Usuário importa livro
7. Usuário seleciona uma estante e status para adicionar o livro
8. Sistema cria um novo BookshelfItem associando o livro à estante
```

### Fluxo 2: Gerenciamento de Estante

```
1. Usuário acessa /bookshelves
2. Sistema exibe todas as estantes do usuário
3. Usuário seleciona uma estante específica
4. Sistema exibe todos os livros na estante com seus status
5. Usuário pode alterar status, remover livros ou adicionar novos
```

## Tratamento de Erros

O sistema inclui tratamento de erros para os seguintes cenários:

- Falhas de conexão com a API do Google Books
- Validações de modelo (livros duplicados, campos obrigatórios, etc.)
- Autenticação e autorização (tokens inválidos ou expirados)
- Erros de banco de dados

## Considerações de Performance

- A paginação é implementada para listagens de livros utilizando a gem `kaminari`
- Os resultados da API são cacheados quando apropriado
- As consultas ao banco de dados são otimizadas com índices nos campos de busca frequente

## Migrações e Manutenção de Banco de Dados

### Migração Inicial

```ruby
# Exemplo de migração para criar a tabela de livros
class CreateBooks < ActiveRecord::Migration[7.0]
  def change
    create_table :books do |t|
      t.string :title, null: false
      t.string :subtitle
      t.string :authors
      t.string :publisher
      t.string :published_date
      t.string :language
      t.text :description
      t.integer :page_count
      t.string :categories
      t.string :thumbnail_url
      t.string :preview_link
      t.string :info_link
      t.string :isbn
      t.string :google_books_id

      t.timestamps
    end

    add_index :books, :isbn, unique: true
    add_index :books, :google_books_id, unique: true
    add_index :books, :title
  end
end
```

## Suporte e Manutenção

### Logs Importantes

Os principais arquivos de log para depuração e monitoramento:

- `log/production.log`: Logs de ambiente de produção
- `log/development.log`: Logs de ambiente de desenvolvimento
- `log/test.log`: Logs de execução de testes

### Backup do Banco de Dados

Recomenda-se configurar backups automáticos do banco de dados PostgreSQL:

```bash
# Exemplo de script de backup
pg_dump -U postgres minha_estante_virtual_production > backup_$(date +%Y-%m-%d).sql
```

## Conclusão

Este projeto segue as melhores práticas de desenvolvimento Ruby on Rails, com foco em código limpo, organizado e bem testado. A arquitetura permite fácil manutenção e extensão, oferecendo uma base sólida para adicionar novas funcionalidades.

---

Documento atualizado em: Maio de 2025
