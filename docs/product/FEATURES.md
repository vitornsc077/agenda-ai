# 📋 Especificação de Features — AgendaAI (SaaS de Agendamento)

> **Produto:** Plataforma SaaS de agendamento online genérica
> **Público:** Qualquer tipo de negócio que precise gerenciar agendamentos
> **Modelo:** Planos pagos com trial gratuito de 14 dias
> **Prioridade:** MVP funcional para validação rápida

---

## 🎯 Visão do Produto

**AgendaAI** é uma plataforma de agendamento online multi-tenant que permite a qualquer negócio criar sua página de agendamento, gerenciar equipes, receber pagamentos e enviar notificações automáticas — tudo em poucos minutos.

### Proposta de Valor Única (UVP)
> "Monte sua agenda profissional em 5 minutos. Seus clientes agendam sozinhos. Você só trabalha."

### Concorrentes de Referência
| Concorrente | Ponto Forte | Fraqueza |
|:---|:---|:---|
| Calendly | Simplicidade, integrações | Sem pagamento nativo BR, caro para equipes |
| Simplybook.me | Customização | Interface datada, complexo |
| Doctoralia | Vertical saúde | Nicho restrito |
| Agendor | CRM BR | Não foca em agendamento público |

---

## 🔑 Jobs To Be Done (JTBD)

### JTBD 1 — Dono do Negócio (Tenant Admin)
> **Quando** estou perdendo clientes porque eles ligam fora do horário ou não conseguem agendar,
> **Eu quero** uma página online onde eles agendem sozinhos a qualquer hora,
> **Para que** eu não perca oportunidades e reduza o tempo gasto com confirmações manuais.

**Métrica de Sucesso:** Redução de 50% em agendamentos feitos por telefone/WhatsApp manual dentro de 30 dias.

---

### JTBD 2 — Cliente Final (Quem agenda)
> **Quando** preciso agendar um serviço com um profissional,
> **Eu quero** ver os horários disponíveis e reservar em poucos cliques,
> **Para que** eu não precise esperar resposta no WhatsApp ou ligar durante horário comercial.

**Métrica de Sucesso:** Taxa de conclusão de agendamento > 80% (visitou a página → agendou).

---

### JTBD 3 — Profissional da Equipe (Staff Member)
> **Quando** tenho minha agenda lotada e preciso organizar meus atendimentos,
> **Eu quero** ver meus compromissos no meu calendário e receber lembretes,
> **Para que** eu não perca horários e consiga me preparar adequadamente.

**Métrica de Sucesso:** 0 agendamentos esquecidos por profissional/mês.

---

### JTBD 4 — Dono do Negócio (Monetização)
> **Quando** ofereço serviços que exigem pagamento antecipado ou sinal,
> **Eu quero** que o cliente pague no momento do agendamento,
> **Para que** eu reduza no-shows e tenha previsibilidade de receita.

**Métrica de Sucesso:** Redução de 60% no índice de no-show com pagamento antecipado ativado.

---

## 📦 Features Detalhadas

### F1: Multi-tenancy (Ambientes Isolados)
| Campo | Detalhe |
|:---|:---|
| **Prioridade** | 🔴 Crítica (MVP) |
| **JTBD** | #1 |
| **Descrição** | Cada negócio (tenant) tem seus dados, serviços, equipe e configurações completamente isolados. |
| **Critérios de Aceite** | ✅ Dados de um tenant nunca são visíveis para outro. ✅ Subdomínio ou slug único por tenant (`empresa.agendaai.com` ou `agendaai.com/empresa`). ✅ Tenant admin pode customizar nome, logo e cores. |

---

### F2: Cadastro e Gestão de Serviços
| Campo | Detalhe |
|:---|:---|
| **Prioridade** | 🔴 Crítica (MVP) |
| **JTBD** | #1 |
| **Descrição** | Tenant admin cadastra os serviços oferecidos com nome, duração, preço e descrição. |
| **Critérios de Aceite** | ✅ CRUD de serviços com nome, duração (15/30/60/90/120 min), preço (opcional) e descrição. ✅ Serviço pode ser ativado/desativado. ✅ Serviço pode ser vinculado a profissionais específicos. |

---

