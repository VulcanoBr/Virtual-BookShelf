# Guia de Instalação Rápida - Virtual BookShelf

Este guia tem como objetivo ajudar você a configurar e executar o projeto "Minha Estante Virtual" rapidamente em seu ambiente de desenvolvimento.

## 📋 Pré-requisitos

Antes de começar, certifique-se de ter instalado:

- [Ruby](https://www.ruby-lang.org/pt/downloads/) (versão 3.3.4)
- [Rails](https://rubyonrails.org/) (versão 7.2.1 )
- [PostgreSQL](https://www.postgresql.org/download/) (versão 12 ou superior)
- [Node.js](https://nodejs.org/) (versão 20.18)
- [Yarn](https://yarnpkg.com/getting-started/install)
- [Git](https://git-scm.com/downloads)

## 🚀 Instalação Passo a Passo

### 1. Clone o repositório

```bash
git clone https://github.com/vulcanobr/virtual-bookshelf.git
cd virtual-bookshelf
```

### 2. Instale as dependências Ruby

```bash
bundle install
```

### 3. Instale as dependências JavaScript

```bash
yarn install
```

### 4. Configure as variáveis de ambiente

Crie um arquivo `.env` na raiz do projeto com o seguinte conteúdo:

```
# Obtenha sua chave API em https://console.cloud.google.com/apis/credentials
GOOGLE_BOOKS_API_KEY=sua_chave_api_google_books

# Gere uma chave segura usando: rails secret
JWT_SECRET_KEY=chave_secreta_gerada_pelo_rails_secret
JWT_EXPIRATION_TIME=24
```

Para gerar uma chave segura para o JWT, use:

```bash
rails secret
```

### 5. Configure o banco de dados

Edite o arquivo `config/database.yml` conforme necessário e execute:

```bash
rails db:create
rails db:migrate
```

### 6. Inicie o servidor

```bash
# Para desenvolvimento com hot-reloading
bin/dev

# OU usando o servidor Rails padrão
rails server
```

Acesse a aplicação em [http://localhost:3000]

## 📱 Testando a API

Você pode testar a API usando ferramentas como [Postman](https://www.postman.com/) ou [Insomnia](https://insomnia.rest/).

### Exemplo de autenticação:

```
POST http://localhost:3000/login
Content-Type: application/json

{
  "email": "usuario@exemplo.com",
  "password": "senha123"
}
```

### Exemplo de busca de livros:

```
GET http://localhost:3000/books/search?q=harry+potter&type=title
Authorization: Bearer seu_token_jwt_aqui
```

## 🐛 Solução de Problemas Comuns

### Problemas com o PostgreSQL

Se você encontrar erros de conexão com o PostgreSQL:

```bash
# Verifique se o serviço está em execução
sudo service postgresql status

# Inicie o serviço se necessário
sudo service postgresql start
```

### Problemas com dependências JavaScript

```bash
# Limpe o cache do Yarn
yarn cache clean

# Reinstale as dependências
yarn install
```

### Erro de "Webpacker::Manifest::MissingEntryError"

```bash
# Execute o webpack dev server
bin/webpack-dev-server
```

### Problemas com a API do Google Books

Verifique se:

- Sua chave API está correta no arquivo `.env`
- A API do Google Books está habilitada na sua conta do Google Cloud Platform
- As cotas da API não foram excedidas

## 📚 Recursos Úteis

- [Documentação do Ruby on Rails](https://guides.rubyonrails.org/)
- [Documentação do Bootstrap 5](https://getbootstrap.com/docs/5.3/getting-started/introduction/)
- [Documentação da API do Google Books](https://developers.google.com/books/docs/v1/using)
- [Tutoriais sobre JWT em Rails](https://www.pluralsight.com/guides/token-based-authentication-with-ruby-on-rails-5-api)

## 🤝 Obtendo Ajuda

Se você tiver dúvidas ou encontrar problemas:

1. Verifique as issues existentes no GitHub
2. Crie uma nova issue com descrição detalhada do problema
3. Entre em contato com a equipe de desenvolvimento

---

⭐️ Boa codificação! ⭐️
