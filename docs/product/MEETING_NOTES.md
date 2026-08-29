# 📌 Planejamento de Produto — AgendaAI

> **Data:** 2026-08-29
> **Tipo:** Kickoff de Produto — SaaS de Agendamento Genérico
> **Objetivo:** Definir visão, MVP, personas e roadmap para validação rápida.

---

## Decisões Tomadas

### 1. Posicionamento
- **Tipo:** SaaS B2B genérico (não vertical). Qualquer negócio que agende.
- **Diferencial:** Simplicidade de setup (5 min), página pública tipo Calendly e pagamento nativo BR (Pix).
- **Nome de trabalho:** AgendaAI.

### 2. Modelo de Negócio
- **Monetização:** Planos pagos com trial de 14 dias (sem cartão).
- **Planos:** Starter (R$79), Professional (R$149), Business (R$299), Enterprise (sob consulta).
- **Decisão:** NÃO teremos plano gratuito permanente. O trial de 14 dias é suficiente para demonstrar valor.

### 3. Escopo do MVP (6 semanas)
As features críticas para o MVP são:
1. Multi-tenancy com isolamento total de dados
2. Autenticação (registro + login + convite de equipe)
3. CRUD de Serviços
4. Gestão de Equipe (profissionais + horários)
5. Página Pública de Agendamento (link compartilhável)
6. Motor de Disponibilidade (cálculo de slots livres)
7. Calendário Admin (dia/semana/mês)
8. Notificações por Email (confirmação + lembrete)
9. Lógica de Trial (14 dias)

### 4. O que ficou FORA do MVP (deliberadamente)
- ❌ Pagamento online (vai para a fase "Next")
- ❌ WhatsApp (vai para a fase "Next")
- ❌ Google Calendar sync (vai para a fase "Next")
- ❌ App mobile (vai para "Later")
- ❌ Marketplace (vai para "Later")

**Razão:** Validar primeiro se o core (agendar fácil) resolve o problema, antes de investir em integrações complexas.

### 5. Stack Técnica (sugestão para o Arquiteto)
> ⚠️ Decisão final é do Rails Architect, mas a recomendação do PM é:
- **Backend:** Ruby on Rails 8+ (monolito com multi-tenancy)
- **Frontend:** Hotwire (Turbo + Stimulus) para reatividade sem SPA
- **Database:** PostgreSQL
- **Background Jobs:** Solid Queue
- **Email:** Action Mailer + Resend/Postmark
- **Deploy:** Kamal 2 (Docker-based, zero-downtime)

---

## Próximos Passos

| Passo | Responsável | Status |
|:---|:---|:---:|
| ✅ Definir personas e JTBD | Product Manager | `[x]` |
| ✅ Criar FEATURES.md com critérios de aceite | Product Manager | `[x]` |
| ✅ Criar ROADMAP.md com WSJF e metas | Product Manager | `[x]` |
| Criar Implementation Plan (schema, arquitetura) | **@Rails Architect** | `[ ]` |
| Definir UI/UX da página pública de agendamento | **@UI/UX Designer** | `[ ]` |
| Bootstrapping do projeto Rails | **@Rails Developer** | `[ ]` |

---

## Riscos Identificados

| Risco | Probabilidade | Impacto | Mitigação |
|:---|:---:|:---:|:---|
| Multi-tenancy mal implementada → vazamento de dados | Média | 🔴 Crítico | Usar `acts_as_tenant` ou `apartment` gem. Testes de isolamento obrigatórios. |
| Motor de disponibilidade com bugs → double-booking | Alta | 🔴 Crítico | Locks otimistas no banco. Testes extensivos de concorrência. |
| Trial sem conversão → receita zero | Média | 🟡 Alto | Onboarding guiado. Email drip durante o trial. Métricas de ativação. |
| Concorrência com Calendly/SimplyBook | Alta | 🟡 Médio | Focar no mercado BR: Pix nativo, WhatsApp, precificação em Real. |
