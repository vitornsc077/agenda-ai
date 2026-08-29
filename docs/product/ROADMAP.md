# 🗺️ Roadmap — AgendaAI

> **Atualizado em:** 2026-08-29
> **Modelo:** Now / Next / Later
> **Estratégia:** MVP → Validação → Crescimento

---

## 🔴 NOW — MVP (Semanas 1-6)
> Objetivo: Lançar versão funcional para 10 beta testers pagantes.

| # | Feature | WSJF | JTBD | Status |
|:--|:---|:---:|:---:|:---:|
| 1 | **Multi-tenancy** (isolamento de dados, slug/subdomínio) | 30 | #1 | `[x]` |
| 2 | **Autenticação** (registro, login, convite de equipe) | 28 | #1 | `[x]` |
| 3 | **CRUD de Serviços** (nome, duração, preço, vínculo com staff) | 25 | #1 | `[x]` |
| 4 | **Gestão de Equipe** (profissionais, horários, pausas, bloqueios) | 25 | #1, #3 | `[x]` |
| 5 | **Página Pública de Agendamento** (fluxo completo, mobile-first) | 27 | #2 | `[x]` |
| 6 | **Motor de Disponibilidade** (calcular slots livres em tempo real) | 26 | #2 | `[x]` |
| 7 | **Calendário Admin** (visão dia/semana/mês, agendamento manual) | 24 | #1, #3 | `[x]` |
| 8 | **Notificações por Email** (confirmação + lembrete 24h) | 22 | #2, #3 | `[x]` |
| 9 | **Trial de 14 dias** (onboarding, billing flag, expiração) | 20 | — | `[x]` |

### Critérios de Saída do MVP
- [ ] 10 tenants criados e agendando ativamente
- [ ] Taxa de conclusão de agendamento > 70%
- [ ] NPS dos beta testers > 7
- [ ] Zero vazamentos de dados entre tenants

---

## 🟡 NEXT — Monetização & Retenção (Semanas 7-12)
> Objetivo: Converter trials em assinantes e aumentar engajamento.

| # | Feature | WSJF | JTBD | Status |
|:--|:---|:---:|:---:|:---:|
| 10 | **Pagamento Online** (Stripe + Pix, sinal ou total) | 22 | #4 | `[ ]` |
| 11 | **Billing / Assinaturas** (planos, cobrança recorrente, upgrade/downgrade) | 21 | — | `[ ]` |
| 12 | **Notificações WhatsApp** (via Evolution API ou Twilio) | 20 | #2, #3 | `[ ]` |
| 13 | **Integração Google Calendar** (sync bidirecional) | 18 | #3 | `[ ]` |
| 14 | **Dashboard de Métricas** (agendamentos/dia, no-show rate, receita) | 17 | #1 | `[ ]` |
| 15 | **Customização visual** (cores, logo, banner na página pública) | 15 | #1 | `[ ]` |
| 16 | **Política de cancelamento** (configurável por tenant, reembolso auto) | 14 | #4 | `[ ]` |

### Critérios de Saída
- [ ] 30% dos trials convertidos em assinantes pagos
- [ ] MRR (Monthly Recurring Revenue) > R$ 3.000
- [ ] Churn mensal < 10%

---

## 🟢 LATER — Escala & Diferenciação (Trimestre 2+)
> Objetivo: Expandir o mercado e criar barreiras competitivas.

| # | Feature | JTBD | Status |
|:--|:---|:---:|:---:|
| 17 | **App Mobile** (React Native / Flutter para profissionais) | #3 | `[ ]` |
| 18 | **Agendamento recorrente** (semanal, quinzenal, mensal) | #2 | `[ ]` |
| 19 | **Lista de espera** (cliente entra em fila se horário cheio) | #2 | `[ ]` |
| 20 | **Avaliações e reviews** (cliente avalia o atendimento) | #1 | `[ ]` |
| 21 | **API pública + Webhooks** (integração com sistemas externos) | #1 | `[ ]` |
| 22 | **Marketplace** (diretório público de negócios cadastrados) | #1 | `[ ]` |
| 23 | **IA para sugestão de horários** (otimizar agenda do profissional) | #3 | `[ ]` |
| 24 | **Multi-idioma** (i18n completo: pt-BR, en, es) | #1 | `[ ]` |
| 25 | **Relatórios avançados** (exportação, comparativos, sazonalidade) | #1 | `[ ]` |

---

## 💰 Planos e Precificação (Proposta Inicial)

| Plano | Preço/mês | Limites |
|:---|:---:|:---|
| **Starter** | R$ 79 | 1 profissional, 100 agendamentos/mês, email apenas |
| **Professional** | R$ 149 | 5 profissionais, ilimitado, email + WhatsApp |
| **Business** | R$ 299 | 15 profissionais, ilimitado, pagamento online, API, prioridade no suporte |
| **Enterprise** | Sob consulta | Ilimitado, SLA, domínio próprio, onboarding dedicado |

> **Trial:** 14 dias do plano Professional (sem cartão).

---

## 📊 Métricas-Chave (North Star)

| Métrica | Meta MVP | Meta 6 meses |
|:---|:---:|:---:|
| **Agendamentos realizados/mês** (North Star) | 500 | 10.000 |
| **Tenants ativos** | 10 | 100 |
| **MRR** | R$ 0 (trial) | R$ 15.000 |
| **Taxa de conversão trial → pago** | — | 30% |
| **No-show rate (com lembrete)** | < 20% | < 10% |
| **NPS** | > 7 | > 8 |

---

## 🚀 Rollout Strategy

### Fase 1 — Validação (Semanas 1-6)
1. **Internal:** Time de desenvolvimento usa o sistema internamente.
2. **Alpha:** 3-5 negócios conhecidos (amigos/rede) usam gratuitamente.
3. **Beta fechado:** 10 negócios com trial de 14 dias. Coleta intensiva de feedback.

### Fase 2 — Lançamento Controlado (Semanas 7-12)
4. **Beta aberto:** Landing page com waitlist. Aceita inscrições com trial automático.
5. **Cobrança ativa:** Billing habilitado. Trials expiram. Conversão monitorada.

### Fase 3 — Growth (Trimestre 2+)
6. **GA (General Availability):** Marketing ativo. SEO, conteúdo, referral program.
7. **Marketplace:** Diretório público para aquisição orgânica.
