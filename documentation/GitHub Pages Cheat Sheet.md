# GitHub Pages

This guide shows how to host a secure apex and www domain page for free using GitHub Pages and IONOS.

- **Primary (canonical) domain**: `example.com` (apex)
- **Alternate domain**: `www.example.com` (redirects to apex)
- **Hosting**: GitHub Pages
- **DNS provider / registrar**: IONOS
- **TLS certificate**: Issued/managed by GitHub Pages (Let’s Encrypt)

---

## 1) Create the repo (User/Org GitHub Pages site)

To host an apex domain most simply, use a **user/org Pages repo**.

- **Create a new repository** in the GitHub **user or organization** that should own the website
- **Name it exactly**: `<account>.github.io`
  - Example (this org): `nohype-ai.github.io` (repo: `nohype-ai/nohype-ai.github.io`)
- **Visibility**: make it **Public** (GitHub Pages on Free requires public repos)
- Add your site files (e.g. `index.html`) to the repo root
- Before adding a custom domain, the site will be available at `https://<account>.github.io`

---

## 2) Configure GitHub Pages settings

In GitHub:

1. Go to **Repo → Settings → Pages**
2. **Build and deployment**
   - Source: **Deploy from a branch**
   - Branch: `main` (or your branch)
   - Folder: `/ (root)` if `index.html` is at repo root
3. **Custom domain**
   - Enter the apex: `example.com`
   - Click **Save**
4. (Optional but recommended) **Verify the domain**
   - Do this in **profile/org settings** (not the repo):
     - **User**: `GitHub → Settings → Pages → Add a domain`
     - **Org**: `GitHub → Your profile menu → Organizations → <org> → Settings → Pages → Add a domain`
     - Docs: [Verifying your custom domain for GitHub Pages](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/verifying-your-custom-domain-for-github-pages)
   - GitHub will give you a **TXT record** to create at **IONOS DNS** (often named like `_github-pages-challenge-<account>` with a random value).
   - **Keep this TXT record permanently**: if you delete it later, the domain can lose its verified status.
5. **Enforce HTTPS**
   - This toggle may appear only after DNS is correct.
   - Turn it on once available.

Notes:
- If you set a custom domain in GitHub Pages, GitHub will usually create/commit a `CNAME` file into the publishing source. That `CNAME` should contain the custom domain (e.g. `example.com`).
- If you’re using a custom GitHub Actions Pages workflow, GitHub may ignore any repo `CNAME` file; the domain is still configured in Settings.

---

## 3) Configure DNS at IONOS (apex + `www`)

Open IONOS DNS settings for the domain.

### 3.1 Remove conflicting IONOS features (common hidden cause)

In IONOS, disable any of these if enabled for the domain/hostnames:

- “Parking”
- “Web forwarding” / “Forwarding”
- “Webspace” default destination

These can interfere even when DNS records look correct.

### 3.2 Apex (`example.com`) — A records (required)

Create **four** `A` records for the apex.

- **Type**: `A`
- **Hostname/Name**: `@` (or blank/root in IONOS UI)
- **TTL**: `3600` (1 hour) is fine
- **Values** (4 separate records):
  - `185.199.108.153`
  - `185.199.109.153`
  - `185.199.110.153`
  - `185.199.111.153`

### 3.3 Apex (`example.com`) — AAAA records (optional but recommended)

Create **four** `AAAA` records for IPv6.

- **Type**: `AAAA`
- **Hostname/Name**: `@` (or blank/root)
- **TTL**: `3600`
- **Values** (4 separate records):
  - `2606:50c0:8000::153`
  - `2606:50c0:8001::153`
  - `2606:50c0:8002::153`
  - `2606:50c0:8003::153`

### 3.4 `www.example.com` — CNAME record (recommended)

This is the key part: **do not** point `www` with A/AAAA records. Use a CNAME to your GitHub Pages host.

- **Type**: `CNAME`
- **Hostname/Name**: `www`
- **Value/Target**: `<account>.github.io`
  - Example (this org): `nohype-ai.github.io`
