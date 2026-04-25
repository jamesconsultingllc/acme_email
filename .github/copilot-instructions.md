# Copilot instructions for acme_email

ACME Email S/MIME client implementing the **EmailReply-00 challenge** (RFC 8823) on top of Certbot, targeting the CASTLE Platform® ACME server. Distributed as the `certbot-castle` package and a `cli.py` driver.

## Setup, build, run

```bash
python3 -m venv venv
source venv/bin/activate          # Windows: .\venv\Scripts\activate
pip install .                     # installs certbot-castle + plugin entry points
python cli.py {cert,revoke,renew} ...
```

Docker: `docker compose build && docker compose run --rm acme-email-client cert -e ...`. Windows helpers: `docker-run.bat` / `docker-run.ps1`. See `DOCKER.md`.

There is currently **no test suite, linter config, or CI workflow** in this repo. Do not invent commands for these; if testing is needed, smoke-test against the staging server using `-t` plus `--dry-run`:

```bash
python cli.py cert -t --dry-run -e you@example.com --contact you@example.com
```

### Copilot CLI in this repo

Launch the CLI via the repo wrapper, not bare `copilot`, so all contributors share the same MCP servers (defined in `.copilot/mcp-config.json`):

```powershell
.\copilot.ps1     # Windows
./copilot.sh      # macOS/Linux
```

The wrapper sets `COPILOT_HOME` to `<repo>/.copilot`. Only `mcp-config.json` is committed; everything else under `.copilot/` (sessions, logs, plugins) is git-ignored per-dev state.

## Architecture — the workaround that drives everything

Certbot upstream only supports `dns` identifier types in CSRs, but RFC 8823 requires `email` identifiers. The whole codebase is structured around bypassing that limitation:

1. `cli.py` parses our own argparse surface, then **rewrites args into Certbot's internal CLI** (`certbot._internal.cli.prepare_and_parse_args`) and invokes `certbot_main._csr_get_and_save_cert` / `_install_cert` directly. This is why `cli.py` reaches into `certbot._internal.*` — public Certbot APIs do not expose what we need.
2. `certbot_castle/csr.py` builds the CSR locally with **both `RFC822Name` and `DNSName`** SANs for every email (Certbot validates DNSName presence; the ACME server uses RFC822Name). Always preserve this dual-SAN pattern.
3. The CSR is then handed to Certbot via `--csr`, sidestepping its identifier-type assumptions.
4. `certbot_castle/challenge.py` registers the `email-reply-00` challenge type with `acme.challenges` so Certbot's flow can dispatch it.

When changing CLI flags, update **both** `parse_args()` in `cli.py` and the corresponding `prepare_cli_args()` translation that maps them onto the plugin-prefixed Certbot args (e.g. `--login` → `--castle-imap-login`).

## Plugin layout

Plugins are registered as Certbot entry points in `setup.py` under `certbot.plugins`. Each is selected by name on the rewritten Certbot CLI:

| Entry point name        | Module                                    | Role          | Selected by                |
|-------------------------|-------------------------------------------|---------------|----------------------------|
| `castle-interactive`    | `certbot_castle.plugins.interactive`      | Authenticator | default (no flag)          |
| `castle-imap`           | `certbot_castle.plugins.imap`             | Authenticator | `--imap`                   |
| `castle-mapi`           | `certbot_castle.plugins.mapi`             | Authenticator | `--outlook`                |
| `castle-tb`             | `certbot_castle.plugins.thunderbird`      | Authenticator | `--tb`                     |
| `castle-installer`      | `certbot_castle.plugins.installer`        | Installer     | always (`-i`)              |

Shared challenge helpers (DKIM verification, S/MIME / PKCS7 parsing, exceptions) live in `certbot_castle/plugins/castle/`. New authenticators should consume these rather than reimplementing message validation.

After editing `setup.py` entry points, **reinstall** (`pip install .`) — Certbot's plugin discovery reads installed metadata, not the source tree.

## Conventions

- Python 2.7 + Python ≥ 3.6 are both declared supported in `setup.py`. Avoid 3.10+-only syntax (no `match`, no PEP 604 `X | Y` types, no `tomllib`).
- `pywin32` is a conditional dep added only on `win32` — keep MAPI/Outlook code paths inside the `mapi.py` / `thunderbird.py` plugins so importing the package on Linux does not require it.
- The installer produces a **PKCS12 container with embedded private key**. `revoke` accepts that `.p12` directly — see `try_open_p12` in `cli.py` for the passphrase-prompt flow that must be preserved when adding new credential sources.
- Two CASTLE root CA SHA-256 fingerprints are pinned in `cli.py::root_cert_advise`. Update them in lockstep if CASTLE rotates roots.
- Server URLs are hard-coded: `https://acme.castle.cloud/acme/directory` (prod) and `https://acme-staging.castle.cloud/acme/directory` (staging via `-t`).
- Only `keyUsage` and `subjectAltNames` extensions are permitted in the CSR — the server rejects anything else. Do not add extensions in `csr.py`.
- Wildcards in `--email` are explicitly rejected in `process_args`; keep that guard.

## License

GPLv3. Any new files should carry compatible headers.
