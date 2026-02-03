# Copilot instructions for kpax 🧭

Purpose
- This repository is a small polyglot "dev" playground: multiple minimal web services (Go, Node, Python, .NET, Java, Rust, Zig, etc.) live in top-level language folders and each exposes a simple JSON endpoint at `/`.
- Primary goal for agents: make small, well-scoped changes per-language and ensure services run locally or in Docker Compose without breaking the chain.

Big picture / Architecture
- Each language folder (e.g. `go/`, `node/`, `python/`, `dotnet/`, `java/`, `rust/`, `zig/`) is an independent microservice example. Services are intentionally minimal: a single HTTP endpoint returning `{"message":"hello world"}`.
- Orchestration: `docker-compose.yml` defines service images, mounts, run commands and a sequential `depends_on` chain. Inside containers services typically listen on port `8080`; host ports map to `30xx` (see `docker-compose.yml` for exact mapping).

Key files to reference
- Compose and orchestration: `docker-compose.yml`
- Dotnet: `dotnet/Program.cs`, `dotnet/dotnet.csproj` (uses minimal API + OpenAPI)
- Go: `go/main.go`
- Node: `node/index.js`, `node/package.json`
- Python: `python/main.py`, `python/pyproject.toml`, `python/test_main.http` (simple HTTP client tests)
- Java: `java/pom.xml`, `java/src/main/java/...` (Spring Boot `DemoApplication`)
- Rust: `rust/Cargo.toml`, `rust/src/main.rs`
- Zig: `zig/build.zig`
- UI templates: `ui/*/README.md` (React/Angular/Vue/Svelte templates)

Common developer workflows (concrete commands)
- Start all services (recommended smoke test):
  - docker: `docker compose up --build` (or `docker-compose up --build` depending on your Docker CLI)
  - follow logs: `docker compose logs -f` or `docker compose logs -f <service>`
- Run a single service locally (examples):
  - Go: `cd go && go run main.go` (listens on :8080 by docker convention)
  - Node: `cd node && npm install && npm start` (defaults to `PORT=8080` inside containers)
  - Python: `pip install --no-cache-dir fastapi uvicorn && uvicorn main:app --host 0.0.0.0 --port 8080` (note: `test_main.http` uses port 8000 — adjust when running locally)
  - .NET: `dotnet run --project dotnet.csproj --urls http://0.0.0.0:8080` (OpenAPI is enabled only in Development environment)
  - Java: `mvn spring-boot:run -Dspring-boot.run.jvmArguments=-Dserver.port=8080`
  - Rust: `cargo run`
  - Zig: `zig build run`

Project-specific conventions & gotchas
- Internal port convention: containers → `8080` (most `Dockerfile`/compose commands assume this), host port mapping is `30xx` series. When testing locally, be aware of files that expect different ports (e.g., `python/test_main.http` uses `8000`).
- Dotnet OpenAPI is gated by environment: the code calls `MapOpenApi()` only when `app.Environment.IsDevelopment()` — to get Swagger in Docker set `ASPNETCORE_ENVIRONMENT=Development` or run locally in Development mode.
- Dotnet image mismatch: project targets `net10.0` (`dotnet.csproj`) but `docker-compose.yml` uses `mcr.microsoft.com/dotnet/sdk:8.0`. Confirm SDK/runtime versions before making changes that rely on newer frameworks.
- Minimal / single-file pattern: the services are intentionally small and idiomatic for each language. Changes should follow the existing minimal style unless adding a larger feature across the repo.

Integration and cross-component patterns
- There are no shared databases or message buses in this repository — services are isolated and linked only by Docker Compose startup order.
- Use `docker compose logs` and per-service ports to validate cross-service interactions; there is no RPC or external infra configured here.

What an AI agent should do (operational guidance)
- Prefer small, discoverable changes in one language at a time and run the impacted service locally or via `docker compose up` to validate behavior.
- When modifying API surface, update any example tests (`python/test_main.http`) and `docker-compose.yml` if default ports or commands change.
- Avoid changing global tooling (e.g., bumping SDKs, adding CI) without explicit confirmation — call out compatibility risks in PR descriptions.

Examples (explicit snippets)
- Start full suite: `docker compose up --build`
- Run node locally: `cd node && npm install && npm start` (then curl `http://localhost:3020/` if you are using the compose host mapping)
- Enable dotnet OpenAPI in Docker: `docker compose run -e ASPNETCORE_ENVIRONMENT=Development dotnet` (or add the env var to the `dotnet` service in `docker-compose.yml`)

Reporting & PR notes
- Include which service you ran and how you validated changes (command + endpoint + sample response).
- Note any environment differences (e.g., local uvicorn default port 8000 vs container 8080, or SDK mismatch) as part of the PR description.

If anything here is unclear or you'd like additional project-specific checks (lint commands, CI rules, or stricter test examples), tell me what to expand and I'll iterate. ✅
