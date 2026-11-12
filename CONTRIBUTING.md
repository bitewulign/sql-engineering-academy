# Contributing to SQL Engineering Academy

Thank you for considering a contribution. This project is a community learning resource — contributions that improve accuracy, clarity, and coverage are always welcome.

---

## Ways to Contribute

- **Fix a bug** — incorrect SQL, a wrong expected output, a broken query
- **Improve an explanation** — clearer wording, better examples
- **Add an exercise or challenge** — with a matching solution
- **Report a platform version discrepancy** — SQL that works on one platform but not another, undocumented
- **Translate content** — module materials in other languages
- **Add a new module** — following the module template

---

## Before You Start

1. **Search open issues** — your bug or idea may already be tracked
2. **Open an issue first** for significant changes (new modules, structural changes) so the approach can be discussed before you invest time in writing
3. **Small fixes** (typos, broken SQL, wrong expected output) can go straight to a pull request

---

## Development Setup

```bash
git clone https://github.com/your-org/sql-engineering-academy.git
cd sql-engineering-academy
cp .env.example .env
# Edit .env — fill in passwords
docker-compose up -d
```

Verify all three databases are healthy:
```bash
docker-compose ps
```

---

## SQL File Standards

Every SQL file must:

1. **Begin with the standard header:**
   ```sql
   -- ============================================================
   -- SQL Engineering Academy
   -- Engine:  <SQL Server 2022 | PostgreSQL 16 | MySQL 8.0>
   -- Module:  <nn> — <Module Title>
   -- File:    <filename.sql>
   -- Author:  <Your Name or handle>
   -- ============================================================
   ```

2. **Be tested and produce the expected output** on the stated engine version

3. **Use synthetic data only** — no real names, emails, phone numbers, or business data

4. **Include comments** explaining non-obvious syntax, especially platform-specific constructs

5. **Never contain credentials** — no passwords, connection strings with passwords, or API keys

---

## Module Template

Each module directory follows this structure:

```
modules/module-NN/
├── README.md           — objectives, contents, how to use
├── lecture-notes.md    — full written lesson
├── slides/
│   └── module-NN-slides.md   — Marp-compatible presentation
├── code/
│   ├── sql-server/     — T-SQL files
│   ├── postgresql/     — PL/pgSQL files
│   └── mysql/          — MySQL files
├── labs/
│   └── lab-NN-guided.md
├── exercises/
│   └── exercises-NN.md
├── assessments/
│   └── quiz-NN.md      — includes answer key
└── solutions/
    └── solutions-NN.md
```

The assessment file contains its own answer key (this is a learner-facing repo — no separate instructor key directory is used here).

---

## Pull Request Process

1. Fork the repository and create a branch: `git checkout -b fix/module-01-null-example`
2. Make your changes
3. Test all SQL against the Docker environment
4. Commit with a descriptive message
5. Open a pull request against `main`
6. Fill out the pull request template completely

Pull requests that add or change SQL **must** include a note confirming the query was run against the Docker environment and the output matches what is documented.

---

## Code of Conduct

This project follows the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md). By participating you agree to uphold it.

---

## Questions

Open a GitHub Discussion or file an issue with the `question` label.
