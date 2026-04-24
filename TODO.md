# Render Deployment Fix TODO

## Status: In Progress

### 7. Fix `npm ci --only=production` error on Render [IN PROGRESS]
**Problem:** Render build fails with `npm ci --only=production` because all deps are `devDependencies`.
**Fix:** `Dockerfile` updated to use `npm ci` (no `--only=production`), plus:
  - Copy `package.json` + `package-lock.json` first for layer caching
  - Add `node --version && npm --version && ls -la package*.json` for debugging
  - Install latest npm via `npm install -g npm@latest`
  - Separate `npm ci` and `npm run build` into distinct steps
**Next:** Commit + push updated `Dockerfile`, then clear Render build cache & redeploy.

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

### 5. ✅ Local test [SKIPPED - no Docker installed]

### 6. ✅ Deploy to Render [USER ACTION]
**If not auto-updating:**
1. Render Dashboard → Web Service → **Manual Deploy** → "Clear build cache & deploy latest commit"
2. Or: `git commit --allow-empty -m "force-render-rebuild" && git push`
3. Check Build/Deploy logs for errors
4. Verify env vars set (DB_HOST etc.)

**Expected:** No more syntax errors, PDO connects after 60s wait.

### ALL STEPS COMPLETE ✅

