# Sprint 5 Retrospective

**Owned by:** Scrum Master

This file is completed at the end of Week 9, before your team begins its challenge track. Review what your team shipped, what went well, what went poorly, and one specific process change for Sprint 6.

## What Went Well

TODO: What did your team do well this sprint? What accomplishment are you proud of?

## What Could Be Better

TODO: What was difficult? What slowed you down? What surprised you?

## What We'll Do Differently Next Sprint

TODO: Based on what you learned, name one specific process change or workflow improvement you will try in Sprint 6.

## Team Contributions

Use this section to note which team members led which parts of the work:

| Role | Name | Primary Contribution |
|---|---|---|
| Scrum Master | | |
| System Admin | | |
| QA | | |
| Developer 1 | | |
| Developer 2+ | | |

## Sprint Goals

- Load the incident tracker database with ~50,000 synthetic records
- Use k6 to run baseline and ramped load tests
- Diagnose database-layer bottleneck (missing index)
- Diagnose infrastructure-layer bottleneck (CPU throttling)
- Fix both issues and measure improvement
- Add k6 threshold gate to GitHub Actions CI

## Metrics Achieved

- Database rows seeded: ___
- Baseline P95 response time: ___ms
- Post-fix P95 response time: ___ms
- CPU throttle rate before fix: ___
- CPU throttle rate after fix: ___
- k6 threshold gate: passes CI

## Notes

Any additional context about the sprint that does not fit the structure above.
