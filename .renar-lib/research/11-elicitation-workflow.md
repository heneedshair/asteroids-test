# Elicitation Workflow для REQ

> Версия: черновик 0.1 (для обсуждения) | Дата: 2026-05-03
> Назначение: workflow добычи требований у клиента/стейкхолдеров через AI-агента. Закрывает BABOK Elicitation knowledge area gap, выявленный в [01-positioning-vs-world-standards.md §3.5](01-positioning-vs-world-standards.md).
>
> Финальная нормативная форма — после пилота на 2-3 реальных проектах.

---

## 1. Не дублирует SENAR

SENAR описывает работу **с уже существующими требованиями**: декомпозиция, верификация, gates. SENAR не описывает **процесс получения требований** от стейкхолдеров — это исторически было предполагалось как «вне scope методологии разработки».

RENAR **расширяет** этот предположение: в 100% agent-driven контексте AI-агент способен проводить структурированный диалог со стейкхолдером. Это становится частью REQ.

---

## 2. Связь с BABOK

BABOK v3 определяет 6 knowledge areas; одна из них — **Elicitation and Collaboration** (§4):

- **Prepare for Elicitation** (4.1) — план интервью.
- **Conduct Elicitation** (4.2) — само интервью / мастер-класс / observation.
- **Confirm Elicitation Results** (4.3) — подтверждение понимания.
- **Communicate Business Analysis Information** (4.4) — передача результата команде.
- **Manage Stakeholder Collaboration** (4.5) — работа со стейкхолдерами.

REQ адаптирует все 5 sub-areas для AI-driven контекста.

---

## 3. Главный pipeline

```
[Подписан рамочный договор / открыт первый Order]
      │
      ▼
PHASE 1 — Preparation
   ├── Stakeholder identification (kai_search прошлых проектов клиента)
   ├── Domain context loading (web research, прошлые ТЗ, public artifacts)
   └── Prepare interview script (AI-генератор по template)
      │
      ▼
PHASE 2 — Elicitation
   ├── Sequential AI-led interviews (Socratic Q&A)
   │   └── Per stakeholder, 30-60 минут each
   ├── Document review (existing artifacts client provides)
   ├── Optional: shadowing/observation (если применимо)
   └── Collected raw data → structured findings
      │
      ▼
PHASE 3 — Synthesis
   ├── AI synthesizes findings → ТЗ-черновик
   ├── Adversarial critic — что упущено, что противоречит
   ├── Multi-model agreement check
   └── Stakeholder map + business goals diagram
      │
      ▼
PHASE 4 — Confirmation
   ├── ТЗ-черновик отправляется stakeholder для review
   ├── Comments collected (через Princess или другой канал)
   └── Iteration: AI обновляет ТЗ-черновик
      │
      ▼
PHASE 5 — Sign-off
   ├── Финальная версия ТЗ
   ├── Подпись клиентом (юридически)
   └── Импорт в .req/tz/ → запуск REQ-pipeline
```

---

## 4. Phase 1 — Preparation

### 4.1 Stakeholder identification

AI-агент через KAI / Raven запрашивает:

```bash
kai_search "client X" scope=federation
# Возвращает: прошлые проекты, известные стейкхолдеры, контекст
```

При первом проекте с клиентом:

- Клиент сам перечисляет стейкхолдеров через onboarding form в Princess.
- AI-агент анализирует public profile клиента (LinkedIn, корпоративный сайт) для добавления known roles (CEO, CTO, Product, Sales, Operations).
- Stakeholder map собирается как граф (см. [16-req-graph-schema-draft.md](16-req-graph-schema-draft.md)).

### 4.2 Domain context loading

AI-агент собирает контекст:

- **Web research**: industry overview, common challenges, regulatory environment.
- **Public artifacts клиента**: годовые отчёты, public RFPs, marketing material.
- **Прошлые ТЗ Kibertum** в схожих доменах через `kai_search` federation-wide.
- **Industry standards и best practices**: для healthcare — HIPAA primer; для fintech — PCI DSS basics.

Контекст сохраняется в `<project>.req/elicitation/domain-context.md` как живой документ.

### 4.3 Interview script preparation

AI генерирует interview script per stakeholder через `req-prompts/elicitation-script@vN.md`:

