# How Deployment Pipelines & Rules Work — Visual Diagram

## The Flow (Without Rules — THE PROBLEM)

```
┌─────────────────────┐      Deploy       ┌─────────────────────┐
│   DEV Workspace     │ ───────────────── │   PROD Workspace    │
│                     │                    │                     │
│  Dataflow Gen2      │                    │  Dataflow Gen2      │
│  → Dev_Lakehouse    │                    │  → Dev_Lakehouse ❌ │
│                     │                    │    (WRONG! Still    │
│                     │                    │     points to Dev!) │
└─────────────────────┘                    └─────────────────────┘
```

**Problem:** Prod dataflow still reads from Dev_Lakehouse = test data in production! 😱

---

## The Flow (With Rules — THE SOLUTION)

```
┌─────────────────────┐                    ┌─────────────────────┐
│   DEV Workspace     │                    │   UAT Workspace     │
│                     │      Deploy +      │                     │
│  Dataflow Gen2      │   ══ RULES ══════  │  Dataflow Gen2      │
│  Parameters:        │                    │  Parameters:        │
│   pLakehouseName    │   Rule swaps to:   │   pLakehouseName    │
│   = "Dev_Lakehouse" │ → "UAT_Lakehouse"  │   = "UAT_Lakehouse" │
│                     │                    │                     │
│   pFilterRegion     │   Rule swaps to:   │   pFilterRegion     │
│   = "ALL"           │ → "EMEA"           │   = "EMEA"          │
└─────────────────────┘                    └─────────────────────┘
                                                     │
                                                     │ Deploy + RULES
                                                     ▼
                                           ┌─────────────────────┐
                                           │  PROD Workspace     │
                                           │                     │
                                           │  Dataflow Gen2      │
                                           │  Parameters:        │
                                           │   pLakehouseName    │
                                           │   = "Prod_Lakehouse"│
                                           │                     │
                                           │   pFilterRegion     │
                                           │   = "ALL"           │
                                           └─────────────────────┘
                                                    ✅ Correct!
```

---

## The Two Rule Types — Side by Side

```
┌─────────────────────────────────────────────────────────────────┐
│                    DEPLOYMENT RULES                             │
├────────────────────────────┬────────────────────────────────────┤
│   DATA SOURCE RULES        │   PARAMETER RULES                  │
│                            │                                    │
│   Swaps WHICH Lakehouse    │   Changes VALUES inside            │
│   the dataflow connects to │   the dataflow's logic             │
│                            │                                    │
│   Example:                 │   Example:                         │
│   Dev_Lakehouse            │   pFilterRegion                    │
│      ↓                     │      ↓                             │
│   Prod_Lakehouse           │   "ALL" (was "EMEA")               │
│                            │                                    │
│   ✅ Simple, no-code       │   ✅ Flexible, any value           │
│   ❌ Only Fabric items     │   ✅ Works with external sources   │
│                            │   ⚠  Needs parameter setup first  │
└────────────────────────────┴────────────────────────────────────┘
```

---

## Classic vs New Pipelines — Quick Visual

```
┌────────────────────────────┐    ┌────────────────────────────────┐
│   CLASSIC PIPELINES (GA)   │    │   NEW PIPELINES (Preview)      │
│                            │    │                                │
│   Dev → Test → Prod        │    │   Dev → QA → UAT → Staging    │
│   (fixed 3 stages)         │    │      → Prod (2-10 stages)     │
│                            │    │                                │
│   ✅ Dataflow Gen2 rules   │    │   ⚠  Rules still rolling out  │
│   ✅ Production ready      │    │   ✅  Better UI & comparison   │
│   ✅ Use this NOW          │    │   ⚠  Test in Dev only          │
└────────────────────────────┘    └────────────────────────────────┘

         RECOMMENDED                    WAIT FOR GA
```

---

## Setup Checklist

- [ ] Create parameters in Dataflow Gen2 (Manage Parameters)
- [ ] **Enable Public Parameters** (Options → Parameters → Enable)  ← DON'T FORGET!
- [ ] Use parameters in M code (not hard-coded values)
- [ ] Set destination in the dataflow
- [ ] Create deployment pipeline (Classic)
- [ ] Assign workspaces to stages
- [ ] Deploy once (first deploy, default values)
- [ ] Configure Data Source Rules per stage
- [ ] Configure Parameter Rules per stage
- [ ] Test by deploying Dev → UAT → Prod
- [ ] Schedule refresh after deployment
