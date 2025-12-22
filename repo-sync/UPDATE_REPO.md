# Updating the Repo & Dev Workflow

We track upstream changes using a **mirror branch** to keep our custom features as a clean patch on top.

## Branch Strategy

* `upstream-main` → **Mirror of upstream** (`mistralai/mistral-vibe:main`). **NEVER** commit to this branch.
* `main` → **Product branch**. Contains our branding, provider changes, and features.
* `feature/*` → Normal development branches (PR into `main`).

---

## Normal Development

Always branch from `main` for new features or fixes:

```bash
# Get latest main
git checkout main
git pull origin main

# Start work
git checkout -b feature/my-new-change

# Work normally
git add -A
git commit -m "feat: describe change"
git push -u origin feature/my-new-change

```

*Open a PR on GitHub to merge your feature branch into `main`.*

---

## Syncing with Upstream (mistral-vibe updates)

### 1. Update the mirror

This ensures your local mirror perfectly matches the official source.

```bash
git checkout upstream-main
git fetch upstream
git reset --hard upstream/main
git push origin upstream-main --force

```

### 2. Rebase our changes

This puts our custom work on top of the latest upstream code.

```bash
git checkout main
git rebase upstream-main

```

> [!CAUTION]
> **Conflict Resolution**
> If Git stops, conflicts exist in files we both modified.
> 1. Manually fix the code in the flagged files.
> 2. `git add -A`
> 3. `git rebase --continue`
> *(Repeat until the rebase is finished)*
>
>

### 3. Push updated main

```bash
git push origin main --force-with-lease

```

---

## Rules to Follow

* ❌ **Never** merge `upstream-main` directly into `main` (it creates messy merge commits).
* ❌ **Never** commit directly to `upstream-main`.

## Useful Checks

* **See only our custom changes:** `git log upstream-main..main`
* **Check branch alignment:** `git branch -vv`
