<p align="center"><a href="https://laravel.com" target="_blank"><img src="https://raw.githubusercontent.com/laravel/art/master/logo-lockup/5%20SVG/2%20CMYK/1%20Full%20Color/laravel-logolockup-cmyk-red.svg" width="400" alt="Laravel Logo"></a></p>

<p align="center">
<a href="https://github.com/laravel/framework/actions"><img src="https://github.com/laravel/framework/workflows/tests/badge.svg" alt="Build Status"></a>
<a href="https://packagist.org/packages/laravel/framework"><img src="https://img.shields.io/packagist/dt/laravel/framework" alt="Total Downloads"></a>
<a href="https://packagist.org/packages/laravel/framework"><img src="https://img.shields.io/packagist/v/laravel/framework" alt="Latest Stable Version"></a>
<a href="https://packagist.org/packages/laravel/framework"><img src="https://img.shields.io/packagist/l/laravel/framework" alt="License"></a>
</p>

## About Laravel

Laravel is a web application framework with expressive, elegant syntax. We believe development must be an enjoyable and creative experience to be truly fulfilling. Laravel takes the pain out of development by easing common tasks used in many web projects, such as:

- [Simple, fast routing engine](https://laravel.com/docs/routing).
- [Powerful dependency injection container](https://laravel.com/docs/container).
- Multiple back-ends for [session](https://laravel.com/docs/session) and [cache](https://laravel.com/docs/cache) storage.
- Expressive, intuitive [database ORM](https://laravel.com/docs/eloquent).
- Database agnostic [schema migrations](https://laravel.com/docs/migrations).
- [Robust background job processing](https://laravel.com/docs/queues).
- [Real-time event broadcasting](https://laravel.com/docs/broadcasting).

Laravel is accessible, powerful, and provides tools required for large, robust applications.

## Learning Laravel

Laravel has the most extensive and thorough [documentation](https://laravel.com/docs) and video tutorial library of all modern web application frameworks, making it a breeze to get started with the framework.

You may also try the [Laravel Bootcamp](https://bootcamp.laravel.com), where you will be guided through building a modern Laravel application from scratch.

If you don't feel like reading, [Laracasts](https://laracasts.com) can help. Laracasts contains thousands of video tutorials on a range of topics including Laravel, modern PHP, unit testing, and JavaScript. Boost your skills by digging into our comprehensive video library.

## Laravel Sponsors

We would like to extend our thanks to the following sponsors for funding Laravel development. If you are interested in becoming a sponsor, please visit the [Laravel Partners program](https://partners.laravel.com).

### Premium Partners

- **[Vehikl](https://vehikl.com/)**
- **[Tighten Co.](https://tighten.co)**
- **[WebReinvent](https://webreinvent.com/)**
- **[Kirschbaum Development Group](https://kirschbaumdevelopment.com)**
- **[64 Robots](https://64robots.com)**
- **[Curotec](https://www.curotec.com/services/technologies/laravel/)**
- **[Cyber-Duck](https://cyber-duck.co.uk)**
- **[DevSquad](https://devsquad.com/hire-laravel-developers)**
- **[Jump24](https://jump24.co.uk)**
- **[Redberry](https://redberry.international/laravel/)**
- **[Active Logic](https://activelogic.com)**
- **[byte5](https://byte5.de)**
- **[OP.GG](https://op.gg)**

## Contributing

Thank you for considering contributing to the Laravel framework! The contribution guide can be found in the [Laravel documentation](https://laravel.com/docs/contributions).

## Code of Conduct

In order to ensure that the Laravel community is welcoming to all, please review and abide by the [Code of Conduct](https://laravel.com/docs/contributions#code-of-conduct).

## Security Vulnerabilities

If you discover a security vulnerability within Laravel, please send an e-mail to Taylor Otwell via [taylor@laravel.com](mailto:taylor@laravel.com). All security vulnerabilities will be promptly addressed.



## 🚀 Render.com Deployment Guide

### Prerequisites
1. **Database**: Use Render PostgreSQL (recommended) or MySQL. Get connection details from Render Dashboard.
2. **GitHub Repo**: Push code to GitHub, connect Render Web Service to repo.

### Environment Variables (Render Dashboard → Environment)
```
DB_CONNECTION=mysql  # or pgsql
DB_HOST=your-db-internal-url.render.com
DB_PORT=3306  # or 5432 for Postgres
DB_DATABASE=your_db_name
DB_USERNAME=your_db_user
DB_PASSWORD=your_db_pass

APP_ENV=production
APP_DEBUG=false
APP_KEY=base64:...  # Run `php artisan key:generate --show` locally, paste here
APP_URL=https://your-app.onrender.com

# For SSL MySQL (if needed):
MYSQL_ATTR_SSL_CA=(upload CA cert as Private File)

# Cache/Queue (optional):
CACHE_DRIVER=redis  # if using Render Redis
SESSION_DRIVER=redis
QUEUE_CONNECTION=redis
```

**Important**: 
- Enable **Outbound Networking** if using external DB (Dashboard → Settings).
- For MySQL SSL: Upload CA cert as Private File, set `MYSQL_ATTR_SSL_CA=<private_file_name>`.

### Deploy Steps
1. Render Dashboard → New → Web Service → Connect GitHub repo.
2. Runtime: `Docker`
3. Build Command: (auto - docker build)
4. Start Command: (auto - from Dockerfile CMD)
5. Add Env Vars above.
6. Deploy!

### Troubleshooting
- **Auto-deploy not triggering on git push**:
  1. Dashboard → Service → **Settings** → Auto-deploy: "On main branch pushes" ✓
  2. **Connected Repo** tab: Verify GitHub repo/branch correct (main/master).
  3. Push to correct branch: `git push origin main`
  4. Previous build failed? → Manual Deploy → Clear cache.
- **PDO greeting packet**: DB wait loop + config fixes. Check env vars/DB firewall.
- **Syntax error start.sh**: Fixed.
- **Build fails**: Logs → docker issues (missing deps).
- Logs: Dashboard → Logs tab.

### Local Test
```bash
docker build -t attendance .
docker run -p 80:80 \
  -e DB_HOST=host.docker.internal \
  -e DB_PORT=3306 \
  -e DB_DATABASE=your_local_db \
  -e DB_USERNAME=root \
  -e DB_PASSWORD=pass \
  -e APP_KEY=base64:yourkey \
  attendance
```

Visit `http://localhost` (or `localhost:8080`).

## License

The Laravel framework is open-sourced software licensed under the [MIT license](https://opensource.org/licenses/MIT).

