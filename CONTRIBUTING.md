# Contributing to eShop Platform Infrastructure

## Branching Strategy

We follow a Git Flow-inspired branching model:

```
feature/*  →  develop  →  main (production)
    │            │           │
    │            │           └── Production releases
    │            └── Integration & testing
    └── Feature development
```

### Branch Types

| Branch | Purpose | Deploys To |
|--------|---------|------------|
| `main` | Production-ready code | Production (eshop namespace) |
| `develop` | Integration branch | Staging (eshop-staging namespace) |
| `feature/*` | New features | Dev (eshop-dev namespace) |
| `hotfix/*` | Production fixes | Direct to main after testing |
| `release/*` | Release preparation | Staging, then main |

### Workflow

#### 1. Feature Development

```bash
# Create feature branch from develop
git checkout develop
git pull origin develop
git checkout -b feature/my-new-feature

# Make changes
# ... edit files ...

# Commit with conventional commits
git add .
git commit -m "feat: add new basket caching logic"

# Push and create PR
git push -u origin feature/my-new-feature
gh pr create --base develop --title "feat: Add new basket caching" --body "..."
```

#### 2. PR Validation

When you create a PR:
- **Target: develop** → Runs lint, security scan, helm validation
- **Target: main** → Same + requires approval + runs full test suite

#### 3. Integration (develop branch)

After merging to develop:
- CI runs validation
- ArgoCD syncs to staging namespace (manual sync)
- Integration tests run

#### 4. Production Release (main branch)

```bash
# Create release branch
git checkout develop
git checkout -b release/v1.2.0

# Update versions, changelog
# ... make changes ...

git commit -m "chore: prepare release v1.2.0"

# Create PR to main
gh pr create --base main --title "Release v1.2.0"

# After merge, tag the release
git checkout main
git pull
git tag -a v1.2.0 -m "Release v1.2.0"
git push origin v1.2.0
```

### Commit Message Convention

We use [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

#### Types

| Type | Description |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `style` | Formatting, no code change |
| `refactor` | Code change, no new feature or fix |
| `perf` | Performance improvement |
| `test` | Adding tests |
| `chore` | Maintenance tasks |
| `ci` | CI/CD changes |

#### Examples

```bash
feat(basket-api): add redis cluster support
fix(ordering): resolve race condition in order processing
docs: update deployment guide
ci: add helm chart validation to PR checks
chore(deps): upgrade helm charts to v3.12
```

### Environment Mapping

| Branch | ArgoCD Target | Namespace | Auto-Sync |
|--------|---------------|-----------|-----------|
| `main` | main | eshop | Yes (self-heal) |
| `develop` | develop | eshop-staging | Yes |
| `feature/*` | feature branch | eshop-dev | Manual |

### Protected Branches

#### main
- Requires PR review
- Requires passing CI
- No direct pushes
- No force pushes

#### develop
- Requires passing CI
- No force pushes

### Code Review Guidelines

1. **Self-review first** - Check your own PR before requesting review
2. **Keep PRs small** - Under 400 lines preferred
3. **Write good PR descriptions** - What, why, and how
4. **Respond to feedback** - Address all comments
5. **Squash commits** - Clean history on merge

### Testing Requirements

Before submitting a PR:

```bash
# Lint all Helm charts
for chart in helm-charts/*/; do
  helm lint "$chart"
done

# Validate Kubernetes manifests
kubectl apply --dry-run=client -f k8s/

# Run Terragrunt validation
cd terragrunt/prod
terragrunt validate
```

### Release Process

1. Create release branch from develop
2. Update CHANGELOG.md
3. Bump versions in Chart.yaml files
4. Create PR to main
5. After merge, tag release
6. ArgoCD auto-syncs to production

### Hotfix Process

For urgent production fixes:

```bash
# Create hotfix from main
git checkout main
git checkout -b hotfix/fix-critical-bug

# Make fix
git commit -m "fix: resolve critical auth bypass"

# Create PR directly to main
gh pr create --base main --title "hotfix: Fix critical auth bypass"

# After merge, backport to develop
git checkout develop
git cherry-pick <commit-sha>
git push origin develop
```

## Questions?

Open an issue or contact the platform team.
