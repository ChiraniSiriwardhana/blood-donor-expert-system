%% =====================================================================
%%  KNOWLEDGE BASE
%%  Facts and production rules derived from the NBTS Sri Lanka donor criteria.
%%  Source: https://nbts.health.gov.lk/donate-blood/
%% =====================================================================

%% =====================================================================
%%  PART 1 : KNOWLEDGE BASE - FACTS
%% =====================================================================

%% 1.1 Input attributes (facts collected from the user)
attribute(age,               'Age (years)').
attribute(sex,               'Sex').
attribute(first_time,        'First-time donor?').
attribute(months_since_last, 'Months since last donation').
attribute(weight_kg,         'Weight (kg)').
attribute(haemoglobin,       'Haemoglobin (g/dL)').
attribute(pregnant,          'Pregnant?').
attribute(serious_illness,   'Serious medical illness?').
attribute(epilepsy,          'History of epilepsy?').
attribute(risk_behaviour,    'NBTS "risk behaviours"?').
attribute(valid_id,          'Has National ID / valid ID?').
attribute(travel_country,    'Foreign travel (country)').
attribute(months_since_return, 'Months since return from travel').

%% 1.2 Sources
source(nbts,   'NBTS Sri Lanka - "Who Can Donate Blood?" - https://nbts.health.gov.lk/donate-blood/').
source(nbts_m, 'NBTS statement in The Morning, 20 June 2023 - https://www.themorning.lk/articles/ygxn9lNR7Sg6OEOkgniL').

%% 1.3 Eligibility criteria (labels used for the checklist)
criterion(age,        'Age 18-60 years (first-time donors up to 55)').
criterion(interval,   'At least 4 months since last donation').
criterion(weight,     'Weight above 50 kg').
criterion(haemoglobin,'Haemoglobin above 12.5 g/dL').
criterion(health,     'Not pregnant, no serious illness, no epilepsy').
criterion(behaviour,  'Free from NBTS "risk behaviours"').
criterion(id,         'National Identity Card or valid ID available').
criterion(travel,     'Travel deferral period completed').

%% 1.4 Deferral reasons: deferral_info(Code, Criterion, Explanation)
deferral_info(underage,           age,         'You are younger than 18 years.').
deferral_info(over_60,            age,         'You are older than 60 years.').
deferral_info(first_time_over_55, age,         'First-time donors must be 55 years or younger.').
deferral_info(interval,           interval,    'Less than 4 months since your last donation.').
deferral_info(underweight,        weight,      'Weight must be above 50 kg.').
deferral_info(low_haemoglobin,    haemoglobin, 'Haemoglobin must be above 12.5 g/dL.').
deferral_info(pregnant,           health,      'Pregnant women cannot donate.').
deferral_info(serious_illness,    health,      'Donors must be free from serious medical illnesses.').
deferral_info(epilepsy,           health,      'A history of epilepsy is not accepted in Sri Lanka.').
deferral_info(risk_behaviour,     behaviour,   'Donors must be free from "risk behaviours".').
deferral_info(no_id,              id,          'Bring a National Identity Card or another valid ID.').
deferral_info(malaria_travel,     travel,      'Returned from a malaria-endemic country less than 3 years ago.').
deferral_info(foreign_travel,     travel,      'Returned from foreign travel less than 3 months ago.').

%% 1.5 NBTS malaria-endemic country list (2024) - 3-year deferral
malaria_endemic('Angola'). malaria_endemic('Benin'). malaria_endemic('Botswana').
malaria_endemic('Burkina Faso'). malaria_endemic('Burundi'). malaria_endemic('Cameroon').
malaria_endemic('Central African Republic'). malaria_endemic('Chad'). malaria_endemic('Comoros').
malaria_endemic('Congo'). malaria_endemic('Cote d\'Ivoire'). malaria_endemic('Djibouti').
malaria_endemic('DR Congo'). malaria_endemic('Egypt'). malaria_endemic('Equatorial Guinea').
malaria_endemic('Eritrea'). malaria_endemic('Eswatini'). malaria_endemic('Ethiopia').
malaria_endemic('Gabon'). malaria_endemic('Gambia'). malaria_endemic('Ghana').
malaria_endemic('Guinea'). malaria_endemic('Guinea-Bissau'). malaria_endemic('Kenya').
malaria_endemic('Liberia'). malaria_endemic('Madagascar'). malaria_endemic('Malawi').
malaria_endemic('Mali'). malaria_endemic('Mauritania'). malaria_endemic('Mayotte').
malaria_endemic('Mozambique'). malaria_endemic('Namibia'). malaria_endemic('Niger').
malaria_endemic('Nigeria'). malaria_endemic('Rwanda'). malaria_endemic('Sao Tome & Principe').
malaria_endemic('Senegal'). malaria_endemic('Sierra Leone'). malaria_endemic('Somalia').
malaria_endemic('South Africa'). malaria_endemic('Sudan'). malaria_endemic('South Sudan').
malaria_endemic('Togo'). malaria_endemic('Tanzania'). malaria_endemic('Uganda').
malaria_endemic('Zambia'). malaria_endemic('Zimbabwe').
malaria_endemic('Afghanistan'). malaria_endemic('Bangladesh'). malaria_endemic('Bhutan').
malaria_endemic('Cambodia'). malaria_endemic('Georgia'). malaria_endemic('India').
malaria_endemic('Indonesia'). malaria_endemic('Iran'). malaria_endemic('Iraq').
malaria_endemic('Laos'). malaria_endemic('Malaysia'). malaria_endemic('Myanmar').
malaria_endemic('Nepal'). malaria_endemic('North Korea'). malaria_endemic('Pakistan').
malaria_endemic('Papua New Guinea'). malaria_endemic('Philippines').
malaria_endemic('Saudi Arabia (border areas)'). malaria_endemic('Solomon Islands').
malaria_endemic('South Korea'). malaria_endemic('Thailand'). malaria_endemic('Timor-Leste').
malaria_endemic('Turkey'). malaria_endemic('Vanuatu'). malaria_endemic('Vietnam'). malaria_endemic('Yemen').
malaria_endemic('Belize'). malaria_endemic('Bolivia'). malaria_endemic('Brazil').
malaria_endemic('Colombia'). malaria_endemic('Costa Rica'). malaria_endemic('Dominican Republic').
malaria_endemic('Ecuador'). malaria_endemic('French Guiana'). malaria_endemic('Guatemala').
malaria_endemic('Guyana'). malaria_endemic('Haiti'). malaria_endemic('Honduras').
malaria_endemic('Mexico'). malaria_endemic('Nicaragua'). malaria_endemic('Panama').
malaria_endemic('Peru'). malaria_endemic('Suriname'). malaria_endemic('Venezuela').

