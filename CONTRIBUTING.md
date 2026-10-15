# Contributing

Thanks for your interest in improving this landing zone! Issues and pull requests are welcome.

## Before you start

- For larger changes (new modules, new services, breaking changes, compliance scope), open an
  issue first so we can agree on the approach.
- Security issues: follow [SECURITY.md](SECURITY.md), not public issues.
- Be kind: this project follows the [Code of Conduct](CODE_OF_CONDUCT.md).

## Development setup

Tools: Terraform >= 1.9, [TFLint](https://github.com/terraform-linters/tflint),
[Trivy](https://github.com/aquasecurity/trivy), [terraform-docs](https://terraform-docs.io),
[shellcheck](https://www.shellcheck.net) and optionally [pre-commit](https://pre-commit.com).

```bash
pre-commit install            # optional: run the checks on every commit

terraform fmt -recursive
terraform init -backend=false && terraform validate && terraform test
(cd platform && terraform init -backend=false && terraform validate && terraform test)
tflint --init && tflint --recursive --config "$PWD/.tflint.hcl"
trivy config .
./scripts/generate-docs.sh
```

All of these run in CI (`.github/workflows/ci.yml`) without Azure credentials. The tests use
mocked providers (`tests/mocks`), so they are free and safe to run anywhere.

## Conventions

- **Private by default**: new PaaS resources disable public network access and local/key
  authentication, use private endpoints with `private_dns_zone_group`, managed identities and
  RBAC, and send diagnostics to Log Analytics.
- **Naming**: `{prefix}-{env}-{region}-{type}-{instance}`; globally unique names also include
  `unique_suffix`. Add a test when you add a globally unique resource.
- **Feature flags**: optional services are behind `enable_*` variables (module `count`).
- **Variables** have a `description`, a `type` and, where useful, a `validation` block.
- **Docs**: run `./scripts/generate-docs.sh` after changing variables/outputs; update
  `docs/diagrams/*.drawio` (and the exported `.svg`) when the architecture changes.
- **Changelog**: add a line under *Unreleased* in [CHANGELOG.md](CHANGELOG.md).

## Pull requests

1. Fork, create a feature branch, make focused commits.
2. Make sure CI passes.
3. Describe what you tested (ideally a `terraform plan` in a dev subscription, redacted).
