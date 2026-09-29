# References

All rules come from the following sources. No rule was invented; each rule in `src/knowledge_base.pl` carries a source key (`nbts` or `nbts_m`).

1. **[nbts]** National Blood Transfusion Service (NBTS), Ministry of Health, Sri Lanka. *Donate Blood - Who Can Donate Blood?* https://nbts.health.gov.lk/donate-blood/
   Used for: age (18-60, first-time donors up to 55), 4-month donation interval, weight above 50 kg, haemoglobin above 12.5 g/dL, not pregnant, free from serious medical illness, free from "risk behaviours", National Identity Card / valid ID, malaria-endemic travel (3-year deferral), other foreign travel (3-month deferral), the 2024 malaria-endemic country list, "ask NBTS staff if unsure about travel", and the before/after-donation advice.
2. **[nbts_m]** The Morning (20 June 2023). *NBTS statement on donor eligibility.* https://www.themorning.lk/articles/ygxn9lNR7Sg6OEOkgniL
   Used for: history of epilepsy is not accepted in Sri Lanka (rule d09).

## Interpretation notes
- "above 50 kg" and "above 12.5 g/dL" are implemented as strictly greater than.
- NBTS lists "Risk Behaviors" without details on the page, so the system asks one yes/no question.
- Rules s01-s03 (final decision) combine the individual criteria; they are labelled "derived inference rules" in the report.
