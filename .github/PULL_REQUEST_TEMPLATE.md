## What and why

<!-- What does this change and why? Link related issues (Fixes #123). -->

## Type of change

- [ ] Bug fix
- [ ] New feature / module capability
- [ ] Breaking change (renames, removed variables, resource replacement)
- [ ] Documentation / diagrams
- [ ] CI / tooling

## Checklist

- [ ] `terraform fmt -recursive` and `terraform validate` pass (root and `platform/`)
- [ ] `terraform test` passes (root and `platform/`)
- [ ] `tflint --recursive` and `trivy config .` are clean
- [ ] `./scripts/generate-docs.sh` was run (module READMEs / `docs/reference.md` updated)
- [ ] Diagrams in `docs/diagrams/` updated if the architecture changed
- [ ] `CHANGELOG.md` updated under *Unreleased*
- [ ] Tested in a dev subscription (describe below), or explain why not needed

## Plan / test evidence

<!-- Paste relevant `terraform plan` summary or test output. Remove subscription IDs and secrets. -->