```markdown
---
stakeholder: "Sales Director"
domain: "B2B SaaS sales"
duration-target: "45 minutes"
generated-by: claude-opus-4-7@2026-05-03
---

## Opening (3 min)
- "Расскажите про роль и зону ответственности."
- "Какая главная боль в вашем дне?"

## Goals exploration (10 min)
- "Опишите идеальный исход проекта через 6 месяцев."
- "Какие KPI вы отслеживаете?"
- "Что блокирует достижение этих KPI сейчас?"

## Pain points (15 min)
- "Опишите типичный сценарий, где текущий процесс ломается."
- "Сколько времени тратится на эту проблему еженедельно?"
- "Что вы пробовали, что не сработало?"

## Boundaries / non-goals (10 min)
- "Что точно НЕ должно входить в этот проект?"
- "Какие данные / процессы трогать нельзя?"

## Wrap-up (7 min)
- "Кто ещё должен высказаться по этому проекту?"
- "Какие документы можно изучить?"
- "Как лучше держать связь?"
```

Script — **скелет**, не sequential. AI-агент адаптирует на ходу.

---

## 5. Phase 2 — Elicitation

### 5.1 Modality

| Тип интервью | Когда используется | Как реализуется |
|---|---|---|
| **AI-led text chat** | Дефолт; быстро, структурированно | Через Princess клиентский портал, чат-интерфейс |
| **AI-assisted voice call** | Когда клиент предпочитает голос | Voice-to-text → AI processes → структурированный output |
| **Async questionnaire** | Для distributed teams | Princess form, AI follow-up на ответы |
| **Document-driven** | Клиент уже имеет много документов | AI читает, генерирует уточняющие вопросы |

### 5.2 Socratic Q&A pattern

AI-агент ведёт диалог по принципам:

- Один вопрос за раз.
- Open-ended (не yes/no, кроме как для подтверждения).
- Follow-up на интересные ветки.
- При vague ответе — конкретизация: «можешь привести пример?»
- При противоречии — нейтральная подсветка: «ранее ты сказал X, сейчас Y — это разные ситуации?»

### 5.3 Output of phase 2

Per stakeholder:

```yaml
# elicitation/<stakeholder-id>.yaml
stakeholder: "Sales Director"
date: 2026-05-04T10:00:00Z
duration-min: 47
modality: text-chat
ai-provenance:
  generated-by: claude-opus-4-7@2026-05-03
  ...
findings:
  - id: F-01
    type: pain-point
    text: "Ручной перенос данных из CRM в Excel занимает 3 часа в день"
    confidence: high                  # AI confidence в правильном понимании
    quotes:                            # raw квоты из диалога
      - "...Excel reports каждое утро..."
  - id: F-02
    type: goal
    text: "Сократить ручную работу до 30 минут в день"
    related-kpi: "Manual task time"
    related-pain: F-01
follow-ups:
  - "Уточнить какие именно поля переносятся"
  - "Понять, почему сейчас не используется Zapier / native integration"
```

---

## 6. Phase 3 — Synthesis

### 6.1 Genaration of ТЗ-черновика

AI-агент берёт findings от всех стейкхолдеров и синтезирует:

```
[All findings]
   │
   ▼
Cluster by topic (LLM clustering)
   │
   ▼
Identify business goals + pain points + boundaries
   │
   ▼
Draft sections:
   ├── Background / Context
   ├── Business goals (with KPIs)
   ├── Functional Requirements (черновик BR)
   ├── Non-functional Requirements (по ISO 25010)
   ├── Out of scope
   └── Constraints (data, regulatory, timeline)
   │
   ▼
ТЗ-черновик (markdown)
```

### 6.2 Adversarial review

Critic-агент с другой моделью генерирует:

```yaml
critic-findings:
  - severity: high
    issue: "Не упомянут data residency для российских клиентов в проекте с PII"
    location: "§5 НФТ"
    suggested-question: "Уточнить юрисдикцию хранения данных"
  - severity: medium
    issue: "Stakeholder Operations Director дал противоречивые указания относительно retention period"
    location: "§4 ФТ-008"
    quotes:
      - elicitation/operations-director.yaml#F-12
      - elicitation/operations-director.yaml#F-19
    suggested-question: "Запросить разъяснение от Operations Director"
```

### 6.3 Multi-model agreement

Параллельная генерация ТЗ-черновика второй моделью. Diff на уровне утверждений. Расхождения сводятся для архитектора:

```markdown
## Расхождения между моделями
- §4 ФТ-005: Claude утверждает "отчёт ежедневный", GPT — "еженедельный"
  → Источник: Sales Director сказал "каждое утро" (Claude интерпретировал как daily, GPT как weekly)
  → Решение архитектора: УТОЧНИТЬ у Sales Director
```

### 6.4 Output of phase 3

```
<project>.req/
  elicitation/
    domain-context.md                  ← Phase 1
    sales-director.yaml                ← Phase 2 per stakeholder
    operations-director.yaml
    cto.yaml
    findings-clustered.md              ← Phase 3 synthesis
    critic-review.md                   ← Phase 3 adversarial
    multi-model-diff.md                ← Phase 3 multi-model
  tz/
    TZ-2026-NNN-draft.md               ← Phase 3 final draft
```

