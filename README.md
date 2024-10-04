# SOFTWARE PROVIDED AS-IS. NO SUPPORT OFFERED.

This is a simple AI-developed API for internal conduct reporting in FiveM. It can write, delete, and look up player data. The Express server can serve content through the `/public/` directory, which can be disabled for an API-only setup. The server runs on port 3000 by default, but this can be modified as needed. 

# API Example
To add a player record, use the following command (Please not this is unsafe, unless sanitized and tested):
```bash
curl -X POST http://localhost:3000/api/record -H "Content-Type: application/json" -d "{\"player_name\":\"John Doe\", \"fivem_license\":\"license123\", \"warn_ban\":\"Warn\", \"conduct_id\":\"conduct001\", \"reason\":\"Inappropriate behavior\"}"
```

# Setup Instructions
To set up your project, run:
```bash
mkdir cli-cms
cd cli-cms
npm init -y
```

# Requirements
To install dependencies, run:
```bash
npm install express cors mysql path body-parser
```
- **Node Package Manager (NPM)**
  - `express`
  - `cors`
  - `mysql` (for both NPM and the server)
  - `path`
  - `body-parser`
- **Node.js**
- **Public Intranet/Network** (unless resolving internally)
- **MySQL Server** (MariaDB, MySQL, etc.)
  - **Must use `IDENTIFIED WITH mysql_native_password`; legacy methods are not supported.**

# Project Structure
```
/cli-cms
├── node_modules
├── public
│   ├── index.html
│   ├── styles.css
│   └── script.js
├── server.js
├── package.json
└── package-lock.json
```

# Proxy Configuration
```nginx
server {
    listen 80;
    listen [::]:80;

    server_name cms.domain.tld;

    location / {
        proxy_pass http://IPADDR:3000;
        include proxy_params;
    }
}
```