### F3: Gestão de Equipe (Staff)
| Campo | Detalhe |
|:---|:---|
| **Prioridade** | 🔴 Crítica (MVP) |
| **JTBD** | #1, #3 |
| **Descrição** | Cadastro de profissionais com horários de disponibilidade individuais. |
| **Critérios de Aceite** | ✅ CRUD de profissionais (nome, email, foto, bio). ✅ Cada profissional define seus horários de trabalho por dia da semana. ✅ Suporte a intervalos/pausas (almoço, etc.). ✅ Bloqueio manual de horários (férias, folgas). |

---

### F4: Página Pública de Agendamento
| Campo | Detalhe |
|:---|:---|
| **Prioridade** | 🔴 Crítica (MVP) |
| **JTBD** | #2 |
| **Descrição** | Link público compartilhável onde o cliente final escolhe serviço → profissional → data/hora → confirma. |
| **Critérios de Aceite** | ✅ Fluxo: Escolher serviço → Escolher profissional (ou "qualquer disponível") → Selecionar data/hora no calendário → Preencher dados (nome, email, telefone) → Confirmar. ✅ Responsivo (mobile-first). ✅ Não requer login do cliente final. ✅ Exibe apenas horários realmente disponíveis (sem conflitos). |

---

### F5: Calendário e Gestão de Agendamentos
| Campo | Detalhe |
|:---|:---|
| **Prioridade** | 🔴 Crítica (MVP) |
| **JTBD** | #1, #3 |
| **Descrição** | Dashboard com visão de calendário (dia/semana/mês) mostrando todos os agendamentos. |
| **Critérios de Aceite** | ✅ Visões: dia, semana e mês. ✅ Filtro por profissional e serviço. ✅ Status do agendamento: pendente, confirmado, concluído, cancelado, no-show. ✅ Agendamento manual pelo admin/profissional. ✅ Cancelamento e reagendamento pelo admin. |

---

### F6: Notificações Automáticas (Email + WhatsApp)
| Campo | Detalhe |
|:---|:---|
| **Prioridade** | 🔴 Crítica (MVP) |
| **JTBD** | #2, #3 |
| **Descrição** | Envio automático de confirmação, lembrete e cancelamento. |
| **Critérios de Aceite** | ✅ Email de confirmação ao cliente e ao profissional no momento do agendamento. ✅ Lembrete por email 24h antes. ✅ Notificação de cancelamento. ✅ (Fase 2) Integração com WhatsApp via API (Evolution API / Twilio). |

---

### F7: Pagamento Online Integrado
| Campo | Detalhe |
|:---|:---|
| **Prioridade** | 🟡 Importante (MVP) |
| **JTBD** | #4 |
| **Descrição** | Cobrança no momento do agendamento (Pix, cartão de crédito). |
| **Critérios de Aceite** | ✅ Integração com Stripe (internacional) e/ou gateway BR (Pix via API). ✅ Tenant configura se o pagamento é obrigatório, opcional ou desativado. ✅ Opções: pagamento total ou sinal (% do valor). ✅ Reembolso automático em caso de cancelamento dentro da política. |

---

## 🧑‍💼 Personas

### Persona 1: Mariana — Dona de Salão de Beleza
- **Idade:** 34 anos
- **Dor:** Perde 2h/dia respondendo WhatsApp para agendar. Já perdeu clientes que desistiram de esperar.
- **Objetivo:** Ter uma "recepcionista digital" que funcione 24/7.
- **Disposição a pagar:** R$ 79-149/mês se resolver o problema.

### Persona 2: Dr. Lucas — Psicólogo
- **Idade:** 41 anos
- **Dor:** Pacientes faltam sem avisar (no-show de 25%). Precisa cobrar antecipado.
- **Objetivo:** Reduzir no-shows e automatizar confirmações.
- **Disposição a pagar:** R$ 99-199/mês.

### Persona 3: Carlos — Dono de Barbearia (3 barbeiros)
- **Idade:** 28 anos
- **Dor:** Cada barbeiro gerencia sua agenda no celular. Sem visão geral do negócio.
- **Objetivo:** Centralizar todas as agendas em um só lugar.
- **Disposição a pagar:** R$ 129-249/mês (plano equipe).