---

## 7. Phase 4 — Confirmation

### 7.1 Stakeholder review loop

ТЗ-черновик отправляется каждому стейкхолдеру для review. Через Princess клиент:

- Видит свои findings (что AI понял из его слов).
- Видит сводный ТЗ-черновик с цитатами на findings.
- Может оставить inline comments / questions.

AI-агент processes comments:
- При ambiguity — follow-up question stakeholder.
- При conflict между stakeholders — escalation на архитектора + sync-meeting (вне AI loop).
- При confirmed correction — обновляет ТЗ-черновик, новая версия draft.

### 7.2 Iteration limit

Max 3 итерации в фазе Confirmation. Если после 3-го круга остаются open issues — escalation на ручной workshop с архитектором.

---

## 8. Phase 5 — Sign-off

### 8.1 Финальная версия

ТЗ помечается `final` в frontmatter:

```yaml
---
id: TZ-2026-NNN
status: signed                         # draft → review → signed
signed-at: 2026-05-15
signed-by:
  - "Client CEO" (digital signature link)
  - "Kibertum Architect" (digital signature link)
elicitation-cycles: 2
multi-model-agreement: 0.91            # similarity score
critic-findings-resolved: 8/9
---
```

### 8.2 Импорт в `.req`

После sign-off:

```bash
tausik req import-tz --order-id NNN --type initial
```

Это перемещает draft в `tz/TZ-2026-NNN.md` с финальной версией, генерирует `tz/TZ-2026-NNN-index.md` (маппинг разделов на запланированные BR/SR), удаляет `elicitation/draft-*` (но сохраняет findings и provenance).

После этого начинается стандартный REQ-pipeline: декомпозиция → BR/SR → TC → ...

---

## 9. Skill `/req-elicit`

```
/req-elicit start <client-slug>
   — инициирует Phase 1, генерирует stakeholder map, domain context

/req-elicit interview <stakeholder-id>
   — открывает Princess interview chat для stakeholder
   — AI ведёт по script, сохраняет findings

/req-elicit synthesize
   — Phase 3: synthesis + adversarial + multi-model
   — генерирует ТЗ-черновик

/req-elicit review-loop
   — Phase 4: отправляет stakeholder'ам для review
   — собирает comments, iterates

/req-elicit finalize
   — Phase 5: sign-off, импорт в .req/tz/
```

---

## 10. Метрики elicitation

| Метрика | Что показывает | Цель |
|---|---|---|
| Time to ТЗ | От первого интервью до signed-off | < 2 недели |
| Iterations in Confirmation | Сколько итераций draft → review → revise | ≤ 2 |
| Stakeholder satisfaction | Survey после sign-off | ≥ 4/5 |
| Critic findings resolution rate | Сколько issues от critic'а реально resolved до sign-off | ≥ 90% |
| Multi-model agreement at sign-off | Embedding similarity между двумя моделями | ≥ 0.85 |
| Post-sign-off changes (delta-TZ within 30 days) | Indicator плохой elicitation | ≤ 1 delta-TZ |

---

## 11. Ограничения и когда не использовать AI elicitation

AI-driven elicitation **не подходит** для:

- **Высокочувствительные регулируемые домены** (medical devices, financial trading с millisecond latency, defense). Требует регулируемых процедур.
- **Высокая политическая сложность** — несколько стейкхолдеров с конфликтующими интересами требуют человеческой facilitation.
- **Очень новые домены** — AI не имеет training data. Лучше manual elicitation с domain expert.

В этих случаях AI помогает (preparation, synthesis, document review), но не ведёт интервью самостоятельно.

---

## 12. Open questions

- [ ] Voice modality: integrate voice-to-text провайдер или клиент сам присылает запись?
- [ ] Stakeholder authentication: как убедиться, что отвечает именно тот, кого позвали? (Princess auth, но что с external stakeholders?)
- [ ] Когда «иссякло» — после скольких ответов с low marginal value прекращать интервью?
- [ ] Multi-language: как с русскоязычным клиентом + английским ТЗ output? Translation в каком этапе?
- [ ] Privacy in interviews: stakeholders могут раскрывать sensitive business info (конкуренты, internal struggles). Какая модель приватности? Anthropic privacy settings + не train on conversations.
- [ ] Conflict resolution: AI обнаруживает противоречие между stakeholders. Эскалация на архитектора через какой канал?
- [ ] Если клиент категорически отказывается от AI elicitation — fallback на manual workflow с tooling support?
