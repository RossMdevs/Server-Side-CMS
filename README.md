# SOFTWARE PROVIDED AS-IS. NO SUPPORT OFFERED.

This is a simple AI-developed API designed for interal conduct reporting in FiveM. It can write, delete, and look up player data. The Express server can serve content through browsers to the `/public/` directory, which can also be disabled for an API-only setup. It serves off port 3000, which can be modified per need. 

# API Example
To add a player record, use the following command:
```bash
curl -X POST http://localhost:3000/api/record -H "Content-Type: application/json" -d "{\"player_name\":\"John Doe\", \"fivem_license\":\"license123\", \"warn_ban\":\"Warn\", \"conduct_id\":\"conduct001\", \"reason\":\"Inappropriate behavior\"}"
```

# Requirements:
- **Node Package Manager (NPM)**
  - `express`
  - `cors`
  - `mysql` (for both NPM and the server)
  - `path`
- **Node.js**
- **Public Intranet/Network**
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

# Proxy: 
```server {
    listen 80;
    listen [::]:80;

    server_name cms.domain.tld;
        
    location / {
        proxy_pass IPADDR:3000;
        include proxy_params;
    }
}```
