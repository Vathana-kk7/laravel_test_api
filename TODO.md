# Render Deployment Fix TODO

## Status: In Progress

### 1. ✅ Create TODO.md [DONE]

### 2. ✅ Fix start.sh syntax error and DB connection logic [DONE]
   - Restructured DB wait with `until` loop + exit codes
   - Simplified TCP test with `nc`
   - Added 60s retry timeout
   - Fixed port fallback `${PORT:-8000}`

### 3. ✅ Productionize Dockerfile [DONE]
   - Multi-stage: composer -> nginx + php8.2-fpm + supervisor
   - nginx.conf + supervisord.conf added
   - npm build + vendor caching
   - start.sh runs setup only

### 4. ✅ Update documentation [DONE]
   - Added Render deployment guide to README.md
   - Add Render env var instructions to README.md

### 5. Test changes locally with Docker
   ```bash
   docker build -t attendance .
   docker run -p 8080:80 -e DB_HOST=host.docker.internal -e DB_PORT=3306 ... attendance
   ```

### 6. Deploy to Render**

**Next step: Fix start.sh**

