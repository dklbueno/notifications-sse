# Notification SSE (Server-Sent Events)

## Instalação

1. Faça uma cópia do arquivo **.env.example** como **.env**
```shell
cp .env.example .env
```

2. Crie um arquivo chamado **database.sqlite** na pasta **database**
```shell
sudo touch database/database.sqlite
```

3. Rode o comando de build do docker compose
```shell
docker compose build --no-cache
```

4. Rode o **composer install** dentro do container do docker
```shell
docker compose exec notifications-php-fpm composer install
```

5. Faça a migração das tabelas dentro do container do docker
```shell
docker compose exec notifications-php-fpm php artisan migrate
```

6. Rode os comandos **npm**
```shell
npm install && npm run dev
```

Agora sua aplicação está pronta para ser testada

1. Crie um usuário na rota **localhost:8000/register**

2. Logue com esse usuário e use o **php artisan tinker** dentro do docker para capturar seu id
```shell
docker compose exec -it notifications-php-fpm bash
```
```shell
php artisan tinker
```

3. Entre na rota **localhost:8000**. Essa rota ficará `escutando`os eventos

4. Use o **postman** ou **insomnia** com a rota **POST** **localhost:8000/notifications** com o payload
```javascript
{
    "user_id": id_do_usuario_logado,
    "from_app": "CRM",
    "message": "Mensagem Teste"
}
```