%% =====================================================================
%%  PART 2 : KNOWLEDGE BASE - RULES
%%  rule(Id, Stratum, [Conditions], Attribute=Value, SourceKey)
%%  (d14/s03: NBTS says unsure travellers should ask NBTS staff)
%%  Conditions: A=V | A<N | A>N | A>=N | A=<N | in_kb(Attr,Pred)
%%              exists(Attr) | absent(Attr)
%%  Stratum 1 : criteria checks (passed / deferral)
%%  Stratum 2 : final decision (uses negation, so runs after stratum 1)
%%  Stratum 3 : recommendations
%% =====================================================================

%% --- Stratum 1a : criteria that are PASSED ---
rule(p01, 1, [age>=18, age=<55],                              passed=age,         nbts).
rule(p02, 1, [first_time=no, age>55, age=<60],                passed=age,         nbts).
rule(p03, 1, [months_since_last>=4],                          passed=interval,    nbts).
rule(p04, 1, [weight_kg>50],                                  passed=weight,      nbts).
rule(p05, 1, [haemoglobin>12.5],                              passed=haemoglobin, nbts).
rule(p06, 1, [pregnant=no, serious_illness=no, epilepsy=no],  passed=health,      nbts).
rule(p07, 1, [risk_behaviour=no],                             passed=behaviour,   nbts).
rule(p08, 1, [travel_country=none],                           passed=travel,      nbts).
rule(p09, 1, [in_kb(travel_country, malaria_endemic), months_since_return>=36], passed=travel, nbts).
rule(p11, 1, [valid_id=yes],                                  passed=id,          nbts).
rule(p10, 1, [travel_country=other, months_since_return>=3],  passed=travel,      nbts).

%% --- Stratum 1b : DEFERRAL reasons ---
rule(d01, 1, [age<18],                                        deferral=underage,           nbts).
rule(d02, 1, [age>60],                                        deferral=over_60,            nbts).
rule(d03, 1, [first_time=yes, age>55],                        deferral=first_time_over_55, nbts).
rule(d04, 1, [months_since_last<4],                           deferral=interval,           nbts).
rule(d05, 1, [weight_kg=<50],                                 deferral=underweight,        nbts).
rule(d06, 1, [haemoglobin=<12.5],                             deferral=low_haemoglobin,    nbts).
rule(d07, 1, [pregnant=yes],                                  deferral=pregnant,           nbts).
rule(d08, 1, [serious_illness=yes],                           deferral=serious_illness,    nbts).
rule(d09, 1, [epilepsy=yes],                                  deferral=epilepsy,           nbts_m).
rule(d10, 1, [risk_behaviour=yes],                            deferral=risk_behaviour,     nbts).
rule(d11, 1, [in_kb(travel_country, malaria_endemic), months_since_return<36], deferral=malaria_travel, nbts).
rule(d12, 1, [travel_country=other, months_since_return<3],   deferral=foreign_travel,     nbts).
rule(d13, 1, [valid_id=no],                                   deferral=no_id,              nbts).
rule(d14, 1, [travel_country=unsure],                         referral=travel_unsure,      nbts).

%% --- Stratum 2 : FINAL DECISION ---
rule(s01, 2, [absent(deferral), absent(referral)], status=eligible,     nbts).
rule(s02, 2, [exists(deferral)],                 status=not_eligible, nbts).
rule(s03, 2, [absent(deferral), exists(referral)], status=refer_nbts,    nbts).

%% --- Stratum 3 : RECOMMENDATIONS for eligible donors ---
rule(a01, 3, [status=eligible], advice='Bring your National Identity Card or another valid ID.', nbts).
rule(a02, 3, [status=eligible], advice='Before donating: have a main meal within the last 4 hours.', nbts).
rule(a03, 3, [status=eligible], advice='Before donating: drink plenty of fluids.', nbts).
rule(a04, 3, [status=eligible], advice='Before donating: avoid alcohol.', nbts).
rule(a05, 3, [status=eligible], advice='Before donating: rest for at least 6 hours the previous night.', nbts).
rule(a06, 3, [status=eligible], advice='After donating: rest for at least 20 minutes.', nbts).
rule(a07, 3, [status=eligible], advice='After donating: drink more fluids over the next 4 hours.', nbts).
rule(a08, 3, [status=eligible], advice='After donating: keep the plaster on for about 12 hours.', nbts).
rule(a09, 3, [status=eligible], advice='After donating: avoid heavy lifting for 24 hours.', nbts).