- **TTL**: `3600`

#### Important: don’t let IONOS auto-create `www` A/AAAA records

If IONOS automatically adds `www` records (often `A` + `AAAA`):

- Delete those `www` **A**/**AAAA** records
- Keep only the `www` **CNAME** → `<account>.github.io`

Why: GitHub’s Pages health check expects the `www` variant to be a CNAME to the GitHub Pages hostname for reliable redirects + HTTPS behavior. See GitHub’s custom domain documentation:  
[Managing a custom domain for your GitHub Pages site](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/managing-a-custom-domain-for-your-github-pages-site)

### 3.5 TXT records (SPF / mail)

- SPF TXT records like `v=spf1 include:_spf-eu.ionos.com ~all` are **for email** and **not required** for GitHub Pages.
- Keep them if you use IONOS mail; they won’t affect Pages.

---

## 4) Validate DNS from your Mac (fast checks)

Replace `example.com` with your domain.

### Apex A records

```bash
dig example.com +noall +answer -t A
```

Expected: four `185.199.108–111.153` records.

### Apex AAAA records (if you configured them)

```bash
dig example.com +noall +answer -t AAAA
```

Expected: four `2606:50c0:8000–8003::153` records.

### `www` CNAME

```bash
dig www.example.com +noall +answer -t CNAME
```

Expected: `www.example.com CNAME <account>.github.io.`

### Check what public DNS resolvers see (good for propagation)

```bash
dig @8.8.8.8 example.com A +noall +answer
dig @1.1.1.1 www.example.com CNAME +noall +answer
```

---

## 5) Validate that GitHub is serving the site (what health checks care about)

GitHub’s health check effectively wants your domain to be **served by GitHub Pages**.
You can sanity-check via headers:

```bash
curl -I -L --max-time 20 http://example.com
curl -I -L --max-time 20 https://example.com
curl -I -L --max-time 20 http://www.example.com
curl -I -L --max-time 20 https://www.example.com
```

Healthy signs:
- `Server: GitHub.com`
- `X-GitHub-Request-Id` header present
- `www` redirects to apex (or vice versa, depending on what you set as custom domain in GitHub)

---

## 6) Turn on HTTPS in GitHub Pages

In **Repo → Settings → Pages**:

- Wait until the custom domain shows as configured/valid.
- Enable **Enforce HTTPS** when the checkbox appears.

Notes:
- It can take time (minutes to hours) after DNS is correct for GitHub to issue the cert.
- Sometimes the status flips between orange/green briefly while GitHub revalidates.

---

## 7) Troubleshooting checklist (when DNS looks right but GitHub complains)

### If GitHub says `InvalidDNSError` for `www`
- You probably deleted `www` records and haven’t added the `www` CNAME yet, or it hasn’t propagated.

### If GitHub says `NotServedByPagesError` even though `dig` is correct
Common causes:
- IONOS **forwarding/parking** still enabled (not visible as a DNS record)
- `www` is not a CNAME (e.g. it’s A/AAAA instead)
- GitHub validation is **stale/lagging**

Fixes that commonly work:
- Ensure `www` is **CNAME → `<account>.github.io`** (and no `www` A/AAAA)
- Temporarily remove the custom domain in GitHub Pages settings, save, then add it back
- Wait (GitHub’s health checks can lag behind DNS reality)

### Don’t use wildcard DNS
Avoid records like `*.example.com`—GitHub strongly discourages them due to takeover risk.  
([docs](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/managing-a-custom-domain-for-your-github-pages-site))

---

## Reference: GitHub’s official DNS targets (apex)

From GitHub Docs: [Managing a custom domain for your GitHub Pages site](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/managing-a-custom-domain-for-your-github-pages-site)

- **A (IPv4)**:
  - `185.199.108.153`
  - `185.199.109.153`
  - `185.199.110.153`
  - `185.199.111.153`
- **AAAA (IPv6)**:
  - `2606:50c0:8000::153`
  - `2606:50c0:8001::153`
  - `2606:50c0:8002::153`
  - `2606:50c0:8003::153`
